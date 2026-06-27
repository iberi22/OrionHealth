// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_registry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLicenseRegistryLocalCollection on Isar {
  IsarCollection<LicenseRegistryLocal> get licenseRegistryLocals =>
      this.collection();
}

const LicenseRegistryLocalSchema = CollectionSchema(
  name: r'LicenseRegistryLocal',
  id: -2005878214601057861,
  properties: {
    r'countryCode': PropertySchema(
      id: 0,
      name: r'countryCode',
      type: IsarType.string,
    ),
    r'hashes': PropertySchema(
      id: 1,
      name: r'hashes',
      type: IsarType.stringList,
    )
  },
  estimateSize: _licenseRegistryLocalEstimateSize,
  serialize: _licenseRegistryLocalSerialize,
  deserialize: _licenseRegistryLocalDeserialize,
  deserializeProp: _licenseRegistryLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'countryCode': IndexSchema(
      id: -6124957146481819559,
      name: r'countryCode',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'countryCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _licenseRegistryLocalGetId,
  getLinks: _licenseRegistryLocalGetLinks,
  attach: _licenseRegistryLocalAttach,
  version: '3.1.0+1',
);

int _licenseRegistryLocalEstimateSize(
  LicenseRegistryLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.countryCode.length * 3;
  bytesCount += 3 + object.hashes.length * 3;
  {
    for (var i = 0; i < object.hashes.length; i++) {
      final value = object.hashes[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _licenseRegistryLocalSerialize(
  LicenseRegistryLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.countryCode);
  writer.writeStringList(offsets[1], object.hashes);
}

LicenseRegistryLocal _licenseRegistryLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LicenseRegistryLocal(
    countryCode: reader.readString(offsets[0]),
    hashes: reader.readStringList(offsets[1]) ?? [],
  );
  object.id = id;
  return object;
}

P _licenseRegistryLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _licenseRegistryLocalGetId(LicenseRegistryLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _licenseRegistryLocalGetLinks(
    LicenseRegistryLocal object) {
  return [];
}

void _licenseRegistryLocalAttach(
    IsarCollection<dynamic> col, Id id, LicenseRegistryLocal object) {
  object.id = id;
}

extension LicenseRegistryLocalByIndex on IsarCollection<LicenseRegistryLocal> {
  Future<LicenseRegistryLocal?> getByCountryCode(String countryCode) {
    return getByIndex(r'countryCode', [countryCode]);
  }

  LicenseRegistryLocal? getByCountryCodeSync(String countryCode) {
    return getByIndexSync(r'countryCode', [countryCode]);
  }

  Future<bool> deleteByCountryCode(String countryCode) {
    return deleteByIndex(r'countryCode', [countryCode]);
  }

  bool deleteByCountryCodeSync(String countryCode) {
    return deleteByIndexSync(r'countryCode', [countryCode]);
  }

  Future<List<LicenseRegistryLocal?>> getAllByCountryCode(
      List<String> countryCodeValues) {
    final values = countryCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'countryCode', values);
  }

  List<LicenseRegistryLocal?> getAllByCountryCodeSync(
      List<String> countryCodeValues) {
    final values = countryCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'countryCode', values);
  }

  Future<int> deleteAllByCountryCode(List<String> countryCodeValues) {
    final values = countryCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'countryCode', values);
  }

  int deleteAllByCountryCodeSync(List<String> countryCodeValues) {
    final values = countryCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'countryCode', values);
  }

  Future<Id> putByCountryCode(LicenseRegistryLocal object) {
    return putByIndex(r'countryCode', object);
  }

  Id putByCountryCodeSync(LicenseRegistryLocal object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'countryCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCountryCode(List<LicenseRegistryLocal> objects) {
    return putAllByIndex(r'countryCode', objects);
  }

  List<Id> putAllByCountryCodeSync(List<LicenseRegistryLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'countryCode', objects, saveLinks: saveLinks);
  }
}

extension LicenseRegistryLocalQueryWhereSort
    on QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QWhere> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LicenseRegistryLocalQueryWhere
    on QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QWhereClause> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      countryCodeEqualTo(String countryCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'countryCode',
        value: [countryCode],
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterWhereClause>
      countryCodeNotEqualTo(String countryCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [],
              upper: [countryCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [countryCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [countryCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'countryCode',
              lower: [],
              upper: [countryCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LicenseRegistryLocalQueryFilter on QueryBuilder<LicenseRegistryLocal,
    LicenseRegistryLocal, QFilterCondition> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeEqualTo(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeGreaterThan(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeLessThan(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeBetween(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeStartsWith(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeEndsWith(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
          QAfterFilterCondition>
      countryCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'countryCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
          QAfterFilterCondition>
      countryCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'countryCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> countryCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'countryCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
          QAfterFilterCondition>
      hashesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hashes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
          QAfterFilterCondition>
      hashesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hashes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashes',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hashes',
        value: '',
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> hashesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'hashes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal,
      QAfterFilterCondition> idBetween(
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
}

extension LicenseRegistryLocalQueryObject on QueryBuilder<LicenseRegistryLocal,
    LicenseRegistryLocal, QFilterCondition> {}

extension LicenseRegistryLocalQueryLinks on QueryBuilder<LicenseRegistryLocal,
    LicenseRegistryLocal, QFilterCondition> {}

extension LicenseRegistryLocalQuerySortBy
    on QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QSortBy> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      sortByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      sortByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }
}

extension LicenseRegistryLocalQuerySortThenBy
    on QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QSortThenBy> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      thenByCountryCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.asc);
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      thenByCountryCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countryCode', Sort.desc);
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension LicenseRegistryLocalQueryWhereDistinct
    on QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QDistinct> {
  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QDistinct>
      distinctByCountryCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countryCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal, QDistinct>
      distinctByHashes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashes');
    });
  }
}

extension LicenseRegistryLocalQueryProperty on QueryBuilder<
    LicenseRegistryLocal, LicenseRegistryLocal, QQueryProperty> {
  QueryBuilder<LicenseRegistryLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LicenseRegistryLocal, String, QQueryOperations>
      countryCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countryCode');
    });
  }

  QueryBuilder<LicenseRegistryLocal, List<String>, QQueryOperations>
      hashesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashes');
    });
  }
}
