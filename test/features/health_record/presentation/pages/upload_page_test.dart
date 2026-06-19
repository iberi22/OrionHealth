import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/upload_page.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';

class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockHealthRecordCubit mockCubit;
  late StreamController<HealthRecordState> stateController;

  setUpAll(() {
    registerFallbackValue(RecordType.clinicalNote);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(FakeRoute());
  });

  setUp(() {
    mockCubit = MockHealthRecordCubit();
    stateController = StreamController<HealthRecordState>.broadcast();

    when(() => mockCubit.state).thenReturn(HealthRecordInitial());
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.pickPdf()).thenAnswer((_) async {});
    when(() => mockCubit.pickImage(any())).thenAnswer((_) async {});
    when(() => mockCubit.reset()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<HealthRecordCubit>.value(
        value: mockCubit,
        child: const UploadPage(),
      ),
    );
  }

  group('UploadPage', () {
    testWidgets('renders source selection step when state is initial', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Selecciona el origen'), findsOneWidget);
      expect(find.text('Subir Documento PDF'), findsOneWidget);
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Elegir de la Galería'), findsOneWidget);
    });

    testWidgets('calls pickPdf when PDF option is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Subir Documento PDF'));
      await tester.pump();

      verify(() => mockCubit.pickPdf()).called(1);
    });

    testWidgets('calls pickImage(true) when Take Photo is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Tomar Foto'));
      await tester.pump();

      verify(() => mockCubit.pickImage(true)).called(1);
    });

    testWidgets('calls pickImage(false) when Gallery is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Elegir de la Galería'));
      await tester.pump();

      verify(() => mockCubit.pickImage(false)).called(1);
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      when(() => mockCubit.state).thenReturn(HealthRecordLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Procesando documento...'), findsOneWidget);
    });

    testWidgets('shows details step when file is picked', (tester) async {
      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: 'test/path/report.pdf',
        extractedText: 'Extracted Content',
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Verificar Información'), findsOneWidget);
      expect(find.text('Archivo: report.pdf'), findsOneWidget);
      expect(find.text('Extracted Content'), findsOneWidget);
    });

    testWidgets('validates and saves record in details step', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: 'test/path/report.pdf',
        extractedText: 'Extracted Content',
      ));
      when(() => mockCubit.saveRecord(
        filePath: any(named: 'filePath'),
        extractedText: any(named: 'extractedText'),
        summary: any(named: 'summary'),
        type: any(named: 'type'),
        date: any(named: 'date'),
      )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter summary - it's the first TextFormField
      await tester.enterText(find.byType(TextFormField).first, 'Test Summary');

      await tester.ensureVisible(find.text('GUARDAR REGISTRO'));
      await tester.tap(find.text('GUARDAR REGISTRO'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.saveRecord(
        filePath: 'test/path/report.pdf',
        extractedText: 'Extracted Content',
        summary: 'Test Summary',
        type: any(named: 'type'),
        date: any(named: 'date'),
      )).called(1);
    });

    testWidgets('shows error snackbar when error state is emitted', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      stateController.add(const HealthRecordError('Some error occurred'));
      await tester.pump();

      expect(find.text('Error: Some error occurred'), findsOneWidget);
    });

    testWidgets('shows success snackbar and pops when saved state is emitted', (tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [mockObserver],
        home: BlocProvider<HealthRecordCubit>.value(
          value: mockCubit,
          child: const UploadPage(),
        ),
      ));

      stateController.add(HealthRecordSaved());
      await tester.pump();

      expect(find.text('¡Registro guardado con éxito!'), findsOneWidget);
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
