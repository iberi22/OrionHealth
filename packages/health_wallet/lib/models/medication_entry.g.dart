// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicationEntryCollection on Isar {
  IsarCollection<MedicationEntry> get medicationEntrys => this.collection();
}

const MedicationEntrySchema = CollectionSchema(
  name: r'MedicationEntry',
  id: 112928627332495331,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dosage': PropertySchema(
      id: 1,
      name: r'dosage',
      type: IsarType.string,
    ),
    r'dosageUnit': PropertySchema(
      id: 2,
      name: r'dosageUnit',
      type: IsarType.string,
    ),
    r'encryptedDosage': PropertySchema(
      id: 3,
      name: r'encryptedDosage',
      type: IsarType.string,
    ),
    r'encryptedName': PropertySchema(
      id: 4,
      name: r'encryptedName',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 5,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'frequency': PropertySchema(
      id: 6,
      name: r'frequency',
      type: IsarType.string,
    ),
    r'medicationName': PropertySchema(
      id: 7,
      name: r'medicationName',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 8,
      name: r'notes',
      type: IsarType.string,
    ),
    r'pharmacy': PropertySchema(
      id: 9,
      name: r'pharmacy',
      type: IsarType.string,
    ),
    r'prescribedBy': PropertySchema(
      id: 10,
      name: r'prescribedBy',
      type: IsarType.string,
    ),
    r'refillsRemaining': PropertySchema(
      id: 11,
      name: r'refillsRemaining',
      type: IsarType.long,
    ),
    r'route': PropertySchema(
      id: 12,
      name: r'route',
      type: IsarType.string,
    ),
    r'rxNormCode': PropertySchema(
      id: 13,
      name: r'rxNormCode',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 14,
      name: r'source',
      type: IsarType.string,
      enumMap: _MedicationEntrysourceEnumValueMap,
    ),
    r'startDate': PropertySchema(
      id: 15,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'syncStatus': PropertySchema(
      id: 16,
      name: r'syncStatus',
      type: IsarType.string,
      enumMap: _MedicationEntrysyncStatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _medicationEntryEstimateSize,
  serialize: _medicationEntrySerialize,
  deserialize: _medicationEntryDeserialize,
  deserializeProp: _medicationEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'rxNormCode': IndexSchema(
      id: 3411212710155994789,
      name: r'rxNormCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'rxNormCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'startDate': IndexSchema(
      id: 7723980484494730382,
      name: r'startDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startDate',
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
  getId: _medicationEntryGetId,
  getLinks: _medicationEntryGetLinks,
  attach: _medicationEntryAttach,
  version: '3.1.0+1',
);

int _medicationEntryEstimateSize(
  MedicationEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dosage.length * 3;
  bytesCount += 3 + object.dosageUnit.length * 3;
  {
    final value = object.encryptedDosage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.encryptedName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.frequency.length * 3;
  bytesCount += 3 + object.medicationName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pharmacy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.prescribedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.route.length * 3;
  bytesCount += 3 + object.rxNormCode.length * 3;
  bytesCount += 3 + object.source.name.length * 3;
  bytesCount += 3 + object.syncStatus.name.length * 3;
  return bytesCount;
}

void _medicationEntrySerialize(
  MedicationEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.dosage);
  writer.writeString(offsets[2], object.dosageUnit);
  writer.writeString(offsets[3], object.encryptedDosage);
  writer.writeString(offsets[4], object.encryptedName);
  writer.writeDateTime(offsets[5], object.endDate);
  writer.writeString(offsets[6], object.frequency);
  writer.writeString(offsets[7], object.medicationName);
  writer.writeString(offsets[8], object.notes);
  writer.writeString(offsets[9], object.pharmacy);
  writer.writeString(offsets[10], object.prescribedBy);
  writer.writeLong(offsets[11], object.refillsRemaining);
  writer.writeString(offsets[12], object.route);
  writer.writeString(offsets[13], object.rxNormCode);
  writer.writeString(offsets[14], object.source.name);
  writer.writeDateTime(offsets[15], object.startDate);
  writer.writeString(offsets[16], object.syncStatus.name);
  writer.writeDateTime(offsets[17], object.updatedAt);
}

MedicationEntry _medicationEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicationEntry(
    createdAt: reader.readDateTime(offsets[0]),
    dosage: reader.readString(offsets[1]),
    dosageUnit: reader.readString(offsets[2]),
    encryptedDosage: reader.readStringOrNull(offsets[3]),
    encryptedName: reader.readStringOrNull(offsets[4]),
    endDate: reader.readDateTimeOrNull(offsets[5]),
    frequency: reader.readString(offsets[6]),
    id: id,
    medicationName: reader.readString(offsets[7]),
    notes: reader.readStringOrNull(offsets[8]),
    pharmacy: reader.readStringOrNull(offsets[9]),
    prescribedBy: reader.readStringOrNull(offsets[10]),
    refillsRemaining: reader.readLongOrNull(offsets[11]),
    route: reader.readString(offsets[12]),
    rxNormCode: reader.readString(offsets[13]),
    source: _MedicationEntrysourceValueEnumMap[
            reader.readStringOrNull(offsets[14])] ??
        DataSource.manual,
    startDate: reader.readDateTime(offsets[15]),
    syncStatus: _MedicationEntrysyncStatusValueEnumMap[
            reader.readStringOrNull(offsets[16])] ??
        SyncStatus.pending,
    updatedAt: reader.readDateTime(offsets[17]),
  );
  return object;
}

P _medicationEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (_MedicationEntrysourceValueEnumMap[
              reader.readStringOrNull(offset)] ??
          DataSource.manual) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (_MedicationEntrysyncStatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          SyncStatus.pending) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MedicationEntrysourceEnumValueMap = {
  r'manual': r'manual',
  r'external': r'external',
  r'device': r'device',
};
const _MedicationEntrysourceValueEnumMap = {
  r'manual': DataSource.manual,
  r'external': DataSource.external,
  r'device': DataSource.device,
};
const _MedicationEntrysyncStatusEnumValueMap = {
  r'synced': r'synced',
  r'pending': r'pending',
  r'conflict': r'conflict',
};
const _MedicationEntrysyncStatusValueEnumMap = {
  r'synced': SyncStatus.synced,
  r'pending': SyncStatus.pending,
  r'conflict': SyncStatus.conflict,
};

Id _medicationEntryGetId(MedicationEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _medicationEntryGetLinks(MedicationEntry object) {
  return [];
}

void _medicationEntryAttach(
    IsarCollection<dynamic> col, Id id, MedicationEntry object) {
  object.id = id;
}

extension MedicationEntryQueryWhereSort
    on QueryBuilder<MedicationEntry, MedicationEntry, QWhere> {
  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhere> anyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDate'),
      );
    });
  }
}

