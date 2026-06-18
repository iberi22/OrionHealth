import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

void main() {
  late MockMedicalResearchCubit mockCubit;

  setUp(() {
    mockCubit = MockMedicalResearchCubit();
    final getIt = GetIt.instance;
    getIt.registerFactory<MedicalResearchCubit>(() => mockCubit);

    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('MedicalResearchPage renders Scaffold with INVESTIGACIÓN MÉDICA title', (tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    // Verify the app bar title
    expect(find.text('INVESTIGACIÓN MÉDICA'), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows three tabs: EVIDENCIA, INTERACCIONES, ICD-10', (tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    expect(find.text('EVIDENCIA'), findsOneWidget);
    expect(find.text('INTERACCIONES'), findsOneWidget);
    expect(find.text('ICD-10'), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows evidence tab search field', (tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    // Verify the search hint on the evidence tab
    expect(find.text('Ej: Tratamiento para Diabetes Tipo 2...'), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows ICD-10 search field on third tab', (tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    // Switch to the ICD-10 tab
    await tester.tap(find.text('ICD-10'));
    await tester.pumpAndSettle();

    expect(find.text('Ej: Hipertensión, Diabetes...'), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows empty state message on evidence tab', (tester) async {
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    // Default idle state shows the placeholder message
    expect(find.text('Ingresa una consulta para comenzar la investigación.'), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows loading spinner when loading evidence', (tester) async {
    when(() => mockCubit.state).thenReturn(
      const MedicalResearchState(
        status: MedicalResearchStatus.loading,
        loadingMessage: 'Buscando evidencia médica...',
      ),
    );
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MedicalResearchPage shows error message when in error state', (tester) async {
    when(() => mockCubit.state).thenReturn(
      const MedicalResearchState(
        status: MedicalResearchStatus.error,
        errorMessage: 'Error de conexión',
      ),
    );
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicalResearchPage(),
      ),
    );

    expect(find.text('Error de conexión'), findsOneWidget);
  });
}
