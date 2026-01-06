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
    r'authMethod': PropertySchema(
      id: 0,
      name: r'authMethod',
      type: IsarType.byte,
      enumMap: _AuthCredentialsauthMethodEnumValueMap,
    ),
    r'biometricEnabled': PropertySchema(
      id: 1,
      name: r'biometricEnabled',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'failedAttempts': PropertySchema(
      id: 3,
      name: r'failedAttempts',
      type: IsarType.long,
    ),
    r'isCurrentlyLocked': PropertySchema(
      id: 4,
      name: r'isCurrentlyLocked',
      type: IsarType.bool,
    ),
    r'isLocked': PropertySchema(
      id: 5,
      name: r'isLocked',
      type: IsarType.bool,
    ),
    r'lastFailedAttempt': PropertySchema(
      id: 6,
      name: r'lastFailedAttempt',
      type: IsarType.dateTime,
    ),
    r'lockRemainingMinutes': PropertySchema(
      id: 7,
      name: r'lockRemainingMinutes',
      type: IsarType.long,
    ),
    r'lockUntil': PropertySchema(
      id: 8,
      name: r'lockUntil',
      type: IsarType.dateTime,
    ),
    r'pinHash': PropertySchema(
      id: 9,
      name: r'pinHash',
      type: IsarType.string,
    ),
    r'pinSalt': PropertySchema(
      id: 10,
      name: r'pinSalt',
      type: IsarType.string,
    ),
    r'requireAuthOnResume': PropertySchema(
      id: 11,
      name: r'requireAuthOnResume',
      type: IsarType.bool,
    ),
    r'sessionTimeoutMinutes': PropertySchema(
      id: 12,
      name: r'sessionTimeoutMinutes',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
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
    final value = object.pinHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pinSalt;
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
  writer.writeByte(offsets[0], object.authMethod.index);
  writer.writeBool(offsets[1], object.biometricEnabled);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.failedAttempts);
  writer.writeBool(offsets[4], object.isCurrentlyLocked);
  writer.writeBool(offsets[5], object.isLocked);
  writer.writeDateTime(offsets[6], object.lastFailedAttempt);
  writer.writeLong(offsets[7], object.lockRemainingMinutes);
  writer.writeDateTime(offsets[8], object.lockUntil);
  writer.writeString(offsets[9], object.pinHash);
  writer.writeString(offsets[10], object.pinSalt);
  writer.writeBool(offsets[11], object.requireAuthOnResume);
  writer.writeLong(offsets[12], object.sessionTimeoutMinutes);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

AuthCredentials _authCredentialsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthCredentials();
  object.authMethod = _AuthCredentialsauthMethodValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      AuthMethod.pin;
  object.biometricEnabled = reader.readBool(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.failedAttempts = reader.readLong(offsets[3]);
  object.id = id;
  object.isLocked = reader.readBool(offsets[5]);
  object.lastFailedAttempt = reader.readDateTimeOrNull(offsets[6]);
  object.lockUntil = reader.readDateTimeOrNull(offsets[8]);
  object.pinHash = reader.readStringOrNull(offsets[9]);
  object.pinSalt = reader.readStringOrNull(offsets[10]);
  object.requireAuthOnResume = reader.readBool(offsets[11]);
  object.sessionTimeoutMinutes = reader.readLong(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
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
      return (_AuthCredentialsauthMethodValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AuthMethod.pin) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AuthCredentialsauthMethodEnumValueMap = {
  'pin': 0,
  'biometric': 1,
  'both': 2,
};
const _AuthCredentialsauthMethodValueEnumMap = {
  0: AuthMethod.pin,
  1: AuthMethod.biometric,
  2: AuthMethod.both,
};

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
      authMethodEqualTo(AuthMethod value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      authMethodGreaterThan(
    AuthMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      authMethodLessThan(
    AuthMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      authMethodBetween(
    AuthMethod lower,
    AuthMethod upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

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
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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
      isCurrentlyLockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCurrentlyLocked',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      isLockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLocked',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastFailedAttempt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastFailedAttempt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastFailedAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastFailedAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastFailedAttempt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lastFailedAttemptBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastFailedAttempt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockRemainingMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockRemainingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockRemainingMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lockRemainingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockRemainingMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lockRemainingMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockRemainingMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lockRemainingMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lockUntil',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lockUntil',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lockUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lockUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lockUntil',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      lockUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lockUntil',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pinHash',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pinHash',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pinHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pinHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pinHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pinHash',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pinSalt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pinSalt',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pinSalt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pinSalt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pinSalt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinSalt',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      pinSaltIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pinSalt',
        value: '',
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      requireAuthOnResumeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requireAuthOnResume',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      sessionTimeoutMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionTimeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      sessionTimeoutMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionTimeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      sessionTimeoutMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionTimeoutMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      sessionTimeoutMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionTimeoutMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterFilterCondition>
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

extension AuthCredentialsQueryObject
    on QueryBuilder<AuthCredentials, AuthCredentials, QFilterCondition> {}

extension AuthCredentialsQueryLinks
    on QueryBuilder<AuthCredentials, AuthCredentials, QFilterCondition> {}

extension AuthCredentialsQuerySortBy
    on QueryBuilder<AuthCredentials, AuthCredentials, QSortBy> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByAuthMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authMethod', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByAuthMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authMethod', Sort.desc);
    });
  }

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
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
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
      sortByIsCurrentlyLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCurrentlyLocked', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByIsCurrentlyLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCurrentlyLocked', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLastFailedAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailedAttempt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLastFailedAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailedAttempt', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockRemainingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockRemainingMinutes', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockRemainingMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockRemainingMinutes', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockUntil', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByLockUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockUntil', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> sortByPinHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHash', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByPinHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHash', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> sortByPinSalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSalt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByPinSaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSalt', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByRequireAuthOnResume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireAuthOnResume', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByRequireAuthOnResumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireAuthOnResume', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortBySessionTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionTimeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortBySessionTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionTimeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AuthCredentialsQuerySortThenBy
    on QueryBuilder<AuthCredentials, AuthCredentials, QSortThenBy> {
  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByAuthMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authMethod', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByAuthMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authMethod', Sort.desc);
    });
  }

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
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
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
      thenByIsCurrentlyLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCurrentlyLocked', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByIsCurrentlyLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCurrentlyLocked', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLastFailedAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailedAttempt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLastFailedAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailedAttempt', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockRemainingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockRemainingMinutes', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockRemainingMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockRemainingMinutes', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockUntil', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByLockUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lockUntil', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> thenByPinHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHash', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByPinHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinHash', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy> thenByPinSalt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSalt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByPinSaltDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinSalt', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByRequireAuthOnResume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireAuthOnResume', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByRequireAuthOnResumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requireAuthOnResume', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenBySessionTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionTimeoutMinutes', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenBySessionTimeoutMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionTimeoutMinutes', Sort.desc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AuthCredentialsQueryWhereDistinct
    on QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> {
  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByAuthMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authMethod');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByBiometricEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'biometricEnabled');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByFailedAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failedAttempts');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByIsCurrentlyLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCurrentlyLocked');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocked');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByLastFailedAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFailedAttempt');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByLockRemainingMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockRemainingMinutes');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByLockUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lockUntil');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> distinctByPinHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct> distinctByPinSalt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinSalt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByRequireAuthOnResume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requireAuthOnResume');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctBySessionTimeoutMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionTimeoutMinutes');
    });
  }

  QueryBuilder<AuthCredentials, AuthCredentials, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
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

  QueryBuilder<AuthCredentials, AuthMethod, QQueryOperations>
      authMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authMethod');
    });
  }

  QueryBuilder<AuthCredentials, bool, QQueryOperations>
      biometricEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'biometricEnabled');
    });
  }

  QueryBuilder<AuthCredentials, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AuthCredentials, int, QQueryOperations>
      failedAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failedAttempts');
    });
  }

  QueryBuilder<AuthCredentials, bool, QQueryOperations>
      isCurrentlyLockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCurrentlyLocked');
    });
  }

  QueryBuilder<AuthCredentials, bool, QQueryOperations> isLockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocked');
    });
  }

  QueryBuilder<AuthCredentials, DateTime?, QQueryOperations>
      lastFailedAttemptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFailedAttempt');
    });
  }

  QueryBuilder<AuthCredentials, int, QQueryOperations>
      lockRemainingMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockRemainingMinutes');
    });
  }

  QueryBuilder<AuthCredentials, DateTime?, QQueryOperations>
      lockUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lockUntil');
    });
  }

  QueryBuilder<AuthCredentials, String?, QQueryOperations> pinHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinHash');
    });
  }

  QueryBuilder<AuthCredentials, String?, QQueryOperations> pinSaltProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinSalt');
    });
  }

  QueryBuilder<AuthCredentials, bool, QQueryOperations>
      requireAuthOnResumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requireAuthOnResume');
    });
  }

  QueryBuilder<AuthCredentials, int, QQueryOperations>
      sessionTimeoutMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionTimeoutMinutes');
    });
  }

  QueryBuilder<AuthCredentials, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
