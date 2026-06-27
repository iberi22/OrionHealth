// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDoctorProfileCollection on Isar {
  IsarCollection<DoctorProfile> get doctorProfiles => this.collection();
}

const DoctorProfileSchema = CollectionSchema(
  name: r'DoctorProfile',
  id: 1832939599929087735,
  properties: {
    r'countryCode': PropertySchema(
      id: 0,
      name: r'countryCode',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fullName': PropertySchema(
      id: 2,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 3,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'institution': PropertySchema(
      id: 5,
      name: r'institution',
      type: IsarType.string,
    ),
    r'languages': PropertySchema(
      id: 6,
      name: r'languages',
      type: IsarType.stringList,
    ),
    r'licenseNumber': PropertySchema(
      id: 7,
      name: r'licenseNumber',
      type: IsarType.string,
    ),
    r'specialty': PropertySchema(
      id: 8,
      name: r'specialty',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'verified': PropertySchema(
      id: 10,
      name: r'verified',
      type: IsarType.bool,
    ),
    r'yearsOfExperience': PropertySchema(
      id: 11,
      name: r'yearsOfExperience',
      type: IsarType.long,
    )
  },
  estimateSize: _doctorProfileEstimateSize,
  serialize: _doctorProfileSerialize,
  deserialize: _doctorProfileDeserialize,
  deserializeProp: _doctorProfileDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _doctorProfileGetId,
  getLinks: _doctorProfileGetLinks,
  attach: _doctorProfileAttach,
  version: '3.1.0+1',
);

int _doctorProfileEstimateSize(
  DoctorProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.countryCode.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.institution;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.languages.length * 3;
  {
    for (var i = 0; i < object.languages.length; i++) {
      final value = object.languages[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.licenseNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.specialty.length * 3;
  return bytesCount;
}

void _doctorProfileSerialize(
  DoctorProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.countryCode);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.fullName);
  writer.writeLong(offsets[3], object.hashCode);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.institution);
  writer.writeStringList(offsets[6], object.languages);
  writer.writeString(offsets[7], object.licenseNumber);
  writer.writeString(offsets[8], object.specialty);
  writer.writeDateTime(offsets[9], object.updatedAt);
  writer.writeBool(offsets[10], object.verified);
  writer.writeLong(offsets[11], object.yearsOfExperience);
}

DoctorProfile _doctorProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DoctorProfile(
    countryCode: reader.readString(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    fullName: reader.readString(offsets[2]),
    id: reader.readString(offsets[4]),
    institution: reader.readStringOrNull(offsets[5]),
    languages: reader.readStringList(offsets[6]) ?? const [],
    licenseNumber: reader.readStringOrNull(offsets[7]),
    specialty: reader.readString(offsets[8]),
    updatedAt: reader.readDateTime(offsets[9]),
    verified: reader.readBoolOrNull(offsets[10]) ?? false,
    yearsOfExperience: reader.readLongOrNull(offsets[11]),
  );
  object.isarId = id;
  return object;
}

P _doctorProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? const []) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _doctorProfileGetId(DoctorProfile object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _doctorProfileGetLinks(DoctorProfile object) {
  return [];
}

void _doctorProfileAttach(
    IsarCollection<dynamic> col, Id id, DoctorProfile object) {
  object.isarId = id;
}

extension DoctorProfileQueryWhereSort
    on QueryBuilder<DoctorProfile, DoctorProfile, QWhere> {
  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DoctorProfileQueryWhere
    on QueryBuilder<DoctorProfile, DoctorProfile, QWhereClause> {
  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhereClause>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterWhereClause> isarIdBetween(
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

extension DoctorProfileQueryFilter
    on QueryBuilder<DoctorProfile, DoctorProfile, QFilterCondition> {
  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'countryCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'countryCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      countryCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'institution',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'institution',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'institution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'institution',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institution',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      institutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'institution',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languages',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languages',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      languagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'licenseNumber',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'licenseNumber',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'licenseNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'licenseNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'licenseNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'licenseNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      licenseNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'licenseNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'specialty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'specialty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'specialty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specialty',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      specialtyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'specialty',
        value: '',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
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

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      verifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verified',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'yearsOfExperience',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'yearsOfExperience',
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'yearsOfExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'yearsOfExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'yearsOfExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterFilterCondition>
      yearsOfExperienceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'yearsOfExperience',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DoctorProfileQueryObject
    on QueryBuilder<DoctorProfile, DoctorProfile, QFilterCondition> {}

extension DoctorProfileQueryLinks
    on QueryBuilder<DoctorProfile, DoctorProfile, QFilterCondition> {}

extension DoctorProfileQuerySortBy
    on QueryBuilder<DoctorProfile, DoctorProfile, QSortBy> {
  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByInstitution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByInstitutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByLicenseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseNumber', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByLicenseNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseNumber', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortBySpecialty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialty', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortBySpecialtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialty', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByYearsOfExperience() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearsOfExperience', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      sortByYearsOfExperienceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearsOfExperience', Sort.desc);
    });
  }
}

extension DoctorProfileQuerySortThenBy
    on QueryBuilder<DoctorProfile, DoctorProfile, QSortThenBy> {
  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByInstitution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByInstitutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByLicenseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseNumber', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByLicenseNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licenseNumber', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenBySpecialty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialty', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenBySpecialtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specialty', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy> thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByYearsOfExperience() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearsOfExperience', Sort.asc);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QAfterSortBy>
      thenByYearsOfExperienceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'yearsOfExperience', Sort.desc);
    });
  }
}

extension DoctorProfileQueryWhereDistinct
    on QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> {
  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByCountryCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countryCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByInstitution(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'institution', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languages');
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByLicenseNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licenseNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctBySpecialty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'specialty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct> distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }

  QueryBuilder<DoctorProfile, DoctorProfile, QDistinct>
      distinctByYearsOfExperience() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'yearsOfExperience');
    });
  }
}

extension DoctorProfileQueryProperty
    on QueryBuilder<DoctorProfile, DoctorProfile, QQueryProperty> {
  QueryBuilder<DoctorProfile, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DoctorProfile, String, QQueryOperations> countryCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countryCode');
    });
  }

  QueryBuilder<DoctorProfile, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DoctorProfile, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<DoctorProfile, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DoctorProfile, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DoctorProfile, String?, QQueryOperations> institutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'institution');
    });
  }

  QueryBuilder<DoctorProfile, List<String>, QQueryOperations>
      languagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languages');
    });
  }

  QueryBuilder<DoctorProfile, String?, QQueryOperations>
      licenseNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licenseNumber');
    });
  }

  QueryBuilder<DoctorProfile, String, QQueryOperations> specialtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'specialty');
    });
  }

  QueryBuilder<DoctorProfile, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<DoctorProfile, bool, QQueryOperations> verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }

  QueryBuilder<DoctorProfile, int?, QQueryOperations>
      yearsOfExperienceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'yearsOfExperience');
    });
  }
}
