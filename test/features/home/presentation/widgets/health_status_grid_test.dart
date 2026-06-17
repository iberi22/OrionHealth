import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/features/home/presentation/widgets/health_status_grid.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late StreamController<HomeState> stateController;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    stateController = StreamController<HomeState>.broadcast();

    when(() => mockHomeCubit.state).thenReturn(const HomeState());
    when(() => mockHomeCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockHomeCubit.close()).thenAnswer((_) async => stateController.close());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const HealthStatusGrid(),
        ),
      ),
    );
  }

  testWidgets('HealthStatusGrid renders all categories', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Frecuencia Cardíaca'), findsOneWidget);
    expect(find.text('Presión Arterial'), findsOneWidget);
    expect(find.text('Temperatura'), findsOneWidget);
    expect(find.text('Saturación de Oxígeno'), findsOneWidget);
  });
}
