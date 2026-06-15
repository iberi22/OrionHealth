import '../../domain/entities/credential_schema.dart';

class CredentialSchemaDto {
  final String id;
  final String name;
  final String version;
  final Map<String, dynamic> attributes;

  const CredentialSchemaDto({
    required this.id, required this.name, required this.version,
    required this.attributes,
  });

  factory CredentialSchemaDto.fromEntity(CredentialSchema e) => CredentialSchemaDto(
    id: e.id, name: e.name, version: e.version, attributes: e.attributes,
  );

  CredentialSchema toEntity() => CredentialSchema(
    id: id, name: name, version: version, attributes: attributes,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'version': version, 'attributes': attributes,
  };

  factory CredentialSchemaDto.fromJson(Map<String, dynamic> j) => CredentialSchemaDto(
    id: j['id'] as String, name: j['name'] as String, version: j['version'] as String,
    attributes: Map<String, dynamic>.from(j['attributes'] as Map),
  );
}
