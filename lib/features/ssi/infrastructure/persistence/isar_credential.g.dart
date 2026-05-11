// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_credential.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarCredentialCollection on Isar {
  IsarCollection<IsarCredential> get isarCredentials => this.collection();
}

const IsarCredentialSchema = CollectionSchema(
  name: r'IsarCredential',
  id: -170141991681670357,
  properties: {
    r'claimsJson': PropertySchema(
      id: 0,
      name: r'claimsJson',
      type: IsarType.string,
    ),
    r'credentialId': PropertySchema(
      id: 1,
      name: r'credentialId',
      type: IsarType.string,
    ),
    r'expirationDate': PropertySchema(
      id: 2,
      name: r'expirationDate',
      type: IsarType.dateTime,
    ),
    r'isRevoked': PropertySchema(
      id: 3,
      name: r'isRevoked',
      type: IsarType.bool,
    ),
    r'issuanceDate': PropertySchema(
      id: 4,
      name: r'issuanceDate',
      type: IsarType.dateTime,
    ),
    r'issuer': PropertySchema(
      id: 5,
      name: r'issuer',
      type: IsarType.string,
    ),
    r'proof': PropertySchema(
      id: 6,
      name: r'proof',
      type: IsarType.string,
    ),
    r'schemaId': PropertySchema(
      id: 7,
      name: r'schemaId',
      type: IsarType.string,
    ),
    r'subject': PropertySchema(
      id: 8,
      name: r'subject',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 9,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _isarCredentialEstimateSize,
  serialize: _isarCredentialSerialize,
  deserialize: _isarCredentialDeserialize,
  deserializeProp: _isarCredentialDeserializeProp,
  idName: r'id',
  indexes: {
    r'credentialId': IndexSchema(
      id: 7147664887779844858,
      name: r'credentialId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'credentialId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarCredentialGetId,
  getLinks: _isarCredentialGetLinks,
  attach: _isarCredentialAttach,
  version: '3.1.0+1',
);

int _isarCredentialEstimateSize(
  IsarCredential object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.claimsJson.length * 3;
  bytesCount += 3 + object.credentialId.length * 3;
  bytesCount += 3 + object.issuer.length * 3;
  {
    final value = object.proof;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schemaId.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _isarCredentialSerialize(
  IsarCredential object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.claimsJson);
  writer.writeString(offsets[1], object.credentialId);
  writer.writeDateTime(offsets[2], object.expirationDate);
  writer.writeBool(offsets[3], object.isRevoked);
  writer.writeDateTime(offsets[4], object.issuanceDate);
  writer.writeString(offsets[5], object.issuer);
  writer.writeString(offsets[6], object.proof);
  writer.writeString(offsets[7], object.schemaId);
  writer.writeString(offsets[8], object.subject);
  writer.writeString(offsets[9], object.type);
}

IsarCredential _isarCredentialDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarCredential();
  object.claimsJson = reader.readString(offsets[0]);
  object.credentialId = reader.readString(offsets[1]);
  object.expirationDate = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.isRevoked = reader.readBool(offsets[3]);
  object.issuanceDate = reader.readDateTime(offsets[4]);
  object.issuer = reader.readString(offsets[5]);
  object.proof = reader.readStringOrNull(offsets[6]);
  object.schemaId = reader.readString(offsets[7]);
  object.subject = reader.readString(offsets[8]);
  object.type = reader.readString(offsets[9]);
  return object;
}

P _isarCredentialDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarCredentialGetId(IsarCredential object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarCredentialGetLinks(IsarCredential object) {
  return [];
}

void _isarCredentialAttach(
    IsarCollection<dynamic> col, Id id, IsarCredential object) {
  object.id = id;
}

extension IsarCredentialByIndex on IsarCollection<IsarCredential> {
  Future<IsarCredential?> getByCredentialId(String credentialId) {
    return getByIndex(r'credentialId', [credentialId]);
  }

  IsarCredential? getByCredentialIdSync(String credentialId) {
    return getByIndexSync(r'credentialId', [credentialId]);
  }

  Future<bool> deleteByCredentialId(String credentialId) {
    return deleteByIndex(r'credentialId', [credentialId]);
  }

  bool deleteByCredentialIdSync(String credentialId) {
    return deleteByIndexSync(r'credentialId', [credentialId]);
  }

  Future<List<IsarCredential?>> getAllByCredentialId(
      List<String> credentialIdValues) {
    final values = credentialIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'credentialId', values);
  }

  List<IsarCredential?> getAllByCredentialIdSync(
      List<String> credentialIdValues) {
    final values = credentialIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'credentialId', values);
  }

  Future<int> deleteAllByCredentialId(List<String> credentialIdValues) {
    final values = credentialIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'credentialId', values);
  }

  int deleteAllByCredentialIdSync(List<String> credentialIdValues) {
    final values = credentialIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'credentialId', values);
  }

  Future<Id> putByCredentialId(IsarCredential object) {
    return putByIndex(r'credentialId', object);
  }

  Id putByCredentialIdSync(IsarCredential object, {bool saveLinks = true}) {
    return putByIndexSync(r'credentialId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCredentialId(List<IsarCredential> objects) {
    return putAllByIndex(r'credentialId', objects);
  }

  List<Id> putAllByCredentialIdSync(List<IsarCredential> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'credentialId', objects, saveLinks: saveLinks);
  }
}

extension IsarCredentialQueryWhereSort
    on QueryBuilder<IsarCredential, IsarCredential, QWhere> {
  QueryBuilder<IsarCredential, IsarCredential, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarCredentialQueryWhere
    on QueryBuilder<IsarCredential, IsarCredential, QWhereClause> {
  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause>
      credentialIdEqualTo(String credentialId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'credentialId',
        value: [credentialId],
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterWhereClause>
      credentialIdNotEqualTo(String credentialId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialId',
              lower: [],
              upper: [credentialId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialId',
              lower: [credentialId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialId',
              lower: [credentialId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialId',
              lower: [],
              upper: [credentialId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarCredentialQueryFilter
    on QueryBuilder<IsarCredential, IsarCredential, QFilterCondition> {
  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'claimsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'claimsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'claimsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claimsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      claimsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'claimsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credentialId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'credentialId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      credentialIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'credentialId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expirationDate',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expirationDate',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expirationDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      expirationDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expirationDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      isRevokedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRevoked',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuanceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuanceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuanceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuanceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuanceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuanceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuer',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      issuerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuer',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proof',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proof',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proof',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proof',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proof',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proof',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      proofIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proof',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schemaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schemaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      schemaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schemaId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension IsarCredentialQueryObject
    on QueryBuilder<IsarCredential, IsarCredential, QFilterCondition> {}

extension IsarCredentialQueryLinks
    on QueryBuilder<IsarCredential, IsarCredential, QFilterCondition> {}

extension IsarCredentialQuerySortBy
    on QueryBuilder<IsarCredential, IsarCredential, QSortBy> {
  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByClaimsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimsJson', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByClaimsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimsJson', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByCredentialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByCredentialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByExpirationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByIsRevoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevoked', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByIsRevokedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevoked', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByIssuanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuanceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByIssuanceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuanceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByIssuer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuer', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortByIssuerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuer', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByProof() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proof', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByProofDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proof', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortBySchemaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortBySchemaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCredentialQuerySortThenBy
    on QueryBuilder<IsarCredential, IsarCredential, QSortThenBy> {
  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByClaimsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimsJson', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByClaimsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claimsJson', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByCredentialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByCredentialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByExpirationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expirationDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByIsRevoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevoked', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByIsRevokedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevoked', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByIssuanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuanceDate', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByIssuanceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuanceDate', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByIssuer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuer', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenByIssuerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuer', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByProof() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proof', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByProofDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proof', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenBySchemaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenBySchemaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaId', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy>
      thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension IsarCredentialQueryWhereDistinct
    on QueryBuilder<IsarCredential, IsarCredential, QDistinct> {
  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctByClaimsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'claimsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct>
      distinctByCredentialId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credentialId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct>
      distinctByExpirationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expirationDate');
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct>
      distinctByIsRevoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRevoked');
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct>
      distinctByIssuanceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuanceDate');
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctByIssuer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctByProof(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proof', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctBySchemaId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarCredential, IsarCredential, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension IsarCredentialQueryProperty
    on QueryBuilder<IsarCredential, IsarCredential, QQueryProperty> {
  QueryBuilder<IsarCredential, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations> claimsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'claimsJson');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations>
      credentialIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialId');
    });
  }

  QueryBuilder<IsarCredential, DateTime?, QQueryOperations>
      expirationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expirationDate');
    });
  }

  QueryBuilder<IsarCredential, bool, QQueryOperations> isRevokedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRevoked');
    });
  }

  QueryBuilder<IsarCredential, DateTime, QQueryOperations>
      issuanceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuanceDate');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations> issuerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuer');
    });
  }

  QueryBuilder<IsarCredential, String?, QQueryOperations> proofProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proof');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations> schemaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaId');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<IsarCredential, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
