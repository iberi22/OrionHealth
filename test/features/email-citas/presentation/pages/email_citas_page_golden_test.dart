import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/email-citas/presentation/email_connect_page.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_cubit.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockEmailCitasCubit extends Mock implements EmailCitasCubit {}

void main() {
  late MockEmailCitasCubit mockCubit;

  setUpAll(() {
    mockCubit = MockEmailCitasCubit();
    GetIt.I.registerSingleton<EmailCitasCubit>(mockCubit);
  });

  tearDownAll(() {
    GetIt.I.reset();
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
        matchesGoldenFile('goldens/email_connect_disconnected.png'),
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
        matchesGoldenFile('goldens/email_connect_connected.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Email Connect Page - Loading', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(EmailCitasLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const EmailConnectPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EmailConnectPage),
        matchesGoldenFile('goldens/email_connect_loading.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
