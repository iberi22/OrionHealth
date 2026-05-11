// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_did.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarDidCollection on Isar {
  IsarCollection<IsarDid> get isarDids => this.collection();
}

const IsarDidSchema = CollectionSchema(
  name: r'IsarDid',
  id: 1674962400950285438,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'did': PropertySchema(
      id: 1,
      name: r'did',
      type: IsarType.string,
    ),
    r'didDocumentJson': PropertySchema(
      id: 2,
      name: r'didDocumentJson',
      type: IsarType.string,
    ),
    r'isAnchored': PropertySchema(
      id: 3,
      name: r'isAnchored',
      type: IsarType.bool,
    ),
    r'keyType': PropertySchema(
      id: 4,
      name: r'keyType',
      type: IsarType.string,
    ),
    r'longForm': PropertySchema(
      id: 5,
      name: r'longForm',
      type: IsarType.string,
    ),
    r'shortForm': PropertySchema(
      id: 6,
      name: r'shortForm',
      type: IsarType.string,
    )
  },
  estimateSize: _isarDidEstimateSize,
  serialize: _isarDidSerialize,
  deserialize: _isarDidDeserialize,
  deserializeProp: _isarDidDeserializeProp,
  idName: r'id',
  indexes: {
    r'did': IndexSchema(
      id: -4238199618338197262,
      name: r'did',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'did',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarDidGetId,
  getLinks: _isarDidGetLinks,
  attach: _isarDidAttach,
  version: '3.1.0+1',
);

int _isarDidEstimateSize(
  IsarDid object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.did.length * 3;
  {
    final value = object.didDocumentJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.keyType.length * 3;
  bytesCount += 3 + object.longForm.length * 3;
  {
    final value = object.shortForm;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarDidSerialize(
  IsarDid object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.did);
  writer.writeString(offsets[2], object.didDocumentJson);
  writer.writeBool(offsets[3], object.isAnchored);
  writer.writeString(offsets[4], object.keyType);
  writer.writeString(offsets[5], object.longForm);
  writer.writeString(offsets[6], object.shortForm);
}

IsarDid _isarDidDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarDid();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.did = reader.readString(offsets[1]);
  object.didDocumentJson = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isAnchored = reader.readBool(offsets[3]);
  object.keyType = reader.readString(offsets[4]);
  object.longForm = reader.readString(offsets[5]);
  object.shortForm = reader.readStringOrNull(offsets[6]);
  return object;
}

P _isarDidDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarDidGetId(IsarDid object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarDidGetLinks(IsarDid object) {
  return [];
}

void _isarDidAttach(IsarCollection<dynamic> col, Id id, IsarDid object) {
  object.id = id;
}

extension IsarDidByIndex on IsarCollection<IsarDid> {
  Future<IsarDid?> getByDid(String did) {
    return getByIndex(r'did', [did]);
  }

  IsarDid? getByDidSync(String did) {
    return getByIndexSync(r'did', [did]);
  }

  Future<bool> deleteByDid(String did) {
    return deleteByIndex(r'did', [did]);
  }

  bool deleteByDidSync(String did) {
    return deleteByIndexSync(r'did', [did]);
  }

  Future<List<IsarDid?>> getAllByDid(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return getAllByIndex(r'did', values);
  }

  List<IsarDid?> getAllByDidSync(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'did', values);
  }

  Future<int> deleteAllByDid(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'did', values);
  }

  int deleteAllByDidSync(List<String> didValues) {
    final values = didValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'did', values);
  }

  Future<Id> putByDid(IsarDid object) {
    return putByIndex(r'did', object);
  }

  Id putByDidSync(IsarDid object, {bool saveLinks = true}) {
    return putByIndexSync(r'did', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDid(List<IsarDid> objects) {
    return putAllByIndex(r'did', objects);
  }

  List<Id> putAllByDidSync(List<IsarDid> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'did', objects, saveLinks: saveLinks);
  }
}

extension IsarDidQueryWhereSort on QueryBuilder<IsarDid, IsarDid, QWhere> {
  QueryBuilder<IsarDid, IsarDid, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarDidQueryWhere on QueryBuilder<IsarDid, IsarDid, QWhereClause> {
  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> didEqualTo(String did) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'did',
        value: [did],
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterWhereClause> didNotEqualTo(String did) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [],
              upper: [did],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [did],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [did],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'did',
              lower: [],
              upper: [did],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsarDidQueryFilter
    on QueryBuilder<IsarDid, IsarDid, QFilterCondition> {
  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'did',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'did',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'did',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'did',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'didDocumentJson',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'didDocumentJson',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'didDocumentJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'didDocumentJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> didDocumentJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'didDocumentJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'didDocumentJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition>
      didDocumentJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'didDocumentJson',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> isAnchoredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAnchored',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> keyTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyType',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longForm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'longForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'longForm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longForm',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> longFormIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'longForm',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'shortForm',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'shortForm',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shortForm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shortForm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shortForm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shortForm',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterFilterCondition> shortFormIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shortForm',
        value: '',
      ));
    });
  }
}

extension IsarDidQueryObject
    on QueryBuilder<IsarDid, IsarDid, QFilterCondition> {}

extension IsarDidQueryLinks
    on QueryBuilder<IsarDid, IsarDid, QFilterCondition> {}

extension IsarDidQuerySortBy on QueryBuilder<IsarDid, IsarDid, QSortBy> {
  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByDidDocumentJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didDocumentJson', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByDidDocumentJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didDocumentJson', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByIsAnchored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnchored', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByIsAnchoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnchored', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByKeyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyType', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByKeyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyType', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByLongForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longForm', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByLongFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longForm', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByShortForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortForm', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> sortByShortFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortForm', Sort.desc);
    });
  }
}

extension IsarDidQuerySortThenBy
    on QueryBuilder<IsarDid, IsarDid, QSortThenBy> {
  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByDid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByDidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'did', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByDidDocumentJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didDocumentJson', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByDidDocumentJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'didDocumentJson', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByIsAnchored() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnchored', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByIsAnchoredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAnchored', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByKeyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyType', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByKeyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyType', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByLongForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longForm', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByLongFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longForm', Sort.desc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByShortForm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortForm', Sort.asc);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QAfterSortBy> thenByShortFormDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shortForm', Sort.desc);
    });
  }
}

extension IsarDidQueryWhereDistinct
    on QueryBuilder<IsarDid, IsarDid, QDistinct> {
  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByDid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'did', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByDidDocumentJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'didDocumentJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByIsAnchored() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAnchored');
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByKeyType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByLongForm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longForm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarDid, IsarDid, QDistinct> distinctByShortForm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shortForm', caseSensitive: caseSensitive);
    });
  }
}

extension IsarDidQueryProperty
    on QueryBuilder<IsarDid, IsarDid, QQueryProperty> {
  QueryBuilder<IsarDid, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarDid, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarDid, String, QQueryOperations> didProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'did');
    });
  }

  QueryBuilder<IsarDid, String?, QQueryOperations> didDocumentJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'didDocumentJson');
    });
  }

  QueryBuilder<IsarDid, bool, QQueryOperations> isAnchoredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAnchored');
    });
  }

  QueryBuilder<IsarDid, String, QQueryOperations> keyTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyType');
    });
  }

  QueryBuilder<IsarDid, String, QQueryOperations> longFormProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longForm');
    });
  }

  QueryBuilder<IsarDid, String?, QQueryOperations> shortFormProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shortForm');
    });
  }
}
