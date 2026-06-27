// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'second_opinion.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSecondOpinionRequestCollection on Isar {
  IsarCollection<SecondOpinionRequest> get secondOpinionRequests =>
      this.collection();
}

const SecondOpinionRequestSchema = CollectionSchema(
  name: r'SecondOpinionRequest',
  id: -7953683894219704785,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'documents': PropertySchema(
      id: 1,
      name: r'documents',
      type: IsarType.stringList,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'patientId': PropertySchema(
      id: 3,
      name: r'patientId',
      type: IsarType.string,
    ),
    r'primaryDoctorId': PropertySchema(
      id: 4,
      name: r'primaryDoctorId',
      type: IsarType.string,
    ),
    r'symptoms': PropertySchema(
      id: 5,
      name: r'symptoms',
      type: IsarType.string,
    )
  },
  estimateSize: _secondOpinionRequestEstimateSize,
  serialize: _secondOpinionRequestSerialize,
  deserialize: _secondOpinionRequestDeserialize,
  deserializeProp: _secondOpinionRequestDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _secondOpinionRequestGetId,
  getLinks: _secondOpinionRequestGetLinks,
  attach: _secondOpinionRequestAttach,
  version: '3.1.0+1',
);

int _secondOpinionRequestEstimateSize(
  SecondOpinionRequest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.documents.length * 3;
  {
    for (var i = 0; i < object.documents.length; i++) {
      final value = object.documents[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.patientId.length * 3;
  {
    final value = object.primaryDoctorId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.symptoms.length * 3;
  return bytesCount;
}

void _secondOpinionRequestSerialize(
  SecondOpinionRequest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeStringList(offsets[1], object.documents);
  writer.writeString(offsets[2], object.id);
  writer.writeString(offsets[3], object.patientId);
  writer.writeString(offsets[4], object.primaryDoctorId);
  writer.writeString(offsets[5], object.symptoms);
}

SecondOpinionRequest _secondOpinionRequestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SecondOpinionRequest(
    createdAt: reader.readDateTime(offsets[0]),
    documents: reader.readStringList(offsets[1]) ?? const [],
    id: reader.readString(offsets[2]),
    patientId: reader.readString(offsets[3]),
    primaryDoctorId: reader.readStringOrNull(offsets[4]),
    symptoms: reader.readString(offsets[5]),
  );
  object.isarId = id;
  return object;
}

P _secondOpinionRequestDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? const []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _secondOpinionRequestGetId(SecondOpinionRequest object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _secondOpinionRequestGetLinks(
    SecondOpinionRequest object) {
  return [];
}

void _secondOpinionRequestAttach(
    IsarCollection<dynamic> col, Id id, SecondOpinionRequest object) {
  object.isarId = id;
}

extension SecondOpinionRequestQueryWhereSort
    on QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QWhere> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SecondOpinionRequestQueryWhere
    on QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QWhereClause> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhereClause>
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterWhereClause>
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

extension SecondOpinionRequestQueryFilter on QueryBuilder<SecondOpinionRequest,
    SecondOpinionRequest, QFilterCondition> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documents',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      documentsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      documentsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documents',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documents',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documents',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> documentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'documents',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'patientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      patientIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      patientIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'patientId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patientId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> patientIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'patientId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'primaryDoctorId',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'primaryDoctorId',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryDoctorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      primaryDoctorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      primaryDoctorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryDoctorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryDoctorId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> primaryDoctorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryDoctorId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symptoms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      symptomsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
          QAfterFilterCondition>
      symptomsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symptoms',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptoms',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest,
      QAfterFilterCondition> symptomsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symptoms',
        value: '',
      ));
    });
  }
}

extension SecondOpinionRequestQueryObject on QueryBuilder<SecondOpinionRequest,
    SecondOpinionRequest, QFilterCondition> {}

extension SecondOpinionRequestQueryLinks on QueryBuilder<SecondOpinionRequest,
    SecondOpinionRequest, QFilterCondition> {}

extension SecondOpinionRequestQuerySortBy
    on QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QSortBy> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByPatientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByPatientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByPrimaryDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryDoctorId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortByPrimaryDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryDoctorId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortBySymptoms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      sortBySymptomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.desc);
    });
  }
}

extension SecondOpinionRequestQuerySortThenBy
    on QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QSortThenBy> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByPatientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByPatientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByPrimaryDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryDoctorId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenByPrimaryDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryDoctorId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenBySymptoms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QAfterSortBy>
      thenBySymptomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.desc);
    });
  }
}

extension SecondOpinionRequestQueryWhereDistinct
    on QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct> {
  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctByDocuments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documents');
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctByPatientId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patientId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctByPrimaryDoctorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryDoctorId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionRequest, SecondOpinionRequest, QDistinct>
      distinctBySymptoms({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symptoms', caseSensitive: caseSensitive);
    });
  }
}

extension SecondOpinionRequestQueryProperty on QueryBuilder<
    SecondOpinionRequest, SecondOpinionRequest, QQueryProperty> {
  QueryBuilder<SecondOpinionRequest, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SecondOpinionRequest, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SecondOpinionRequest, List<String>, QQueryOperations>
      documentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documents');
    });
  }

  QueryBuilder<SecondOpinionRequest, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SecondOpinionRequest, String, QQueryOperations>
      patientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patientId');
    });
  }

  QueryBuilder<SecondOpinionRequest, String?, QQueryOperations>
      primaryDoctorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryDoctorId');
    });
  }

  QueryBuilder<SecondOpinionRequest, String, QQueryOperations>
      symptomsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symptoms');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSecondOpinionResponseCollection on Isar {
  IsarCollection<SecondOpinionResponse> get secondOpinionResponses =>
      this.collection();
}

