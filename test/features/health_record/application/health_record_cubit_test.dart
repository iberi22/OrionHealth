import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/image_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockFilePickerService extends Mock implements FilePickerService {}
class MockImagePickerService extends Mock implements ImagePickerService {}
class MockOcrService extends Mock implements OcrService {}
class MockVectorStoreService extends Mock implements VectorStoreService {}

void main() {
  late HealthRecordCubit cubit;
  late MockHealthRecordRepository mockRepository;
  late MockFilePickerService mockFilePicker;
  late MockImagePickerService mockImagePicker;
  late MockOcrService mockOcrService;
  late MockVectorStoreService mockVectorStore;

  setUpAll(() {
    registerFallbackValue(MedicalRecord(
      date: DateTime.now(),
      type: RecordType.other,
      summary: '',
      attachments: [],
    ));
  });

  setUp(() {
    mockRepository = MockHealthRecordRepository();
    mockFilePicker = MockFilePickerService();
    mockImagePicker = MockImagePickerService();
    mockOcrService = MockOcrService();
    mockVectorStore = MockVectorStoreService();

    cubit = HealthRecordCubit(
      mockRepository,
      mockFilePicker,
      mockImagePicker,
      mockOcrService,
      mockVectorStore,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is HealthRecordInitial', () {
    expect(cubit.state, isA<HealthRecordInitial>());
  });

  group('loadRecords', () {
    test('resetAndLoad calls loadRecords', () async {
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => []);

      await cubit.resetAndLoad();

      verify(() => mockRepository.getAllRecords()).called(1);
    });

    test('emits [Loading, Loaded] when repository returns records', () async {
      final records = [
        MedicalRecord(type: RecordType.labResult, summary: 'Test record'),
      ];
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => records);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          HealthRecordLoaded(records),
        ]),
      );

      await cubit.loadRecords();
      await expectation;
    });

    test('emits [Loading, Error] when repository throws', () async {
      when(() => mockRepository.getAllRecords()).thenThrow(Exception('DB error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordError>(),
        ]),
      );

      await cubit.loadRecords();
      await expectation;

      final state = cubit.state as HealthRecordError;
      expect(state.message, contains('DB error'));
    });
  });

  group('pickPdf', () {
    test('emits [Loading, FilePicked] when file is picked and OCR succeeds', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => 'test.pdf');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'Extracted text');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          const HealthRecordFilePicked(filePath: 'test.pdf', extractedText: 'Extracted text'),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });

    test('emits [Loading, Initial] when file picking is cancelled', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => null);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordInitial>(),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });

    test('emits [Loading, Error] when OCR fails', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => 'test.pdf');
      when(() => mockOcrService.extractText(any())).thenThrow(Exception('OCR failed'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordError>(),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });
  });

  group('pickImage', () {
    test('emits [Loading, FilePicked] when image is picked from camera', () async {
      when(() => mockImagePicker.pickImageFromCamera()).thenAnswer((_) async => 'camera.jpg');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'Text from camera');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          const HealthRecordFilePicked(filePath: 'camera.jpg', extractedText: 'Text from camera'),
        ]),
      );

      await cubit.pickImage(true);
      await expectation;
    });

    test('emits [Loading, FilePicked] when image is picked from gallery', () async {
      when(() => mockImagePicker.pickImageFromGallery()).thenAnswer((_) async => 'gallery.jpg');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'Text from gallery');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          const HealthRecordFilePicked(filePath: 'gallery.jpg', extractedText: 'Text from gallery'),
        ]),
      );

      await cubit.pickImage(false);
      await expectation;
    });

    test('emits [Loading, Initial] when image picking is cancelled', () async {
      when(() => mockImagePicker.pickImageFromCamera()).thenAnswer((_) async => null);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordInitial>(),
        ]),
      );

      await cubit.pickImage(true);
      await expectation;
    });
  });

  group('saveRecord', () {
    final testDate = DateTime(2025, 1, 1);

    test('emits [Loading, Saved] when repository succeeds for .pdf', () async {
      when(() => mockRepository.saveRecord(any())).thenAnswer((_) async => {});

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordSaved>(),
        ]),
      );

      await cubit.saveRecord(
        filePath: 'test.pdf',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: testDate,
      );
      await expectation;

      final captured = verify(() => mockRepository.saveRecord(captureAny())).captured.single as MedicalRecord;
      expect(captured.attachments.first.mimeType, 'application/pdf');
    });

    test('emits [Loading, Saved] when repository succeeds for .jpg', () async {
      when(() => mockRepository.saveRecord(any())).thenAnswer((_) async => {});

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordSaved>(),
        ]),
      );

      await cubit.saveRecord(
        filePath: 'test.jpg',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: testDate,
      );
      await expectation;

      final captured = verify(() => mockRepository.saveRecord(captureAny())).captured.single as MedicalRecord;
      expect(captured.attachments.first.mimeType, 'image/jpeg');
    });

    test('emits [Loading, Error] when repository fails', () async {
      when(() => mockRepository.saveRecord(any())).thenThrow(Exception('Save failed'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          isA<HealthRecordError>(),
        ]),
      );

      await cubit.saveRecord(
        filePath: 'test.pdf',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: testDate,
      );
      await expectation;
    });
  });

  group('Recovery Scenarios', () {
    test('can load records after a failed save', () async {
      // 1. Fail a save
      when(() => mockRepository.saveRecord(any())).thenThrow(Exception('Save failed'));
      await cubit.saveRecord(
        filePath: 'test.pdf',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: DateTime.now(),
      );
      expect(cubit.state, isA<HealthRecordError>());

      // 2. Try to load records - should succeed and emit [Loading, Loaded]
      final records = [MedicalRecord(summary: 'Existing')];
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => records);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HealthRecordLoading>(),
          HealthRecordLoaded(records),
        ]),
      );

      await cubit.loadRecords();
      await expectation;
      expect(cubit.state, isA<HealthRecordLoaded>());
    });

    test('reset() returns to initial state from error', () async {
      when(() => mockRepository.getAllRecords()).thenThrow(Exception('Fail'));
      await cubit.loadRecords();
      expect(cubit.state, isA<HealthRecordError>());

      cubit.reset();
      expect(cubit.state, isA<HealthRecordInitial>());
    });

    test('reset() returns to initial state from Loaded', () async {
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => []);
      await cubit.loadRecords();
      expect(cubit.state, isA<HealthRecordLoaded>());

      cubit.reset();
      expect(cubit.state, isA<HealthRecordInitial>());
    });
  });
}
