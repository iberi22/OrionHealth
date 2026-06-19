import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';

class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}

void main() {
  late MockHealthRecordCubit mockCubit;
  late StreamController<HealthRecordState> stateController;

  setUpAll(() {
    registerFallbackValue(RecordType.clinicalNote);
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockCubit = MockHealthRecordCubit();
    stateController = StreamController<HealthRecordState>.broadcast();

    when(() => mockCubit.state).thenReturn(HealthRecordInitial());
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.loadRecords()).thenAnswer((_) async {});
    when(() => mockCubit.resetAndLoad()).thenAnswer((_) async {});
    when(() => mockCubit.pickPdf()).thenAnswer((_) async {});
    when(() => mockCubit.pickImage(any())).thenAnswer((_) async {});

    final getIt = GetIt.instance;
    if (getIt.isRegistered<HealthRecordCubit>()) {
      getIt.unregister<HealthRecordCubit>();
    }
    getIt.registerLazySingleton<HealthRecordCubit>(() => mockCubit);
  });

  tearDown(() {
    stateController.close();
    GetIt.instance.unregister<HealthRecordCubit>();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: HealthRecordStagingPage(),
    );
  }

  group('HealthRecordStagingPage', () {
    testWidgets('loads records on initialization', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      verify(() => mockCubit.loadRecords()).called(1);
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      when(() => mockCubit.state).thenReturn(HealthRecordLoading());
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders record history when state is loaded', (tester) async {
      final records = [
        MedicalRecord(
          summary: 'Test Record 1',
          type: RecordType.clinicalNote,
          date: DateTime(2023, 1, 1),
        ),
      ];
      when(() => mockCubit.state).thenReturn(HealthRecordLoaded(records));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Record 1'), findsOneWidget);
      expect(find.text('clinicalNote'), findsOneWidget);
    });

    testWidgets('shows empty message when no records', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No hay registros.'), findsOneWidget);
    });

    testWidgets('opens selection modal when FAB is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Subir PDF'), findsOneWidget);
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);
    });

    testWidgets('calls pickPdf when PDF is selected in modal', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Subir PDF'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.pickPdf()).called(1);
    });

    testWidgets('shows form when state is HealthRecordFilePicked', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: 'test.pdf',
        extractedText: 'Extracted text',
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nuevo Registro Médico'), findsOneWidget);
      expect(find.text('Archivo: test.pdf'), findsOneWidget);
      expect(find.text('Extracted text'), findsOneWidget);
    });

    testWidgets('shows success snackbar and reloads when saved', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordLoaded([]));
      await tester.pumpWidget(createWidgetUnderTest());

      stateController.add(HealthRecordSaved());
      await tester.pump();

      expect(find.text('Registro guardado exitosamente'), findsOneWidget);
      verify(() => mockCubit.resetAndLoad()).called(1);
    });

    testWidgets('shows error snackbar on error', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordLoaded([]));
      await tester.pumpWidget(createWidgetUnderTest());

      stateController.add(const HealthRecordError('Operation failed'));
      await tester.pump();

      expect(find.text('Error: Operation failed'), findsOneWidget);
    });
  });
}
