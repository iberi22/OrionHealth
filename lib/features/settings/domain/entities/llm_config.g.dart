// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLlmConfigCollection on Isar {
  IsarCollection<LlmConfig> get llmConfigs => this.collection();
}

const LlmConfigSchema = CollectionSchema(
  name: r'LlmConfig',
  id: -1133713317419693239,
  properties: {
    r'allowCloudApiCalls': PropertySchema(
      id: 0,
      name: r'allowCloudApiCalls',
      type: IsarType.bool,
    ),
    r'apiKey': PropertySchema(
      id: 1,
      name: r'apiKey',
      type: IsarType.string,
    ),
    r'baseUrl': PropertySchema(
      id: 2,
      name: r'baseUrl',
      type: IsarType.string,
    ),
    r'cloudModel': PropertySchema(
      id: 3,
      name: r'cloudModel',
      type: IsarType.string,
    ),
    r'deviceCapabilityTier': PropertySchema(
      id: 4,
      name: r'deviceCapabilityTier',
      type: IsarType.string,
    ),
    r'localModelId': PropertySchema(
      id: 5,
      name: r'localModelId',
      type: IsarType.string,
    ),
    r'providerType': PropertySchema(
      id: 6,
      name: r'providerType',
      type: IsarType.string,
    ),
    r'recommendedModel': PropertySchema(
      id: 7,
      name: r'recommendedModel',
      type: IsarType.string,
    ),
    r'selectedModel': PropertySchema(
      id: 8,
      name: r'selectedModel',
      type: IsarType.string,
    ),
    r'useCloudApi': PropertySchema(
      id: 9,
      name: r'useCloudApi',
      type: IsarType.bool,
    )
  },
  estimateSize: _llmConfigEstimateSize,
  serialize: _llmConfigSerialize,
  deserialize: _llmConfigDeserialize,
  deserializeProp: _llmConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _llmConfigGetId,
  getLinks: _llmConfigGetLinks,
  attach: _llmConfigAttach,
  version: '3.1.0+1',
);

int _llmConfigEstimateSize(
  LlmConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.apiKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.baseUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cloudModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deviceCapabilityTier.length * 3;
  {
    final value = object.localModelId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.providerType.length * 3;
  {
    final value = object.recommendedModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedModel.length * 3;
  return bytesCount;
}

void _llmConfigSerialize(
  LlmConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowCloudApiCalls);
  writer.writeString(offsets[1], object.apiKey);
  writer.writeString(offsets[2], object.baseUrl);
  writer.writeString(offsets[3], object.cloudModel);
  writer.writeString(offsets[4], object.deviceCapabilityTier);
  writer.writeString(offsets[5], object.localModelId);
  writer.writeString(offsets[6], object.providerType);
  writer.writeString(offsets[7], object.recommendedModel);
  writer.writeString(offsets[8], object.selectedModel);
  writer.writeBool(offsets[9], object.useCloudApi);
}

LlmConfig _llmConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LlmConfig(
    allowCloudApiCalls: reader.readBoolOrNull(offsets[0]) ?? true,
    apiKey: reader.readStringOrNull(offsets[1]),
    baseUrl: reader.readStringOrNull(offsets[2]),
    cloudModel: reader.readStringOrNull(offsets[3]),
    deviceCapabilityTier: reader.readStringOrNull(offsets[4]) ?? 'medium',
    localModelId: reader.readStringOrNull(offsets[5]),
    providerType: reader.readStringOrNull(offsets[6]) ?? 'local',
    recommendedModel: reader.readStringOrNull(offsets[7]),
    selectedModel: reader.readStringOrNull(offsets[8]) ?? 'gemini-2.0-flash',
    useCloudApi: reader.readBoolOrNull(offsets[9]) ?? true,
  );
  object.id = id;
  return object;
}

