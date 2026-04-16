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
    r'failedAttempts': PropertySchema(
      id: 0,
      name: r'failedAttempts',
      type: IsarType.long,
    ),
    r'hashedPin': PropertySchema(
      id: 1,
      name: r'hashedPin',
      type: IsarType.string,
    ),
    r'isBiometricsEnabled': PropertySchema(
      id: 2,
      name: r'isBiometricsEnabled',
      type: IsarType.bool,
    ),
    r'lockoutUntil': PropertySchema(
      id: 3,
      name: r'lockoutUntil',
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
  writer.writeLong(offsets[0], object.failedAttempts);
  writer.writeString(offsets[1], object.hashedPin);
  writer.writeBool(offsets[2], object.isBiometricsEnabled);
  writer.writeDateTime(offsets[3], object.lockoutUntil);
  writer.writeString(offsets[4], object.salt);
}

AuthCredentials _authCredentialsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthCredentials(
    failedAttempts: reader.readLongOrNull(offsets[0]) ?? 0,
    hashedPin: reader.readStringOrNull(offsets[1]),
    isBiometricsEnabled: reader.readBoolOrNull(offsets[2]) ?? false,
    lockoutUntil: reader.readDateTimeOrNull(offsets[3]),
    salt: reader.readStringOrNull(offsets[4]),
  );
  object.id = id;
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
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
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
      isBiometricsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBiometricsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lockoutUntil',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lockoutUntil',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockoutUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lockoutUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lockoutUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockoutUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lockoutUntil',
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
      sortByIsBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByIsBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockoutUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.desc);
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
      thenByIsBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricsEnabled', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByIsBiometricsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricsEnabled', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockoutUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockoutUntil', Sort.desc);
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
      distinctByIsBiometricsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBiometricsEnabled');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByLockoutUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockoutUntil');
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

  QueryBuilder<AuthCredentials, bool, QQueryOperations>
      isBiometricsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBiometricsEnabled');
    });
  }

  QueryBuilder<AuthCredentials, DateTime?, QQueryOperations>
      lockoutUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockoutUntil');
    });
  }

  QueryBuilder<AuthCredentials, String?, QQueryOperations> saltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'salt');
    });
  }
}
