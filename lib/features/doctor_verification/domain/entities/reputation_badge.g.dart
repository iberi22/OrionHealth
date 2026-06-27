// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reputation_badge.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReputationBadgeCollection on Isar {
  IsarCollection<ReputationBadge> get reputationBadges => this.collection();
}

const ReputationBadgeSchema = CollectionSchema(
  name: r'ReputationBadge',
  id: 238167590572308637,
  properties: {
    r'criteria': PropertySchema(
      id: 0,
      name: r'criteria',
      type: IsarType.string,
    ),
    r'doctorId': PropertySchema(
      id: 1,
      name: r'doctorId',
      type: IsarType.string,
    ),
    r'earnedDate': PropertySchema(
      id: 2,
      name: r'earnedDate',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 3,
      name: r'id',
      type: IsarType.string,
    ),
    r'level': PropertySchema(
      id: 4,
      name: r'level',
      type: IsarType.byte,
      enumMap: _ReputationBadgelevelEnumValueMap,
    )
  },
  estimateSize: _reputationBadgeEstimateSize,
  serialize: _reputationBadgeSerialize,
  deserialize: _reputationBadgeDeserialize,
  deserializeProp: _reputationBadgeDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _reputationBadgeGetId,
  getLinks: _reputationBadgeGetLinks,
  attach: _reputationBadgeAttach,
  version: '3.1.0+1',
);

int _reputationBadgeEstimateSize(
  ReputationBadge object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.criteria.length * 3;
  bytesCount += 3 + object.doctorId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _reputationBadgeSerialize(
  ReputationBadge object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.criteria);
  writer.writeString(offsets[1], object.doctorId);
  writer.writeDateTime(offsets[2], object.earnedDate);
  writer.writeString(offsets[3], object.id);
  writer.writeByte(offsets[4], object.level.index);
}

ReputationBadge _reputationBadgeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReputationBadge(
    criteria: reader.readString(offsets[0]),
    doctorId: reader.readString(offsets[1]),
    earnedDate: reader.readDateTime(offsets[2]),
    id: reader.readString(offsets[3]),
    level:
        _ReputationBadgelevelValueEnumMap[reader.readByteOrNull(offsets[4])] ??
            BadgeLevel.bronze,
  );
  object.isarId = id;
  return object;
}

P _reputationBadgeDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_ReputationBadgelevelValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BadgeLevel.bronze) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ReputationBadgelevelEnumValueMap = {
  'bronze': 0,
  'silver': 1,
  'gold': 2,
  'platinum': 3,
};
const _ReputationBadgelevelValueEnumMap = {
  0: BadgeLevel.bronze,
  1: BadgeLevel.silver,
  2: BadgeLevel.gold,
  3: BadgeLevel.platinum,
};

Id _reputationBadgeGetId(ReputationBadge object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _reputationBadgeGetLinks(ReputationBadge object) {
  return [];
}

void _reputationBadgeAttach(
    IsarCollection<dynamic> col, Id id, ReputationBadge object) {
  object.isarId = id;
}

extension ReputationBadgeQueryWhereSort
    on QueryBuilder<ReputationBadge, ReputationBadge, QWhere> {
  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReputationBadgeQueryWhere
    on QueryBuilder<ReputationBadge, ReputationBadge, QWhereClause> {
  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReputationBadgeQueryFilter
    on QueryBuilder<ReputationBadge, ReputationBadge, QFilterCondition> {
  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criteria',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'criteria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'criteria',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criteria',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      criteriaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'criteria',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doctorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'doctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'doctorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doctorId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      doctorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'doctorId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      earnedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'earnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      earnedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'earnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      earnedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'earnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      earnedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'earnedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      levelEqualTo(BadgeLevel value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      levelGreaterThan(
    BadgeLevel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      levelLessThan(
    BadgeLevel value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterFilterCondition>
      levelBetween(
    BadgeLevel lower,
    BadgeLevel upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReputationBadgeQueryObject
    on QueryBuilder<ReputationBadge, ReputationBadge, QFilterCondition> {}

extension ReputationBadgeQueryLinks
    on QueryBuilder<ReputationBadge, ReputationBadge, QFilterCondition> {}

extension ReputationBadgeQuerySortBy
    on QueryBuilder<ReputationBadge, ReputationBadge, QSortBy> {
  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByCriteria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criteria', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByCriteriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criteria', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorId', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorId', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByEarnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedDate', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByEarnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedDate', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }
}

extension ReputationBadgeQuerySortThenBy
    on QueryBuilder<ReputationBadge, ReputationBadge, QSortThenBy> {
  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByCriteria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criteria', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByCriteriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criteria', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorId', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doctorId', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByEarnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedDate', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByEarnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earnedDate', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QAfterSortBy>
      thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }
}

extension ReputationBadgeQueryWhereDistinct
    on QueryBuilder<ReputationBadge, ReputationBadge, QDistinct> {
  QueryBuilder<ReputationBadge, ReputationBadge, QDistinct> distinctByCriteria(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criteria', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QDistinct> distinctByDoctorId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doctorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QDistinct>
      distinctByEarnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earnedDate');
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReputationBadge, ReputationBadge, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }
}

extension ReputationBadgeQueryProperty
    on QueryBuilder<ReputationBadge, ReputationBadge, QQueryProperty> {
  QueryBuilder<ReputationBadge, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ReputationBadge, String, QQueryOperations> criteriaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criteria');
    });
  }

  QueryBuilder<ReputationBadge, String, QQueryOperations> doctorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doctorId');
    });
  }

  QueryBuilder<ReputationBadge, DateTime, QQueryOperations>
      earnedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earnedDate');
    });
  }

  QueryBuilder<ReputationBadge, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReputationBadge, BadgeLevel, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }
}
