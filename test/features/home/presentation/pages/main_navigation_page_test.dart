import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/home/presentation/pages/main_navigation_page.dart';
import 'package:orionhealth_health/features/reports/application/bloc/report_bloc.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockHomeCubit extends Mock implements HomeCubit {}
class MockReportBloc extends Mock implements ReportBloc {}
class MockUserProfileCubit extends Mock implements UserProfileCubit {}
class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockReportBloc mockReportBloc;
  late MockUserProfileCubit mockUserProfileCubit;
  late MockHealthRecordCubit mockHealthRecordCubit;

  setUpAll(() {
    mockHomeCubit = MockHomeCubit();
    mockReportBloc = MockReportBloc();
    mockUserProfileCubit = MockUserProfileCubit();
    mockHealthRecordCubit = MockHealthRecordCubit();

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<HomeCubit>()) {
      getIt.registerSingleton<HomeCubit>(mockHomeCubit);
    }
    if (!getIt.isRegistered<ReportBloc>()) {
      getIt.registerSingleton<ReportBloc>(mockReportBloc);
    }
    if (!getIt.isRegistered<UserProfileCubit>()) {
      getIt.registerSingleton<UserProfileCubit>(mockUserProfileCubit);
    }
    if (!getIt.isRegistered<HealthRecordCubit>()) {
      getIt.registerSingleton<HealthRecordCubit>(mockHealthRecordCubit);
    }
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  setUp(() {
    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});

    when(() => mockReportBloc.state).thenReturn(const ReportInitial());
    when(() => mockReportBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockReportBloc.close()).thenAnswer((_) async {});

    when(() => mockUserProfileCubit.state).thenReturn(const UserProfileInitial());
    when(() => mockUserProfileCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUserProfileCubit.close()).thenAnswer((_) async {});

    when(() => mockHealthRecordCubit.state).thenReturn(const HealthRecordInitial());
    when(() => mockHealthRecordCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockHealthRecordCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: MainNavigationPage()),
    );
  }

  testWidgets('navigation between tabs works', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Home tab should be active
    expect(find.text('ORION HEALTH'), findsOneWidget);

    // Tap on Reports
    await tester.tap(find.byIcon(Icons.description_outlined));
    await tester.pump();

    // Tap on Health Records
    await tester.tap(find.byIcon(Icons.medical_services_outlined));
    await tester.pump();

    // Tap on Profile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();

    // Tap back to Dashboard
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pump();
    expect(find.text('ORION HEALTH'), findsOneWidget);
  });
}
