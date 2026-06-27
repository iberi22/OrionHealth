// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_audit_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetApiAuditLogCollection on Isar {
  IsarCollection<ApiAuditLog> get apiAuditLogs => this.collection();
}

const ApiAuditLogSchema = CollectionSchema(
  name: r'ApiAuditLog',
  id: -2753713020733113885,
  properties: {
    r'apiName': PropertySchema(
      id: 0,
      name: r'apiName',
      type: IsarType.string,
    ),
    r'originalPromptLength': PropertySchema(
      id: 1,
      name: r'originalPromptLength',
      type: IsarType.long,
    ),
    r'piiFound': PropertySchema(
      id: 2,
      name: r'piiFound',
      type: IsarType.bool,
    ),
    r'scrubbedPromptLength': PropertySchema(
      id: 3,
      name: r'scrubbedPromptLength',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 4,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _apiAuditLogEstimateSize,
  serialize: _apiAuditLogSerialize,
  deserialize: _apiAuditLogDeserialize,
  deserializeProp: _apiAuditLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _apiAuditLogGetId,
  getLinks: _apiAuditLogGetLinks,
  attach: _apiAuditLogAttach,
  version: '3.1.0+1',
);

int _apiAuditLogEstimateSize(
  ApiAuditLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apiName.length * 3;
  return bytesCount;
}

void _apiAuditLogSerialize(
  ApiAuditLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiName);
  writer.writeLong(offsets[1], object.originalPromptLength);
  writer.writeBool(offsets[2], object.piiFound);
  writer.writeLong(offsets[3], object.scrubbedPromptLength);
  writer.writeDateTime(offsets[4], object.timestamp);
}

ApiAuditLog _apiAuditLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ApiAuditLog(
    apiName: reader.readString(offsets[0]),
    originalPromptLength: reader.readLong(offsets[1]),
    piiFound: reader.readBool(offsets[2]),
    scrubbedPromptLength: reader.readLong(offsets[3]),
    timestamp: reader.readDateTime(offsets[4]),
  );
  object.id = id;
  return object;
}

P _apiAuditLogDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _apiAuditLogGetId(ApiAuditLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _apiAuditLogGetLinks(ApiAuditLog object) {
  return [];
}

void _apiAuditLogAttach(
    IsarCollection<dynamic> col, Id id, ApiAuditLog object) {
  object.id = id;
}

extension ApiAuditLogQueryWhereSort
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QWhere> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ApiAuditLogQueryWhere
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QWhereClause> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterWhereClause> idBetween(
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

extension ApiAuditLogQueryFilter
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QFilterCondition> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      apiNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      apiNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> apiNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      apiNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiName',
        value: '',
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      apiNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiName',
        value: '',
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      originalPromptLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      originalPromptLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      originalPromptLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      originalPromptLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalPromptLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition> piiFoundEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'piiFound',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      scrubbedPromptLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scrubbedPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      scrubbedPromptLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scrubbedPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      scrubbedPromptLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scrubbedPromptLength',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      scrubbedPromptLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scrubbedPromptLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ApiAuditLogQueryObject
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QFilterCondition> {}

extension ApiAuditLogQueryLinks
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QFilterCondition> {}

extension ApiAuditLogQuerySortBy
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QSortBy> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByApiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiName', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByApiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiName', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      sortByOriginalPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPromptLength', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      sortByOriginalPromptLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPromptLength', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByPiiFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'piiFound', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByPiiFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'piiFound', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      sortByScrubbedPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrubbedPromptLength', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      sortByScrubbedPromptLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrubbedPromptLength', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ApiAuditLogQuerySortThenBy
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QSortThenBy> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByApiName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiName', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByApiNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiName', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      thenByOriginalPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPromptLength', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      thenByOriginalPromptLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalPromptLength', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByPiiFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'piiFound', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByPiiFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'piiFound', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      thenByScrubbedPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrubbedPromptLength', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy>
      thenByScrubbedPromptLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scrubbedPromptLength', Sort.desc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ApiAuditLogQueryWhereDistinct
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct> {
  QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct> distinctByApiName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct>
      distinctByOriginalPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalPromptLength');
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct> distinctByPiiFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'piiFound');
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct>
      distinctByScrubbedPromptLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scrubbedPromptLength');
    });
  }

  QueryBuilder<ApiAuditLog, ApiAuditLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ApiAuditLogQueryProperty
    on QueryBuilder<ApiAuditLog, ApiAuditLog, QQueryProperty> {
  QueryBuilder<ApiAuditLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ApiAuditLog, String, QQueryOperations> apiNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiName');
    });
  }

  QueryBuilder<ApiAuditLog, int, QQueryOperations>
      originalPromptLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalPromptLength');
    });
  }

  QueryBuilder<ApiAuditLog, bool, QQueryOperations> piiFoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'piiFound');
    });
  }

  QueryBuilder<ApiAuditLog, int, QQueryOperations>
      scrubbedPromptLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scrubbedPromptLength');
    });
  }

  QueryBuilder<ApiAuditLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
