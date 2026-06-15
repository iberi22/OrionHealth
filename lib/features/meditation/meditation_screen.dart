import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/audio/audio_recorder_service.dart';

typedef MeditationAudioAction = Future<void> Function();
typedef MeditationSpeakAction = Future<void> Function(String text);
typedef MeditationMemoryHintsLoader = Future<List<String>> Function();

class MeditationScreen extends StatefulWidget {
  final MeditationService? meditationService;
  final MeditationAudioAction? initializeAudio;
  final MeditationSpeakAction? speakText;
  final MeditationAudioAction? stopTts;
  final MeditationAudioAction? stopAll;
  final MeditationMemoryHintsLoader? loadMemoryHints;

  const MeditationScreen({
    super.key,
    this.meditationService,
    this.initializeAudio,
    this.speakText,
    this.stopTts,
    this.stopAll,
    this.loadMemoryHints,
  });

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late final MeditationService _meditationService;
  late final MeditationAudioAction _initializeAudio;
  late final MeditationSpeakAction _speakText;
  late final MeditationAudioAction _stopTts;
  late final MeditationAudioAction _stopAll;
  late final MeditationMemoryHintsLoader _loadMemoryHints;

  bool _isInitialized = false;
  bool _isMeditating = false;
  bool _isPaused = false;
  bool _isFinished = false;
  String? _error;

  int _elapsedSeconds = 0;
  Timer? _timer;

  MeditationScript? _script;
  MeditationSessionRecord? _session;
  MeditationProgress _progress = const MeditationProgress();
  List<String> _meditationSteps = const [];
  int _currentStep = 0;

  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    _meditationService = widget.meditationService ?? MeditationService();
    if (widget.initializeAudio != null &&
        widget.speakText != null &&
        widget.stopTts != null &&
        widget.stopAll != null) {
      _initializeAudio = widget.initializeAudio!;
      _speakText = widget.speakText!;
      _stopTts = widget.stopTts!;
      _stopAll = widget.stopAll!;
    } else {
      final audioService = AudioService();
      _initializeAudio = widget.initializeAudio ?? audioService.initialize;
      _speakText = widget.speakText ?? audioService.speakText;
      _stopTts = widget.stopTts ?? audioService.stopTTS;
      _stopAll = widget.stopAll ?? audioService.stopAll;
    }
    _loadMemoryHints = widget.loadMemoryHints ?? _loadLocalMemoryHints;

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _breathAnimation = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _initializeMeditation();
  }

  Future<void> _initializeMeditation() async {
    try {
      await _meditationService.initialize();
      await _initializeAudio();

      final hints = await _loadMemoryHints();
      final script = await _meditationService.recommendScript(
        memoryHints: hints,
      );
      final progress = await _meditationService.getProgress();

      if (!mounted) return;
      setState(() {
        _script = script;
        _meditationSteps = script.steps;
        _progress = progress;
        _isInitialized = true;
      });
    } catch (e) {
      final fallback = _meditationService.scripts.first;
      if (!mounted) return;
      setState(() {
        _script = fallback;
        _meditationSteps = fallback.steps;
        _error = 'Meditacion offline con contenido local.';
        _isInitialized = true;
      });
    }
  }

  Future<List<String>> _loadLocalMemoryHints() async {
    try {
      final memory = AgentMemoryService();
      await memory.initialize();
      final matches = await memory.searchMemories(
        query: 'meditacion calma enfoque dormir respiracion ansiedad',
        limit: 3,
      );
      return matches
          .map((node) => '${node.userInput} ${node.aiResponse}')
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _startMeditation() async {
    final script = _script;
    if (script == null) return;

    _timer?.cancel();
    final session = await _meditationService.startSession(script);
    if (!mounted) return;

    setState(() {
      _session = session;
      _isMeditating = true;
      _isPaused = false;
      _isFinished = false;
      _currentStep = 0;
      _elapsedSeconds = 0;
    });

    _breathController.repeat(reverse: true);
    await _speakCurrentStep();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isMeditating || _isPaused) return;
      setState(() => _elapsedSeconds++);

      if (_elapsedSeconds > 0 &&
          _elapsedSeconds % 45 == 0 &&
          _currentStep < _meditationSteps.length - 1) {
        _advanceStep();
      }
    });
  }

  Future<void> _speakCurrentStep() async {
    if (_currentStep >= 0 && _currentStep < _meditationSteps.length) {
      await _speakText(_meditationSteps[_currentStep]);
    }
  }

  Future<void> _advanceStep() async {
    if (_currentStep < _meditationSteps.length - 1) {
      setState(() => _currentStep++);
      await _speakCurrentStep();
    }
  }

  Future<void> _nextStep() async {
    if (_currentStep < _meditationSteps.length - 1) {
      await _advanceStep();
    } else {
      await _finishMeditation();
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      await _speakCurrentStep();
    }
  }

  Future<void> _pauseMeditation() async {
    _timer?.cancel();
    _breathController.stop();
    await _stopTts();
    setState(() {
      _isPaused = true;
      _isMeditating = false;
    });
  }

  Future<void> _resumeMeditation() async {
    setState(() {
      _isPaused = false;
      _isMeditating = true;
    });
    _breathController.repeat(reverse: true);
    await _speakCurrentStep();
    _startTimer();
  }

  Future<void> _finishMeditation() async {
    _timer?.cancel();
    _breathController.stop();

    final session = _session;
    if (session != null) {
      await _meditationService.completeSession(
        session: session,
        elapsedSeconds: _elapsedSeconds,
        completedSteps: _currentStep + 1,
      );
    }
    final progress = await _meditationService.getProgress();
    await _speakText(
      'La meditacion ha terminado. Has completado ${_formatDuration(_elapsedSeconds)}.',
    );

    if (!mounted) return;
    setState(() {
      _progress = progress;
      _isMeditating = false;
      _isPaused = false;
      _isFinished = true;
    });
  }

  Future<void> _restartMeditation() async {
    await _stopAll();
    _timer?.cancel();
    _breathController.stop();
    await _startMeditation();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    unawaited(_stopAll());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101828),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Meditacion Guiada'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            unawaited(_stopAll());
            _timer?.cancel();
            _breathController.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101828), Color(0xFF2F3B73), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white70),
            SizedBox(height: 24),
            Text(
              'Preparando meditacion local...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_isFinished) {
      return MeditationFinishedView(
        elapsedSeconds: _elapsedSeconds,
        progress: _progress,
        onRestart: _restartMeditation,
      );
    }

    if (!_isMeditating && !_isPaused) {
      return MeditationWelcomeView(
        script: _script,
        progress: _progress,
        error: _error,
        onStart: _startMeditation,
      );
    }

    return MeditationActiveView(
      steps: _meditationSteps,
      currentStep: _currentStep,
      elapsedSeconds: _elapsedSeconds,
      isPaused: _isPaused,
      breathAnimation: _breathAnimation,
      onPrevious: _previousStep,
      onTogglePause: _isPaused ? _resumeMeditation : _pauseMeditation,
      onNext: _nextStep,
    );
  }
}