const SecondOpinionResponseSchema = CollectionSchema(
  name: r'SecondOpinionResponse',
  id: -3056271521634917205,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'recommendation': PropertySchema(
      id: 2,
      name: r'recommendation',
      type: IsarType.string,
    ),
    r'requestId': PropertySchema(
      id: 3,
      name: r'requestId',
      type: IsarType.string,
    ),
    r'respondedAt': PropertySchema(
      id: 4,
      name: r'respondedAt',
      type: IsarType.dateTime,
    ),
    r'reviewerDoctorId': PropertySchema(
      id: 5,
      name: r'reviewerDoctorId',
      type: IsarType.string,
    )
  },
  estimateSize: _secondOpinionResponseEstimateSize,
  serialize: _secondOpinionResponseSerialize,
  deserialize: _secondOpinionResponseDeserialize,
  deserializeProp: _secondOpinionResponseDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _secondOpinionResponseGetId,
  getLinks: _secondOpinionResponseGetLinks,
  attach: _secondOpinionResponseAttach,
  version: '3.1.0+1',
);

int _secondOpinionResponseEstimateSize(
  SecondOpinionResponse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.recommendation.length * 3;
  bytesCount += 3 + object.requestId.length * 3;
  bytesCount += 3 + object.reviewerDoctorId.length * 3;
  return bytesCount;
}

void _secondOpinionResponseSerialize(
  SecondOpinionResponse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeString(offsets[1], object.id);
  writer.writeString(offsets[2], object.recommendation);
  writer.writeString(offsets[3], object.requestId);
  writer.writeDateTime(offsets[4], object.respondedAt);
  writer.writeString(offsets[5], object.reviewerDoctorId);
}

SecondOpinionResponse _secondOpinionResponseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SecondOpinionResponse(
    confidence: reader.readDouble(offsets[0]),
    id: reader.readString(offsets[1]),
    recommendation: reader.readString(offsets[2]),
    requestId: reader.readString(offsets[3]),
    respondedAt: reader.readDateTime(offsets[4]),
    reviewerDoctorId: reader.readString(offsets[5]),
  );
  object.isarId = id;
  return object;
}

P _secondOpinionResponseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _secondOpinionResponseGetId(SecondOpinionResponse object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _secondOpinionResponseGetLinks(
    SecondOpinionResponse object) {
  return [];
}

void _secondOpinionResponseAttach(
    IsarCollection<dynamic> col, Id id, SecondOpinionResponse object) {
  object.isarId = id;
}

extension SecondOpinionResponseQueryWhereSort
    on QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QWhere> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SecondOpinionResponseQueryWhere on QueryBuilder<SecondOpinionResponse,
    SecondOpinionResponse, QWhereClause> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhereClause>
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterWhereClause>
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

extension SecondOpinionResponseQueryFilter on QueryBuilder<
    SecondOpinionResponse, SecondOpinionResponse, QFilterCondition> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      recommendationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      recommendationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendation',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> recommendationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendation',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      requestIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      requestIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> requestIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> respondedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'respondedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> respondedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'respondedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> respondedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'respondedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> respondedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'respondedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reviewerDoctorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      reviewerDoctorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reviewerDoctorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
          QAfterFilterCondition>
      reviewerDoctorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reviewerDoctorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reviewerDoctorId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse,
      QAfterFilterCondition> reviewerDoctorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reviewerDoctorId',
        value: '',
      ));
    });
  }
}

extension SecondOpinionResponseQueryObject on QueryBuilder<
    SecondOpinionResponse, SecondOpinionResponse, QFilterCondition> {}

extension SecondOpinionResponseQueryLinks on QueryBuilder<SecondOpinionResponse,
    SecondOpinionResponse, QFilterCondition> {}

extension SecondOpinionResponseQuerySortBy
    on QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QSortBy> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRecommendation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRecommendationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRespondedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAt', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByRespondedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAt', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByReviewerDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerDoctorId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      sortByReviewerDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerDoctorId', Sort.desc);
    });
  }
}

extension SecondOpinionResponseQuerySortThenBy
    on QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QSortThenBy> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRecommendation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRecommendationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendation', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRespondedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAt', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByRespondedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'respondedAt', Sort.desc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByReviewerDoctorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerDoctorId', Sort.asc);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QAfterSortBy>
      thenByReviewerDoctorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reviewerDoctorId', Sort.desc);
    });
  }
}

extension SecondOpinionResponseQueryWhereDistinct
    on QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct> {
  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctByRecommendation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctByRequestId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctByRespondedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'respondedAt');
    });
  }

  QueryBuilder<SecondOpinionResponse, SecondOpinionResponse, QDistinct>
      distinctByReviewerDoctorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reviewerDoctorId',
          caseSensitive: caseSensitive);
    });
  }
}

extension SecondOpinionResponseQueryProperty on QueryBuilder<
    SecondOpinionResponse, SecondOpinionResponse, QQueryProperty> {
  QueryBuilder<SecondOpinionResponse, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SecondOpinionResponse, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<SecondOpinionResponse, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SecondOpinionResponse, String, QQueryOperations>
      recommendationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendation');
    });
  }

  QueryBuilder<SecondOpinionResponse, String, QQueryOperations>
      requestIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestId');
    });
  }

  QueryBuilder<SecondOpinionResponse, DateTime, QQueryOperations>
      respondedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'respondedAt');
    });
  }

  QueryBuilder<SecondOpinionResponse, String, QQueryOperations>
      reviewerDoctorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reviewerDoctorId');
    });
  }
}
