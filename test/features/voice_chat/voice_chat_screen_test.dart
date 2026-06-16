import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/voice_chat_screen.dart';

/// Widget test for VoiceChatScreen.
///
/// Note: VoiceChatScreen depends on several sub-widgets (VoiceChatAgentView,
/// VoiceChatHistory, VoiceChatStatusBar, VoiceChatControls) and services
/// (AIService, AudioService, AsrService, AgentMemoryService) that are
/// imported from the main screen file. This test verifies that the screen
/// can be constructed and renders its initial loading state correctly.
void main() {
  testWidgets('VoiceChatScreen renders loading state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatScreen(),
      ),
    );

    // The screen starts in loading/initializing state
    expect(find.text('Orion — Chat de Voz'), findsOneWidget);

    // Verify the loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('VoiceChatScreen has back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatScreen(),
      ),
    );

    // Should have a back arrow in the AppBar
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('VoiceChatScreen has clear conversation button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatScreen(),
      ),
    );

    // Clear conversation button should exist (though disabled initially)
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
