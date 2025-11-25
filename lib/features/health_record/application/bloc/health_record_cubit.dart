import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/medical_attachment.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../../infrastructure/services/file_picker_service.dart';
import '../../infrastructure/services/image_picker_service.dart';
import '../../infrastructure/services/ocr_service.dart';

part 'health_record_state.dart';

@injectable
class HealthRecordCubit extends Cubit<HealthRecordState> {
  final HealthRecordRepository _repository;
  final FilePickerService _filePickerService;
  final ImagePickerService _imagePickerService;
  final OcrService _ocrService;

  HealthRecordCubit(
    this._repository,
    this._filePickerService,
    this._imagePickerService,
    this._ocrService,
  ) : super(HealthRecordInitial());

  Future<void> pickPdf() async {
    emit(HealthRecordLoading());
    try {
      final path = await _filePickerService.pickPdf();
      if (path != null) {
        final text = await _ocrService.extractText(path);
        emit(HealthRecordFilePicked(filePath: path, extractedText: text));
      } else {
        emit(HealthRecordInitial());
      }
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  Future<void> pickImage(bool fromCamera) async {
    emit(HealthRecordLoading());
    try {
      final path = fromCamera
          ? await _imagePickerService.pickImageFromCamera()
          : await _imagePickerService.pickImageFromGallery();

      if (path != null) {
        final text = await _ocrService.extractText(path);
        emit(HealthRecordFilePicked(filePath: path, extractedText: text));
      } else {
        emit(HealthRecordInitial());
      }
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  Future<void> saveRecord({
    required String filePath,
    required String extractedText,
    required String summary,
    required RecordType type,
    required DateTime date,
  }) async {
    emit(HealthRecordLoading());
    try {
      final attachment = MedicalAttachment(
        localPath: filePath,
        extractedText: extractedText,
        mimeType: filePath.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
      );

      final record = MedicalRecord(
        date: date,
        type: type,
        summary: summary,
        attachments: [attachment],
      );

      await _repository.saveRecord(record);
      emit(HealthRecordSaved());
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  void reset() {
    emit(HealthRecordInitial());
  }
}
