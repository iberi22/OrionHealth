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
    expect(cubit.state, const HealthRecordInitial());
  });

  group('loadRecords', () {
    final records = [MedicalRecord(summary: 'Record 1')];

    test('emits [Loading, Loaded] when success', () async {
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => records);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          HealthRecordLoaded(records),
        ]),
      );

      await cubit.loadRecords();
      await expectation;
    });

    test('emits [Loading, Error] when failure', () async {
      when(() => mockRepository.getAllRecords()).thenThrow(Exception('Error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordError('Exception: Error'),
        ]),
      );

      await cubit.loadRecords();
      await expectation;
    });
  });

  group('resetAndLoad', () {
    test('calls loadRecords', () async {
      when(() => mockRepository.getAllRecords()).thenAnswer((_) async => []);

      await cubit.resetAndLoad();

      verify(() => mockRepository.getAllRecords()).called(1);
    });
  });

  group('pickPdf', () {
    test('emits [Loading, FilePicked] when success', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => 'path.pdf');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'text');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordFilePicked(filePath: 'path.pdf', extractedText: 'text'),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });

    test('emits [Loading, Initial] when cancelled', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => null);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordInitial(),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });

    test('emits [Loading, Error] when failure', () async {
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => 'path.pdf');
      when(() => mockOcrService.extractText(any())).thenThrow(Exception('OCR Error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordError('Exception: OCR Error'),
        ]),
      );

      await cubit.pickPdf();
      await expectation;
    });
  });

  group('pickImage', () {
    test('emits [Loading, FilePicked] from camera success', () async {
      when(() => mockImagePicker.pickImageFromCamera()).thenAnswer((_) async => 'camera.jpg');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'text');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordFilePicked(filePath: 'camera.jpg', extractedText: 'text'),
        ]),
      );

      await cubit.pickImage(true);
      await expectation;
    });

    test('emits [Loading, FilePicked] from gallery success', () async {
      when(() => mockImagePicker.pickImageFromGallery()).thenAnswer((_) async => 'gallery.jpg');
      when(() => mockOcrService.extractText(any())).thenAnswer((_) async => 'text');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordFilePicked(filePath: 'gallery.jpg', extractedText: 'text'),
        ]),
      );

      await cubit.pickImage(false);
      await expectation;
    });

    test('emits [Loading, Initial] when cancelled', () async {
      when(() => mockImagePicker.pickImageFromCamera()).thenAnswer((_) async => null);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordInitial(),
        ]),
      );

      await cubit.pickImage(true);
      await expectation;
    });
  });

  group('saveRecord', () {
    final date = DateTime(2025, 1, 1);

    test('emits [Loading, Saved] when success', () async {
      when(() => mockRepository.saveRecord(any())).thenAnswer((_) async => {});

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordSaved(),
        ]),
      );

      await cubit.saveRecord(
        filePath: 'test.pdf',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: date,
      );
      await expectation;
    });

    test('emits [Loading, Error] when failure', () async {
      when(() => mockRepository.saveRecord(any())).thenThrow(Exception('Save Error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          const HealthRecordLoading(),
          const HealthRecordError('Exception: Save Error'),
        ]),
      );

      await cubit.saveRecord(
        filePath: 'test.pdf',
        extractedText: 'text',
        summary: 'summary',
        type: RecordType.labResult,
        date: date,
      );
      await expectation;
    });
  });

  group('reset', () {
    test('emits HealthRecordInitial', () {
      cubit.emit(const HealthRecordError('Error'));

      cubit.reset();

      expect(cubit.state, const HealthRecordInitial());
    });
  });
}
