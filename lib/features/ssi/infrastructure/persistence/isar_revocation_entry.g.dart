// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_revocation_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarRevocationEntryCollection on Isar {
  IsarCollection<IsarRevocationEntry> get isarRevocationEntrys =>
      this.collection();
}

const IsarRevocationEntrySchema = CollectionSchema(
  name: r'IsarRevocationEntry',
  id: -8841516020411823533,
  properties: {
    r'credentialId': PropertySchema(
      id: 0,
      name: r'credentialId',
      type: IsarType.string,
    ),
    r'credentialIndex': PropertySchema(
      id: 1,
      name: r'credentialIndex',
      type: IsarType.long,
    ),
    r'issuerPublicKey': PropertySchema(
      id: 2,
      name: r'issuerPublicKey',
      type: IsarType.string,
    ),
    r'issuerSignature': PropertySchema(
      id: 3,
      name: r'issuerSignature',
      type: IsarType.string,
    ),
    r'revokedAt': PropertySchema(
      id: 4,
      name: r'revokedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _isarRevocationEntryEstimateSize,
  serialize: _isarRevocationEntrySerialize,
  deserialize: _isarRevocationEntryDeserialize,
  deserializeProp: _isarRevocationEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'credentialId': IndexSchema(
      id: 7147664887779844858,
      name: r'credentialId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'credentialId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'issuerPublicKey': IndexSchema(
      id: -680250230579890628,
      name: r'issuerPublicKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'issuerPublicKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'credentialIndex': IndexSchema(
      id: 182462548740310685,
      name: r'credentialIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'credentialIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarRevocationEntryGetId,
  getLinks: _isarRevocationEntryGetLinks,
  attach: _isarRevocationEntryAttach,
  version: '3.1.0+1',
);

int _isarRevocationEntryEstimateSize(
  IsarRevocationEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.credentialId.length * 3;
  bytesCount += 3 + object.issuerPublicKey.length * 3;
  bytesCount += 3 + object.issuerSignature.length * 3;
  return bytesCount;
}

void _isarRevocationEntrySerialize(
  IsarRevocationEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.credentialId);
  writer.writeLong(offsets[1], object.credentialIndex);
  writer.writeString(offsets[2], object.issuerPublicKey);
  writer.writeString(offsets[3], object.issuerSignature);
  writer.writeDateTime(offsets[4], object.revokedAt);
}

IsarRevocationEntry _isarRevocationEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarRevocationEntry();
  object.credentialId = reader.readString(offsets[0]);
  object.credentialIndex = reader.readLong(offsets[1]);
  object.id = id;
  object.issuerPublicKey = reader.readString(offsets[2]);
  object.issuerSignature = reader.readString(offsets[3]);
  object.revokedAt = reader.readDateTime(offsets[4]);
  return object;
}

P _isarRevocationEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarRevocationEntryGetId(IsarRevocationEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarRevocationEntryGetLinks(
    IsarRevocationEntry object) {
  return [];
}

void _isarRevocationEntryAttach(
    IsarCollection<dynamic> col, Id id, IsarRevocationEntry object) {
  object.id = id;
}

extension IsarRevocationEntryQueryWhereSort
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QWhere> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhere>
      anyCredentialIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'credentialIndex'),
      );
    });
  }
}

extension IsarRevocationEntryQueryWhere
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QWhereClause> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIdEqualTo(String credentialId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'credentialId',
        value: [credentialId],
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      issuerPublicKeyEqualTo(String issuerPublicKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'issuerPublicKey',
        value: [issuerPublicKey],
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      issuerPublicKeyNotEqualTo(String issuerPublicKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'issuerPublicKey',
              lower: [],
              upper: [issuerPublicKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'issuerPublicKey',
              lower: [issuerPublicKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'issuerPublicKey',
              lower: [issuerPublicKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'issuerPublicKey',
              lower: [],
              upper: [issuerPublicKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIndexEqualTo(int credentialIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'credentialIndex',
        value: [credentialIndex],
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIndexNotEqualTo(int credentialIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialIndex',
              lower: [],
              upper: [credentialIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialIndex',
              lower: [credentialIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialIndex',
              lower: [credentialIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'credentialIndex',
              lower: [],
              upper: [credentialIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIndexGreaterThan(
    int credentialIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'credentialIndex',
        lower: [credentialIndex],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIndexLessThan(
    int credentialIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'credentialIndex',
        lower: [],
        upper: [credentialIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterWhereClause>
      credentialIndexBetween(
    int lowerCredentialIndex,
    int upperCredentialIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'credentialIndex',
        lower: [lowerCredentialIndex],
        includeLower: includeLower,
        upper: [upperCredentialIndex],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarRevocationEntryQueryFilter on QueryBuilder<IsarRevocationEntry,
    IsarRevocationEntry, QFilterCondition> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'credentialId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'credentialId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'credentialId',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'credentialIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'credentialIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'credentialIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      credentialIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'credentialIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuerPublicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerPublicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerPublicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuerSignature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuerSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuerSignature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuerSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      issuerSignatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuerSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      revokedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      revokedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      revokedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revokedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterFilterCondition>
      revokedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revokedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarRevocationEntryQueryObject on QueryBuilder<IsarRevocationEntry,
    IsarRevocationEntry, QFilterCondition> {}

extension IsarRevocationEntryQueryLinks on QueryBuilder<IsarRevocationEntry,
    IsarRevocationEntry, QFilterCondition> {}

extension IsarRevocationEntryQuerySortBy
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QSortBy> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByCredentialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByCredentialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByCredentialIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByCredentialIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByIssuerPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerPublicKey', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByIssuerPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerPublicKey', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByIssuerSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignature', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByIssuerSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignature', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      sortByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }
}

extension IsarRevocationEntryQuerySortThenBy
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QSortThenBy> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByCredentialId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByCredentialIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialId', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByCredentialIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialIndex', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByCredentialIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialIndex', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByIssuerPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerPublicKey', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByIssuerPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerPublicKey', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByIssuerSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignature', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByIssuerSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuerSignature', Sort.desc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QAfterSortBy>
      thenByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }
}

extension IsarRevocationEntryQueryWhereDistinct
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct> {
  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct>
      distinctByCredentialId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credentialId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct>
      distinctByCredentialIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'credentialIndex');
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct>
      distinctByIssuerPublicKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerPublicKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct>
      distinctByIssuerSignature({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuerSignature',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QDistinct>
      distinctByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revokedAt');
    });
  }
}

extension IsarRevocationEntryQueryProperty
    on QueryBuilder<IsarRevocationEntry, IsarRevocationEntry, QQueryProperty> {
  QueryBuilder<IsarRevocationEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarRevocationEntry, String, QQueryOperations>
      credentialIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialId');
    });
  }

  QueryBuilder<IsarRevocationEntry, int, QQueryOperations>
      credentialIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialIndex');
    });
  }

  QueryBuilder<IsarRevocationEntry, String, QQueryOperations>
      issuerPublicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerPublicKey');
    });
  }

  QueryBuilder<IsarRevocationEntry, String, QQueryOperations>
      issuerSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuerSignature');
    });
  }

  QueryBuilder<IsarRevocationEntry, DateTime, QQueryOperations>
      revokedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revokedAt');
    });
  }
}
