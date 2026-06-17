import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
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

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      messagesChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getInitialLink' || methodCall.method == 'getLatestLink') {
          return null;
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      eventsChannel,
      (MethodCall methodCall) async {
        return null;
      },
    );

    mockCubit = MockEmailCitasCubit();
    if (!GetIt.I.isRegistered<EmailCitasCubit>()) {
      await configureDependencies();
    }
    GetIt.I.unregister<EmailCitasCubit>();
    GetIt.I.registerSingleton<EmailCitasCubit>(mockCubit);
  });

  tearDown(() {
    GetIt.I.unregister<EmailCitasCubit>();
  });

  group('Email Citas Golden Tests', () {
    testWidgets('Email Connect Page - Disconnected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(EmailCitasInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const EmailConnectPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EmailConnectPage),
        matchesGoldenFile("../../../../../golden/reference/email_connect_disconnected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Email Connect Page - Connected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const EmailCitasConnected(
        isGmailConnected: true,
        isOutlookConnected: false,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const EmailConnectPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EmailConnectPage),
        matchesGoldenFile("../../../../../golden/reference/email_connect_connected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Email Connect Page - Loading', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(EmailCitasLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const EmailConnectPage()));
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(EmailConnectPage),
        matchesGoldenFile("../../../../../golden/reference/email_connect_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
