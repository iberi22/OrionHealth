import '../../domain/entities/medical_code.dart';

class MedicalCodeDto {
  final String code;
  final String displayName;
  final String standard;
  final String category;
  final List<String> searchTerms;

  const MedicalCodeDto({
    required this.code, required this.displayName, required this.standard,
    this.category = '', this.searchTerms = const [],
  });

  factory MedicalCodeDto.fromEntity(MedicalCode e) => MedicalCodeDto(
    code: e.code, displayName: e.displayName, standard: e.standard,
    category: e.category, searchTerms: e.searchTerms,
  );

  Map<String, dynamic> toJson() => {
    'code': code, 'displayName': displayName, 'standard': standard,
    'category': category, 'searchTerms': searchTerms,
  };
}
