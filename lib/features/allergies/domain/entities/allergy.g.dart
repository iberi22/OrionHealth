// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergy.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAllergyCollection on Isar {
  IsarCollection<Allergy> get allergys => this.collection();
}

const AllergySchema = CollectionSchema(
  name: r'Allergy',
  id: -6029403542999152803,
  properties: {
    r'confirmedDate': PropertySchema(
      id: 0,
      name: r'confirmedDate',
      type: IsarType.dateTime,
    ),
    r'isCritical': PropertySchema(
      id: 1,
      name: r'isCritical',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'reaction': PropertySchema(
      id: 4,
      name: r'reaction',
      type: IsarType.string,
    ),
    r'severity': PropertySchema(
      id: 5,
      name: r'severity',
      type: IsarType.byte,
      enumMap: _AllergyseverityEnumValueMap,
    )
  },
  estimateSize: _allergyEstimateSize,
  serialize: _allergySerialize,
  deserialize: _allergyDeserialize,
  deserializeProp: _allergyDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _allergyGetId,
  getLinks: _allergyGetLinks,
  attach: _allergyAttach,
  version: '3.1.0+1',
);

int _allergyEstimateSize(
  Allergy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reaction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _allergySerialize(
  Allergy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.confirmedDate);
  writer.writeBool(offsets[1], object.isCritical);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.notes);
  writer.writeString(offsets[4], object.reaction);
  writer.writeByte(offsets[5], object.severity.index);
}

Allergy _allergyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Allergy(
    confirmedDate: reader.readDateTimeOrNull(offsets[0]),
    isCritical: reader.readBoolOrNull(offsets[1]) ?? false,
    name: reader.readStringOrNull(offsets[2]),
    notes: reader.readStringOrNull(offsets[3]),
    reaction: reader.readStringOrNull(offsets[4]),
    severity: _AllergyseverityValueEnumMap[reader.readByteOrNull(offsets[5])] ??
        AllergySeverity.moderate,
  );
  object.id = id;
  return object;
}

P _allergyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_AllergyseverityValueEnumMap[reader.readByteOrNull(offset)] ??
          AllergySeverity.moderate) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AllergyseverityEnumValueMap = {
  'mild': 0,
  'moderate': 1,
  'severe': 2,
  'lifeThreatening': 3,
};
const _AllergyseverityValueEnumMap = {
  0: AllergySeverity.mild,
  1: AllergySeverity.moderate,
  2: AllergySeverity.severe,
  3: AllergySeverity.lifeThreatening,
};

Id _allergyGetId(Allergy object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _allergyGetLinks(Allergy object) {
  return [];
}

void _allergyAttach(IsarCollection<dynamic> col, Id id, Allergy object) {
  object.id = id;
}

extension AllergyQueryWhereSort on QueryBuilder<Allergy, Allergy, QWhere> {
  QueryBuilder<Allergy, Allergy, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AllergyQueryWhere on QueryBuilder<Allergy, Allergy, QWhereClause> {
  QueryBuilder<Allergy, Allergy, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Allergy, Allergy, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterWhereClause> idBetween(
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
}

extension AllergyQueryFilter
    on QueryBuilder<Allergy, Allergy, QFilterCondition> {
  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> confirmedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'confirmedDate',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition>
      confirmedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'confirmedDate',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> confirmedDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition>
      confirmedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> confirmedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confirmedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> confirmedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confirmedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> isCriticalEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCritical',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reaction',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reaction',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reaction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reaction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reaction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reaction',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> reactionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reaction',
        value: '',
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> severityEqualTo(
      AllergySeverity value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> severityGreaterThan(
    AllergySeverity value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> severityLessThan(
    AllergySeverity value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterFilterCondition> severityBetween(
    AllergySeverity lower,
    AllergySeverity upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'severity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AllergyQueryObject
    on QueryBuilder<Allergy, Allergy, QFilterCondition> {}

extension AllergyQueryLinks
    on QueryBuilder<Allergy, Allergy, QFilterCondition> {}

extension AllergyQuerySortBy on QueryBuilder<Allergy, Allergy, QSortBy> {
  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedDate', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByConfirmedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedDate', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByIsCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCritical', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByIsCriticalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCritical', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByReaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reaction', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortByReactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reaction', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> sortBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }
}

extension AllergyQuerySortThenBy
    on QueryBuilder<Allergy, Allergy, QSortThenBy> {
  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedDate', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByConfirmedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmedDate', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByIsCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCritical', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByIsCriticalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCritical', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByReaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reaction', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenByReactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reaction', Sort.desc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<Allergy, Allergy, QAfterSortBy> thenBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }
}

extension AllergyQueryWhereDistinct
    on QueryBuilder<Allergy, Allergy, QDistinct> {
  QueryBuilder<Allergy, Allergy, QDistinct> distinctByConfirmedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmedDate');
    });
  }

  QueryBuilder<Allergy, Allergy, QDistinct> distinctByIsCritical() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCritical');
    });
  }

  QueryBuilder<Allergy, Allergy, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Allergy, Allergy, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Allergy, Allergy, QDistinct> distinctByReaction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reaction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Allergy, Allergy, QDistinct> distinctBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severity');
    });
  }
}

extension AllergyQueryProperty
    on QueryBuilder<Allergy, Allergy, QQueryProperty> {
  QueryBuilder<Allergy, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Allergy, DateTime?, QQueryOperations> confirmedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmedDate');
    });
  }

  QueryBuilder<Allergy, bool, QQueryOperations> isCriticalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCritical');
    });
  }

  QueryBuilder<Allergy, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Allergy, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Allergy, String?, QQueryOperations> reactionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reaction');
    });
  }

  QueryBuilder<Allergy, AllergySeverity, QQueryOperations> severityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severity');
    });
  }
}
