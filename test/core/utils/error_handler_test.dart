import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    late ErrorHandler errorHandler;

    setUp(() {
      errorHandler = ErrorHandler();
    });

    test('handleError emits AppError to errorStream', () async {
      final expectation = expectLater(
        errorHandler.errorStream,
        emits(isA<AppError>().having((e) => e.error, 'error', 'test error')),
      );

      ErrorHandler.handleError('test error', null, context: 'test');

      await expectation;
    });

    test('handleAuthError uses correct context and severity', () async {
      final expectation = expectLater(
        errorHandler.errorStream,
        emits(isA<AppError>()
          .having((e) => e.context, 'context', 'Local Profile')
          .having((e) => e.severity, 'severity', ErrorSeverity.warning)),
      );

      ErrorHandler.handleAuthError('auth error');

      await expectation;
    });

    test('handleNetworkError uses correct context and metadata', () async {
      final expectation = expectLater(
        errorHandler.errorStream,
        emits(isA<AppError>()
          .having((e) => e.context, 'context', 'Network')
          .having((e) => e.metadata, 'metadata', containsPair('type', 'network'))),
      );

      ErrorHandler.handleNetworkError('network error');

      await expectation;
    });

    test('handleVoiceChatError uses correct metadata', () async {
      final expectation = expectLater(
        errorHandler.errorStream,
        emits(isA<AppError>()
          .having((e) => e.metadata, 'metadata', containsPair('type', 'voice_chat'))),
      );

      ErrorHandler.handleVoiceChatError('voice error');

      await expectation;
    });

    test('handleMemoryError sets showToUser to false', () async {
      final expectation = expectLater(
        errorHandler.errorStream,
        emits(isA<AppError>()
          .having((e) => e.showToUser, 'showToUser', false)),
      );

      ErrorHandler.handleMemoryError('memory error');

      await expectation;
    });

    test('AppError toString returns formatted string', () {
      final timestamp = DateTime.now();
      final error = AppError(
        error: 'err',
        context: 'ctx',
        severity: ErrorSeverity.error,
        metadata: {},
        timestamp: timestamp,
        showToUser: true,
      );

      expect(error.toString(), contains('ctx'));
      expect(error.toString(), contains('error'));
    });
  });
}