P _llmConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? 'medium') as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? 'local') as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset) ?? 'gemini-2.0-flash') as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _llmConfigGetId(LlmConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _llmConfigGetLinks(LlmConfig object) {
  return [];
}

void _llmConfigAttach(IsarCollection<dynamic> col, Id id, LlmConfig object) {
  object.id = id;
}

extension LlmConfigQueryWhereSort
    on QueryBuilder<LlmConfig, LlmConfig, QWhere> {
  QueryBuilder<LlmConfig, LlmConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LlmConfigQueryWhere
    on QueryBuilder<LlmConfig, LlmConfig, QWhereClause> {
  QueryBuilder<LlmConfig, LlmConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LlmConfig, LlmConfig, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterWhereClause> idBetween(
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

extension LlmConfigQueryFilter
    on QueryBuilder<LlmConfig, LlmConfig, QFilterCondition> {
  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      allowCloudApiCallsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowCloudApiCalls',
        value: value,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'apiKey',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'apiKey',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> apiKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baseUrl',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baseUrl',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> baseUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      baseUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudModel',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      cloudModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudModel',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      cloudModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cloudModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      cloudModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cloudModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> cloudModelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cloudModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      cloudModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      cloudModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cloudModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceCapabilityTier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceCapabilityTier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceCapabilityTier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceCapabilityTier',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      deviceCapabilityTierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceCapabilityTier',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localModelId',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localModelId',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> localModelIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> localModelIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localModelId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localModelId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> localModelIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localModelId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localModelId',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      localModelIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localModelId',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> providerTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> providerTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> providerTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerType',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      providerTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerType',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recommendedModel',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recommendedModel',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendedModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendedModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendedModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      recommendedModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendedModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'selectedModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'selectedModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition>
      selectedModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'selectedModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterFilterCondition> useCloudApiEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useCloudApi',
        value: value,
      ));
    });
  }
}

extension LlmConfigQueryObject
    on QueryBuilder<LlmConfig, LlmConfig, QFilterCondition> {}

extension LlmConfigQueryLinks
    on QueryBuilder<LlmConfig, LlmConfig, QFilterCondition> {}

extension LlmConfigQuerySortBy on QueryBuilder<LlmConfig, LlmConfig, QSortBy> {
  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByAllowCloudApiCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowCloudApiCalls', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      sortByAllowCloudApiCallsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowCloudApiCalls', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByCloudModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByCloudModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      sortByDeviceCapabilityTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCapabilityTier', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      sortByDeviceCapabilityTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCapabilityTier', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByLocalModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localModelId', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByLocalModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localModelId', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByProviderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerType', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByProviderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerType', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByRecommendedModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      sortByRecommendedModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortBySelectedModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortBySelectedModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByUseCloudApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCloudApi', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> sortByUseCloudApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCloudApi', Sort.desc);
    });
  }
}

extension LlmConfigQuerySortThenBy
    on QueryBuilder<LlmConfig, LlmConfig, QSortThenBy> {
  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByAllowCloudApiCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowCloudApiCalls', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      thenByAllowCloudApiCallsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowCloudApiCalls', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByCloudModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByCloudModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      thenByDeviceCapabilityTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCapabilityTier', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      thenByDeviceCapabilityTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCapabilityTier', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByLocalModelId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localModelId', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByLocalModelIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localModelId', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByProviderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerType', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByProviderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerType', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByRecommendedModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy>
      thenByRecommendedModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenBySelectedModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedModel', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenBySelectedModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedModel', Sort.desc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByUseCloudApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCloudApi', Sort.asc);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QAfterSortBy> thenByUseCloudApiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCloudApi', Sort.desc);
    });
  }
}

extension LlmConfigQueryWhereDistinct
    on QueryBuilder<LlmConfig, LlmConfig, QDistinct> {
  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByAllowCloudApiCalls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowCloudApiCalls');
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByApiKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByBaseUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByCloudModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByDeviceCapabilityTier(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceCapabilityTier',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByLocalModelId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localModelId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByProviderType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByRecommendedModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendedModel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctBySelectedModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedModel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LlmConfig, LlmConfig, QDistinct> distinctByUseCloudApi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useCloudApi');
    });
  }
}

extension LlmConfigQueryProperty
    on QueryBuilder<LlmConfig, LlmConfig, QQueryProperty> {
  QueryBuilder<LlmConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LlmConfig, bool, QQueryOperations> allowCloudApiCallsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowCloudApiCalls');
    });
  }

  QueryBuilder<LlmConfig, String?, QQueryOperations> apiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiKey');
    });
  }

  QueryBuilder<LlmConfig, String?, QQueryOperations> baseUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseUrl');
    });
  }

  QueryBuilder<LlmConfig, String?, QQueryOperations> cloudModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudModel');
    });
  }

  QueryBuilder<LlmConfig, String, QQueryOperations>
      deviceCapabilityTierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceCapabilityTier');
    });
  }

  QueryBuilder<LlmConfig, String?, QQueryOperations> localModelIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localModelId');
    });
  }

  QueryBuilder<LlmConfig, String, QQueryOperations> providerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerType');
    });
  }

  QueryBuilder<LlmConfig, String?, QQueryOperations>
      recommendedModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendedModel');
    });
  }

  QueryBuilder<LlmConfig, String, QQueryOperations> selectedModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedModel');
    });
  }

  QueryBuilder<LlmConfig, bool, QQueryOperations> useCloudApiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useCloudApi');
    });
  }
}
