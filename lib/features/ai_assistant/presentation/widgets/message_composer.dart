import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_theme.dart';

class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final Function(String)? onQuickPrompt;
  final bool isEnabled;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.onQuickPrompt,
    this.isEnabled = true,
  });

  static const List<String> _quickPrompts = [
    'Analyze my last labs',
    'Check blood pressure',
    'Medication schedule',
    'Symptom checker',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEnabled) _buildQuickPrompts(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: CyberTheme.secondary),
                  onPressed: isEnabled ? onAttach : null,
                  tooltip: 'Attach file',
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      enabled: isEnabled,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: CyberTheme.primary),
                  onPressed: isEnabled ? onSend : null,
                  tooltip: 'Send message',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPrompts() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 12,
                  color: CyberTheme.primary,
                ),
              ),
              backgroundColor: CyberTheme.primary.withValues(alpha: 0.1),
              side: const BorderSide(color: CyberTheme.primary, width: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () => onQuickPrompt?.call(prompt),
            ),
          );
        },
      ),
    );
  }
}
