// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLabResultCollection on Isar {
  IsarCollection<LabResult> get labResults => this.collection();
}

const LabResultSchema = CollectionSchema(
  name: r'LabResult',
  id: 1313281372476420437,
  properties: {
    r'collectedAt': PropertySchema(
      id: 0,
      name: r'collectedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'encryptedValue': PropertySchema(
      id: 2,
      name: r'encryptedValue',
      type: IsarType.string,
    ),
    r'isAbnormal': PropertySchema(
      id: 3,
      name: r'isAbnormal',
      type: IsarType.bool,
    ),
    r'isSensitive': PropertySchema(
      id: 4,
      name: r'isSensitive',
      type: IsarType.bool,
    ),
    r'loincCode': PropertySchema(
      id: 5,
      name: r'loincCode',
      type: IsarType.string,
    ),
    r'referenceRangeHigh': PropertySchema(
      id: 6,
      name: r'referenceRangeHigh',
      type: IsarType.double,
    ),
    r'referenceRangeLow': PropertySchema(
      id: 7,
      name: r'referenceRangeLow',
      type: IsarType.double,
    ),
    r'remoteId': PropertySchema(
      id: 8,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'resultValue': PropertySchema(
      id: 9,
      name: r'resultValue',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 10,
      name: r'source',
      type: IsarType.string,
      enumMap: _LabResultsourceEnumValueMap,
    ),
    r'syncStatus': PropertySchema(
      id: 11,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _LabResultsyncStatusEnumValueMap,
    ),
    r'testName': PropertySchema(
      id: 12,
      name: r'testName',
      type: IsarType.string,
    ),
    r'unit': PropertySchema(
      id: 13,
      name: r'unit',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _labResultEstimateSize,
  serialize: _labResultSerialize,
  deserialize: _labResultDeserialize,
  deserializeProp: _labResultDeserializeProp,
  idName: r'id',
  indexes: {
    r'loincCode': IndexSchema(
      id: 8326644141241462849,
      name: r'loincCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'loincCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'collectedAt': IndexSchema(
      id: -5519599978623615390,
      name: r'collectedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'collectedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _labResultGetId,
  getLinks: _labResultGetLinks,
  attach: _labResultAttach,
  version: '3.1.0+1',
);

int _labResultEstimateSize(
  LabResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.encryptedValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.loincCode.length * 3;
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.resultValue.length * 3;
  bytesCount += 3 + object.source.name.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  bytesCount += 3 + object.testName.length * 3;
  bytesCount += 3 + object.unit.length * 3;
  return bytesCount;
}

void _labResultSerialize(
  LabResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.collectedAt);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.encryptedValue);
  writer.writeBool(offsets[3], object.isAbnormal);
  writer.writeBool(offsets[4], object.isSensitive);
  writer.writeString(offsets[5], object.loincCode);
  writer.writeDouble(offsets[6], object.referenceRangeHigh);
  writer.writeDouble(offsets[7], object.referenceRangeLow);
  writer.writeString(offsets[8], object.remoteId);
  writer.writeString(offsets[9], object.resultValue);
  writer.writeString(offsets[10], object.source.name);
  writer.writeString(offsets[11], object.syncStatus.name);
  writer.writeString(offsets[12], object.testName);
  writer.writeString(offsets[13], object.unit);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

LabResult _labResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LabResult(
    collectedAt: reader.readDateTime(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    encryptedValue: reader.readStringOrNull(offsets[2]),
    id: id,
    loincCode: reader.readString(offsets[5]),
    referenceRangeHigh: reader.readDouble(offsets[6]),
    referenceRangeLow: reader.readDouble(offsets[7]),
    remoteId: reader.readString(offsets[8]),
    resultValue: reader.readString(offsets[9]),
    source:
        _LabResultsourceValueEnumMap[reader.readStringOrNull(offsets[10])] ??
            DataSource.manual,
    syncStatus: _LabResultsyncStatusValueEnumMap[
            reader.readStringOrNull(offsets[11])] ??
        SyncStatus.pending,
    testName: reader.readString(offsets[12]),
    unit: reader.readString(offsets[13]),
    updatedAt: reader.readDateTime(offsets[14]),
  );
  return object;
}

P _labResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (_LabResultsourceValueEnumMap[reader.readStringOrNull(offset)] ??
          DataSource.manual) as P;
    case 11:
      return (_LabResultsyncStatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LabResultsourceEnumValueMap = {
  r'manual': r'manual',
  r'external': r'external',
  r'device': r'device',
};
const _LabResultsourceValueEnumMap = {
  r'manual': DataSource.manual,
  r'external': DataSource.external,
  r'device': DataSource.device,
};
const _LabResultsyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pending': r'pending',
  r'conflict': r'conflict',
};
const _LabResultsyncStatusValueEnumMap = {
  r'synced': SyncStatus.synced,
  r'pending': SyncStatus.pending,
  r'conflict': SyncStatus.conflict,
};

Id _labResultGetId(LabResult object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _labResultGetLinks(LabResult object) {
  return [];
}

void _labResultAttach(IsarCollection<dynamic> col, Id id, LabResult object) {
  object.id = id;
}

extension LabResultQueryWhereSort
    on QueryBuilder<LabResult, LabResult, QWhere> {
  QueryBuilder<LabResult, LabResult, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhere> anyCollectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'collectedAt'),
      );
    });
  }
}

extension LabResultQueryWhere
    on QueryBuilder<LabResult, LabResult, QWhereClause> {
  QueryBuilder<LabResult, LabResult, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> idBetween(
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

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> loincCodeEqualTo(
      String loincCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'loincCode',
        value: [loincCode],
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> loincCodeNotEqualTo(
      String loincCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loincCode',
              lower: [],
              upper: [loincCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loincCode',
              lower: [loincCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loincCode',
              lower: [loincCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'loincCode',
              lower: [],
              upper: [loincCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> collectedAtEqualTo(
      DateTime collectedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'collectedAt',
        value: [collectedAt],
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> collectedAtNotEqualTo(
      DateTime collectedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectedAt',
              lower: [],
              upper: [collectedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectedAt',
              lower: [collectedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectedAt',
              lower: [collectedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'collectedAt',
              lower: [],
              upper: [collectedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> collectedAtGreaterThan(
    DateTime collectedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectedAt',
        lower: [collectedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> collectedAtLessThan(
    DateTime collectedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectedAt',
        lower: [],
        upper: [collectedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> collectedAtBetween(
    DateTime lowerCollectedAt,
    DateTime upperCollectedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'collectedAt',
        lower: [lowerCollectedAt],
        includeLower: includeLower,
        upper: [upperCollectedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> syncStatusEqualTo(
      SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterWhereClause> syncStatusNotEqualTo(
      SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LabResultQueryFilter
    on QueryBuilder<LabResult, LabResult, QFilterCondition> {
  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> collectedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      collectedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> collectedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> collectedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'encryptedValue',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'encryptedValue',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedValue',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      encryptedValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedValue',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> isAbnormalEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAbnormal',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> isSensitiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSensitive',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      loincCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loincCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loincCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loincCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> loincCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loincCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      loincCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loincCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeHighEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceRangeHigh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeHighGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceRangeHigh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeHighLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceRangeHigh',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeHighBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceRangeHigh',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeLowEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceRangeLow',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeLowGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceRangeLow',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeLowLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceRangeLow',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      referenceRangeLowBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceRangeLow',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      resultValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resultValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      resultValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> resultValueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resultValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      resultValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultValue',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      resultValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resultValue',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceEqualTo(
    DataSource value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceGreaterThan(
    DataSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceLessThan(
    DataSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceBetween(
    DataSource lower,
    DataSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusEqualTo(
    SyncStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      syncStatusGreaterThan(
    SyncStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusLessThan(
    SyncStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusBetween(
    SyncStatus lower,
    SyncStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> syncStatusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'testName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> testNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testName',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      testNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'testName',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LabResultQueryObject
    on QueryBuilder<LabResult, LabResult, QFilterCondition> {}

extension LabResultQueryLinks
    on QueryBuilder<LabResult, LabResult, QFilterCondition> {}

extension LabResultQuerySortBy on QueryBuilder<LabResult, LabResult, QSortBy> {
  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByCollectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByCollectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedAt', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByEncryptedValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedValue', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByEncryptedValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedValue', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByIsAbnormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByIsSensitiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByLoincCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loincCode', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByLoincCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loincCode', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByReferenceRangeHigh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeHigh', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy>
      sortByReferenceRangeHighDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeHigh', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByReferenceRangeLow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeLow', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy>
      sortByReferenceRangeLowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeLow', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByResultValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultValue', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByResultValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultValue', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByTestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByTestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LabResultQuerySortThenBy
    on QueryBuilder<LabResult, LabResult, QSortThenBy> {
  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByCollectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByCollectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedAt', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByEncryptedValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedValue', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByEncryptedValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedValue', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByIsAbnormalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAbnormal', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByIsSensitiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSensitive', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByLoincCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loincCode', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByLoincCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loincCode', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByReferenceRangeHigh() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeHigh', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy>
      thenByReferenceRangeHighDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeHigh', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByReferenceRangeLow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeLow', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy>
      thenByReferenceRangeLowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceRangeLow', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByResultValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultValue', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByResultValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultValue', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByTestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByTestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LabResult, LabResult, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LabResultQueryWhereDistinct
    on QueryBuilder<LabResult, LabResult, QDistinct> {
  QueryBuilder<LabResult, LabResult, QDistinct> distinctByCollectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectedAt');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByEncryptedValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedValue',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByIsAbnormal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAbnormal');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByIsSensitive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSensitive');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByLoincCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loincCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByReferenceRangeHigh() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceRangeHigh');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByReferenceRangeLow() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceRangeLow');
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByResultValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByTestName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LabResult, LabResult, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LabResultQueryProperty
    on QueryBuilder<LabResult, LabResult, QQueryProperty> {
  QueryBuilder<LabResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LabResult, DateTime, QQueryOperations> collectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectedAt');
    });
  }

  QueryBuilder<LabResult, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LabResult, String?, QQueryOperations> encryptedValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedValue');
    });
  }

  QueryBuilder<LabResult, bool, QQueryOperations> isAbnormalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAbnormal');
    });
  }

  QueryBuilder<LabResult, bool, QQueryOperations> isSensitiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSensitive');
    });
  }

  QueryBuilder<LabResult, String, QQueryOperations> loincCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loincCode');
    });
  }

  QueryBuilder<LabResult, double, QQueryOperations>
      referenceRangeHighProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceRangeHigh');
    });
  }

  QueryBuilder<LabResult, double, QQueryOperations>
      referenceRangeLowProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceRangeLow');
    });
  }

  QueryBuilder<LabResult, String, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<LabResult, String, QQueryOperations> resultValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultValue');
    });
  }

  QueryBuilder<LabResult, DataSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<LabResult, SyncStatus, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<LabResult, String, QQueryOperations> testNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testName');
    });
  }

  QueryBuilder<LabResult, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<LabResult, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabResult _$LabResultFromJson(Map<String, dynamic> json) => LabResult(
      id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
      remoteId: json['remoteId'] as String,
      loincCode: json['loincCode'] as String,
      testName: json['testName'] as String,
      resultValue: json['resultValue'] as String,
      unit: json['unit'] as String,
      referenceRangeLow: (json['referenceRangeLow'] as num).toDouble(),
      referenceRangeHigh: (json['referenceRangeHigh'] as num).toDouble(),
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      source: $enumDecodeNullable(_$DataSourceEnumMap, json['source']) ??
          DataSource.manual,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      encryptedValue: json['encryptedValue'] as String?,
    );

Map<String, dynamic> _$LabResultToJson(LabResult instance) => <String, dynamic>{
      'id': instance.id,
      'remoteId': instance.remoteId,
      'loincCode': instance.loincCode,
      'testName': instance.testName,
      'resultValue': instance.resultValue,
      'unit': instance.unit,
      'referenceRangeLow': instance.referenceRangeLow,
      'referenceRangeHigh': instance.referenceRangeHigh,
      'collectedAt': instance.collectedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'source': _$DataSourceEnumMap[instance.source]!,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'encryptedValue': instance.encryptedValue,
    };

const _$DataSourceEnumMap = {
  DataSource.manual: 'manual',
  DataSource.external: 'external',
  DataSource.device: 'device',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.conflict: 'conflict',
};
