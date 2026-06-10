import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart' as bloc_state;
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/receive_medical_data_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/share_medical_data_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockAuthCubit extends Mock implements AuthCubit {}
class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSharingCubit mockSharingCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    mockAuthCubit = MockAuthCubit();
    mockSharingCubit = MockSharingCubit();
    getIt.registerFactory<AuthCubit>(() => mockAuthCubit);
    getIt.registerFactory<SharingCubit>(() => mockSharingCubit);
    registerFallbackValue(TransferMethod.nfc);
  });

  setUp(() {
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.state).thenReturn(const bloc_state.AuthInitial());

    when(() => mockSharingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSharingCubit.state).thenReturn(SharingInitial());
    when(() => mockSharingCubit.initialize()).thenAnswer((_) async {});
    when(() => mockSharingCubit.startListening(any())).thenAnswer((_) async {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Setup PIN Page - Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const SetupPinPage(),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(SetupPinPage),
      matchesGoldenFile('goldens/setup_pin_page.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Receive Medical Data Page - Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    when(() => mockSharingCubit.state).thenReturn(const SharingScanning(TransferMethod.nfc));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const ReceiveMedicalDataPage(),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(ReceiveMedicalDataPage),
      matchesGoldenFile('goldens/receive_medical_data_page.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Share Medical Data Page - Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const ShareMedicalDataPage(),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(ShareMedicalDataPage),
      matchesGoldenFile('goldens/share_medical_data_page.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
