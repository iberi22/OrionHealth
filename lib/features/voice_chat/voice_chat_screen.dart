import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/audio/audio_recorder_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';
import 'package:orionhealth_health/features/voice_chat/state/voice_chat_state.dart';
import 'package:orionhealth_health/core/widgets/connection_status_indicator.dart';

/// Full voice chat screen with complete pipeline:
/// Record -> Transcribe -> Memory -> AI Response -> TTS -> Playback
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  final VoiceChatState _chatState = VoiceChatState();
  final AIService _aiService = AIService();
  final AudioService _audioService = AudioService();
  final AsrService _asrService = AsrService();
  final AgentMemoryService _memoryService = AgentMemoryService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Audio level tracking
  double _currentAudioLevel = 0.0;
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _aiStateSubscription;
  StreamSubscription? _asrStateSubscription;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _errorSubscription;

  // Initialization
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initServices();
  }

  Future<void> _initServices() async {
    setState(() => _isInitializing = true);

    try {
      await _memoryService.initialize();

      await _aiService.initialize();
      await _audioService.initialize();
      await _asrService.initialize();

      // Load recent history into state
      final recentHistory = await _memoryService.getRecentHistory(limit: 20);
      _chatState.clearHistory();
      for (final memory in recentHistory.reversed) {
        _chatState.addConversationTurn(memory.userInput, memory.aiResponse);
      }

      final count = await _memoryService.getMemoryCount();
      _chatState.updateMemoryStatus(true, count);

      // Subscribe to volume levels
      _volumeSubscription = _audioService.currentVolumeStream.listen((vol) {
        setState(() => _currentAudioLevel = vol);
      });

      // Subscribe to AI state for UI updates
      _aiStateSubscription = _aiService.stateStream.listen((_) {
        if (mounted) setState(() {});
      });

      // Subscribe to ASR state
      _asrStateSubscription = _asrService.stateStream.listen((state) {
        if (mounted) {
          setState(() {
            if (state == AsrState.transcribing) {
              _chatState.updateStatus(
                VoiceChatStatus.processing,
                message: 'Transcribiendo...',
              );
            } else if (state == AsrState.unavailable) {
              _chatState.setError(
                'Modelo ASR no instalado. Ve a Configuración.',
              );
            }
          });
        }
      });

      // Subscribe to audio state
      _stateSubscription = _audioService.stateStream.listen((state) {
        setState(() {
          if (state == AudioState.speaking || state == AudioState.playing) {
            _chatState.updateStatus(
              VoiceChatStatus.speaking,
              message: 'Respondiendo...',
            );
          } else if (state == AudioState.playbackCompleted ||
              state == AudioState.playbackStopped ||
              state == AudioState.ttsStopped) {
            _chatState.updateStatus(
              VoiceChatStatus.idle,
              message: 'Listo para conversar',
            );
          }
        });
      });

      // Subscribe to errors
      _errorSubscription = _audioService.errorStream.listen((error) {
        _chatState.setError(error);
        setState(() {});
      });

      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _initError = 'Error inicializando: $e';
      });
    }
  }

  Future<void> _onRecordPressed() async {
    if (!_chatState.canStartRecording) return;

    _chatState.clearError();
    _chatState.updateStatus(VoiceChatStatus.recording, message: 'Grabando...');
    await _audioService.startRecording();
    setState(() {});
  }

  Future<void> _onStopRecording() async {
    if (!_chatState.canStopRecording) return;

    _chatState.updateStatus(
      VoiceChatStatus.processing,
      message: 'Transcribiendo audio...',
    );
    setState(() {});

    try {
      final audioBytes = await _audioService.stopRecording();
      if (audioBytes == null || audioBytes.isEmpty) {
        _chatState.setError('No se pudo capturar el audio');
        _chatState.updateStatus(
          VoiceChatStatus.error,
          message: 'Error de audio',
        );
        return;
      }

      String transcription;
      try {
        if (_asrService.currentState == AsrState.unavailable) {
          _chatState.setError('Modelo ASR no disponible. Usando fallback.');
          transcription = await _aiService.transcribeAudio(audioBytes);
        } else {
          transcription = await _asrService.transcribe(audioBytes);
        }

        if (transcription.trim().isEmpty) {
          throw Exception('Transcripción vacía');
        }
      } catch (e) {
        if (kDebugMode) {
          print('ASR Error, falling back: $e');
        }
        transcription = await _aiService.transcribeAudio(audioBytes);
      }

      _chatState.updateTranscription(transcription);
      _chatState.updateStatus(
        VoiceChatStatus.processing,
        message: 'Consultando memoria...',
      );

      final context = await _memoryService.getContextForQuery(transcription);
      final contextList = context.isNotEmpty ? [context] : <String>[];

      _chatState.updateStatus(
        VoiceChatStatus.processing,
        message: 'Generando respuesta...',
      );

      final response = await _aiService.getResponse(
        transcription,
        context: contextList,
      );

      _chatState.updateAiResponse(response);
      _chatState.addConversationTurn(transcription, response);

      await _memoryService.addMemory(input: transcription, output: response);

      final count = await _memoryService.getMemoryCount();
      _chatState.updateMemoryStatus(true, count);

      _chatState.updateStatus(
        VoiceChatStatus.speaking,
        message: 'Respondiendo...',
      );
      await _audioService.speakText(response);
      _scrollToBottom();
    } catch (e) {
      _chatState.setError('Error en el proceso: $e');
      _chatState.updateStatus(
        VoiceChatStatus.error,
        message: 'Error — intenta de nuevo',
      );
    }
    setState(() {});
  }

  Future<void> _onSendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    _chatState.updateStatus(
      VoiceChatStatus.processing,
      message: 'Consultando memoria...',
    );
    setState(() {});

    try {
      final context = await _memoryService.getContextForQuery(text);
      final contextList = context.isNotEmpty ? [context] : <String>[];

      _chatState.updateStatus(
        VoiceChatStatus.processing,
        message: 'Generando respuesta...',
      );

      final response = await _aiService.getResponse(text, context: contextList);

      _chatState.updateTranscription(text);
      _chatState.updateAiResponse(response);
      _chatState.addConversationTurn(text, response);

      await _memoryService.addMemory(input: text, output: response);
      final count = await _memoryService.getMemoryCount();
      _chatState.updateMemoryStatus(true, count);

      _chatState.updateStatus(
        VoiceChatStatus.speaking,
        message: 'Respondiendo...',
      );
      await _audioService.speakText(response);
      _scrollToBottom();
    } catch (e) {
      _chatState.setError('Error: $e');
      _chatState.updateStatus(VoiceChatStatus.error, message: 'Error');
    }
    setState(() {});
  }

  Future<void> _onInterrupt() async {
    await _audioService.stopAll();
    _chatState.clearError();
    _chatState.updateStatus(VoiceChatStatus.idle, message: 'Interrumpido');
  }

  Future<void> _onClearConversation() async {
    _chatState.clearHistory();
    _chatState.updateStatus(
      VoiceChatStatus.idle,
      message: 'Conversación limpiada',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _volumeSubscription?.cancel();
    _aiStateSubscription?.cancel();
    _asrStateSubscription?.cancel();
    _stateSubscription?.cancel();
    _errorSubscription?.cancel();
    _audioService.dispose();
    _memoryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Orion — Chat de Voz',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed:
                _chatState.conversationHistory.isNotEmpty
                    ? _onClearConversation
                    : null,
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body:
          _isInitializing
              ? _buildLoadingView()
              : _initError != null
              ? _buildErrorView()
              : _buildMainContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white70),
          SizedBox(height: 24),
          Text(
            'Inicializando servicios...',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Memoria, IA y Audio',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              _initError!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _initError = null;
                });
                _initServices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LocalConnectionStatus(
            isLocalAIReady: _aiService.currentState == AIServiceState.ready,
            isMemoryReady: _chatState.isMemoryAvailable,
            memoryCount: _chatState.memoryCount,
            onRetry: () => _aiService.initialize(),
          ),
        ),
        const SizedBox(height: 16),
        VoiceChatAgentView(
          chatState: _chatState,
          pulseAnimation: _pulseAnimation,
        ),
        Expanded(
          child: VoiceChatHistory(
            chatState: _chatState,
            scrollController: _scrollController,
          ),
        ),
        VoiceChatStatusBar(
          chatState: _chatState,
          currentAudioLevel: _currentAudioLevel,
        ),
        VoiceChatControls(
          chatState: _chatState,
          textController: _textController,
          onRecordPressed: _onRecordPressed,
          onStopRecording: _onStopRecording,
          onSendTextMessage: _onSendTextMessage,
          onInterrupt: _onInterrupt,
        ),
      ],
    );
  }
}
