// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_credentials.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuthCredentialsCollection on Isar {
  IsarCollection<AuthCredentials> get authCredentials => this.collection();
}

const AuthCredentialsSchema = CollectionSchema(
  name: r'AuthCredentials',
  id: 5186440161042841949,
  properties: {
    r'biometricEnabled': PropertySchema(
      id: 0,
      name: r'biometricEnabled',
      type: IsarType.bool,
    ),
    r'failedAttempts': PropertySchema(
      id: 1,
      name: r'failedAttempts',
      type: IsarType.long,
    ),
    r'hashedPin': PropertySchema(
      id: 2,
      name: r'hashedPin',
      type: IsarType.string,
    ),
    r'lastLockoutTime': PropertySchema(
      id: 3,
      name: r'lastLockoutTime',
      type: IsarType.dateTime,
    ),
    r'salt': PropertySchema(
      id: 4,
      name: r'salt',
      type: IsarType.string,
    )
  },
  estimateSize: _authCredentialsEstimateSize,
  serialize: _authCredentialsSerialize,
  deserialize: _authCredentialsDeserialize,
  deserializeProp: _authCredentialsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _authCredentialsGetId,
  getLinks: _authCredentialsGetLinks,
  attach: _authCredentialsAttach,
  version: '3.1.0+1',
);

int _authCredentialsEstimateSize(
  AuthCredentials object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.hashedPin;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.salt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _authCredentialsSerialize(
  AuthCredentials object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.biometricEnabled);
  writer.writeLong(offsets[1], object.failedAttempts);
  writer.writeString(offsets[2], object.hashedPin);
  writer.writeDateTime(offsets[3], object.lastLockoutTime);
  writer.writeString(offsets[4], object.salt);
}

AuthCredentials _authCredentialsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthCredentials();
  object.biometricEnabled = reader.readBool(offsets[0]);
  object.failedAttempts = reader.readLong(offsets[1]);
  object.hashedPin = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.lastLockoutTime = reader.readDateTimeOrNull(offsets[3]);
  object.salt = reader.readStringOrNull(offsets[4]);
  return object;
}

P _authCredentialsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _authCredentialsGetId(AuthCredentials object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _authCredentialsGetLinks(AuthCredentials object) {
  return [];
}

void _authCredentialsAttach(
    IsarCollection<dynamic> col, Id id, AuthCredentials object) {
  object.id = id;
}

extension AuthCredentialsQueryWhereSort
    on QueryBuilder<AuthCredentials, AuthCredentials, QWhere> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuthCredentialsQueryWhere
    on QueryBuilder<AuthCredentials, AuthCredentials, QWhereClause> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhereClause>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterWhereClause> idBetween(
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

extension AuthCredentialsQueryFilter
    on QueryBuilder<AuthCredentials, AuthCredentials, QFilterCondition> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      biometricEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'biometricEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      failedAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failedAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      failedAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failedAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      failedAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failedAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      failedAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failedAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hashedPin',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hashedPin',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashedPin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hashedPin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hashedPin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashedPin',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      hashedPinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hashedPin',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastLockoutTime',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastLockoutTime',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLockoutTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLockoutTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLockoutTime',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastLockoutTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLockoutTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'salt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'salt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'salt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'salt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'salt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'salt',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      saltIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'salt',
        value: '',
      ));
    });
  }
}

extension AuthCredentialsQueryObject
    on QueryBuilder<AuthCredentials, AuthCredentials, QFilterCondition> {}

extension AuthCredentialsQueryLinks
    on QueryBuilder<AuthCredentials, AuthCredentials, QFilterCondition> {}

extension AuthCredentialsQuerySortBy
    on QueryBuilder<AuthCredentials, AuthCredentials, QSortBy> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByFailedAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByHashedPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedPin', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByHashedPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedPin', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLastLockoutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLockoutTime', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLastLockoutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLockoutTime', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> sortBySalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortBySaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salt', Sort.desc);
    });
  }
}

extension AuthCredentialsQuerySortThenBy
    on QueryBuilder<AuthCredentials, AuthCredentials, QSortThenBy> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByBiometricEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'biometricEnabled', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByFailedAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failedAttempts', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByHashedPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedPin', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByHashedPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashedPin', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLastLockoutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLockoutTime', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLastLockoutTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLockoutTime', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> thenBySalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenBySaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'salt', Sort.desc);
    });
  }
}

extension AuthCredentialsQueryWhereDistinct
    on QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> {
  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricEnabled');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedAttempts');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> distinctByHashedPin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashedPin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByLastLockoutTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLockoutTime');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> distinctBySalt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'salt', caseSensitive: caseSensitive);
    });
  }
}

extension AuthCredentialsQueryProperty
    on QueryBuilder<AuthCredentials, AuthCredentials, QQueryProperty> {
  QueryBuilder<AuthCredentials, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuthCredentials, bool, QQueryOperations>
      biometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricEnabled');
    });
  }

  QueryBuilder<AuthCredentials, int, QQueryOperations>
      failedAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedAttempts');
    });
  }

  QueryBuilder<AuthCredentials, String?, QQueryOperations> hashedPinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashedPin');
    });
  }

  QueryBuilder<AuthCredentials, DateTime?, QQueryOperations>
      lastLockoutTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLockoutTime');
    });
  }

  QueryBuilder<AuthCredentials, String?, QQueryOperations> saltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salt');
    });
  }
}
