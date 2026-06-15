import 'dart:convert';

class IsarDidDto {
  // These fields match the Isar collection in infrastructure/persistence/
  String did = '';
  String shortForm = '';
  String longForm = '';
  DateTime createdAt = DateTime.now();
  bool isAnchored = false;
  String keyType = '';
  String? didDocumentJson;
}

class IsarCredentialDto {
  String credentialId = '';
  String issuer = '';
  String subject = '';
  String type = '';
  String schemaId = '';
  String claimsJson = '{}';
  DateTime issuanceDate = DateTime.now();
  DateTime? expirationDate;
  String proof = '';
  bool isRevoked = false;
}

class IsarRevocationEntryDto {
  String credentialId = '';
  String issuerPublicKey = '';
  int credentialIndex = 0;
  DateTime revokedAt = DateTime.now();
  String issuerSignature = '';
}
