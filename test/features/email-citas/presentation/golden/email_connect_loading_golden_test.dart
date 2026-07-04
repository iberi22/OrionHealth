import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import 'package:flutter/services.dart';
import '../../../../core/golden_test_utils.dart';

class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}

void main() {
  late MockEmailCitasCubit mockCubit;
  const MethodChannel messagesChannel = MethodChannel('com.llfbandit.app_links/messages');
  const MethodChannel eventsChannel = MethodChannel('com.llfbandit.app_links/events');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      messagesChannel,
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      eventsChannel,
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() async {
    mockCubit = MockEmailCitasCubit();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<EmailCitasCubit>(mockCubit);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Email Connect Loading Golden Test', () {
    testWidgets('Email Connect Page - Loading State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EmailCitasLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const EmailConnectPage()));
      // No pumpAndSettle because of CircularProgressIndicator
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(EmailConnectPage),
        matchesGoldenFile("goldens/email_connect_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