extension MedicationEntryQueryWhere
    on QueryBuilder<MedicationEntry, MedicationEntry, QWhereClause> {
  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      rxNormCodeEqualTo(String rxNormCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'rxNormCode',
        value: [rxNormCode],
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      rxNormCodeNotEqualTo(String rxNormCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rxNormCode',
              lower: [],
              upper: [rxNormCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rxNormCode',
              lower: [rxNormCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rxNormCode',
              lower: [rxNormCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rxNormCode',
              lower: [],
              upper: [rxNormCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      startDateEqualTo(DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [startDate],
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      startDateNotEqualTo(DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      startDateGreaterThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [startDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      startDateLessThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [],
        upper: [startDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      startDateBetween(
    DateTime lowerStartDate,
    DateTime upperStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [lowerStartDate],
        includeLower: includeLower,
        upper: [upperStartDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      syncStatusEqualTo(SyncStatus syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterWhereClause>
      syncStatusNotEqualTo(SyncStatus syncStatus) {
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

extension MedicationEntryQueryFilter
    on QueryBuilder<MedicationEntry, MedicationEntry, QFilterCondition> {
  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosageUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosageUnit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosageUnit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosageUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      dosageUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosageUnit',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'encryptedDosage',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'encryptedDosage',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedDosage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedDosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedDosage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedDosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedDosageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedDosage',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'encryptedName',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'encryptedName',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      encryptedNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      frequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      medicationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pharmacy',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pharmacy',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pharmacy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pharmacy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pharmacy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pharmacy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      pharmacyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pharmacy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prescribedBy',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prescribedBy',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prescribedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prescribedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prescribedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prescribedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      prescribedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prescribedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'refillsRemaining',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'refillsRemaining',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refillsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refillsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refillsRemaining',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      refillsRemainingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refillsRemaining',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'route',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'route',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'route',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      routeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'route',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rxNormCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rxNormCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rxNormCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rxNormCode',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      rxNormCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rxNormCode',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceEqualTo(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceGreaterThan(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceLessThan(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceBetween(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceStartsWith(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceEndsWith(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusEqualTo(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusLessThan(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusBetween(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusEndsWith(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterFilterCondition>
      updatedAtBetween(
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

extension MedicationEntryQueryObject
    on QueryBuilder<MedicationEntry, MedicationEntry, QFilterCondition> {}

extension MedicationEntryQueryLinks
    on QueryBuilder<MedicationEntry, MedicationEntry, QFilterCondition> {}

extension MedicationEntryQuerySortBy
    on QueryBuilder<MedicationEntry, MedicationEntry, QSortBy> {
  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> sortByDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByDosageUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByDosageUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByEncryptedDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedDosage', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByEncryptedDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedDosage', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByEncryptedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedName', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByEncryptedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedName', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByMedicationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByMedicationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByPharmacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pharmacy', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByPharmacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pharmacy', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByPrescribedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescribedBy', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByPrescribedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescribedBy', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByRefillsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillsRemaining', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByRefillsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillsRemaining', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> sortByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByRxNormCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rxNormCode', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByRxNormCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rxNormCode', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MedicationEntryQuerySortThenBy
    on QueryBuilder<MedicationEntry, MedicationEntry, QSortThenBy> {
  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenByDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosage', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByDosageUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByDosageUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dosageUnit', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByEncryptedDosage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedDosage', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByEncryptedDosageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedDosage', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByEncryptedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedName', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByEncryptedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedName', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByMedicationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByMedicationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationName', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByPharmacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pharmacy', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByPharmacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pharmacy', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByPrescribedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescribedBy', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByPrescribedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prescribedBy', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByRefillsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillsRemaining', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByRefillsRemainingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refillsRemaining', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenByRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'route', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByRxNormCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rxNormCode', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByRxNormCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rxNormCode', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MedicationEntryQueryWhereDistinct
    on QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> {
  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctByDosage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dosage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByDosageUnit({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dosageUnit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByEncryptedDosage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedDosage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByEncryptedName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctByFrequency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByMedicationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctByPharmacy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pharmacy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByPrescribedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prescribedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByRefillsRemaining() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refillsRemaining');
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctByRoute(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'route', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByRxNormCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rxNormCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicationEntry, MedicationEntry, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MedicationEntryQueryProperty
    on QueryBuilder<MedicationEntry, MedicationEntry, QQueryProperty> {
  QueryBuilder<MedicationEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicationEntry, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations> dosageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dosage');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations> dosageUnitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dosageUnit');
    });
  }

  QueryBuilder<MedicationEntry, String?, QQueryOperations>
      encryptedDosageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedDosage');
    });
  }

  QueryBuilder<MedicationEntry, String?, QQueryOperations>
      encryptedNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedName');
    });
  }

  QueryBuilder<MedicationEntry, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations>
      medicationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationName');
    });
  }

  QueryBuilder<MedicationEntry, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MedicationEntry, String?, QQueryOperations> pharmacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pharmacy');
    });
  }

  QueryBuilder<MedicationEntry, String?, QQueryOperations>
      prescribedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prescribedBy');
    });
  }

  QueryBuilder<MedicationEntry, int?, QQueryOperations>
      refillsRemainingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refillsRemaining');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations> routeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'route');
    });
  }

  QueryBuilder<MedicationEntry, String, QQueryOperations> rxNormCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rxNormCode');
    });
  }

  QueryBuilder<MedicationEntry, DataSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<MedicationEntry, DateTime, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<MedicationEntry, SyncStatus, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<MedicationEntry, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationEntry _$MedicationEntryFromJson(Map<String, dynamic> json) =>
    MedicationEntry(
      id: (json['id'] as num).toInt(),
      rxNormCode: json['rxNormCode'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      dosageUnit: json['dosageUnit'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      prescribedBy: json['prescribedBy'] as String?,
      pharmacy: json['pharmacy'] as String?,
      refillsRemaining: (json['refillsRemaining'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      source: $enumDecodeNullable(_$DataSourceEnumMap, json['source']) ??
          DataSource.manual,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      encryptedName: json['encryptedName'] as String?,
      encryptedDosage: json['encryptedDosage'] as String?,
    );

Map<String, dynamic> _$MedicationEntryToJson(MedicationEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rxNormCode': instance.rxNormCode,
      'medicationName': instance.medicationName,
      'dosage': instance.dosage,
      'dosageUnit': instance.dosageUnit,
      'frequency': instance.frequency,
      'route': instance.route,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'prescribedBy': instance.prescribedBy,
      'pharmacy': instance.pharmacy,
      'refillsRemaining': instance.refillsRemaining,
      'notes': instance.notes,
      'source': _$DataSourceEnumMap[instance.source]!,
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'encryptedName': instance.encryptedName,
      'encryptedDosage': instance.encryptedDosage,
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
