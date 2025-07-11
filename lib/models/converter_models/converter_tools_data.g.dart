// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'converter_tools_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetConverterToolsDataCollection on Isar {
  IsarCollection<ConverterToolsData> get converterToolsDatas =>
      this.collection();
}

const ConverterToolsDataSchema = CollectionSchema(
  name: r'ConverterToolsData',
  id: -6662130265328579496,
  properties: {
    r'dataType': PropertySchema(
      id: 0,
      name: r'dataType',
      type: IsarType.string,
    ),
    r'jsonData': PropertySchema(
      id: 1,
      name: r'jsonData',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'metadata': PropertySchema(
      id: 3,
      name: r'metadata',
      type: IsarType.string,
    ),
    r'toolCode': PropertySchema(
      id: 4,
      name: r'toolCode',
      type: IsarType.string,
    ),
    r'uniqueKey': PropertySchema(
      id: 5,
      name: r'uniqueKey',
      type: IsarType.string,
    )
  },
  estimateSize: _converterToolsDataEstimateSize,
  serialize: _converterToolsDataSerialize,
  deserialize: _converterToolsDataDeserialize,
  deserializeProp: _converterToolsDataDeserializeProp,
  idName: r'id',
  indexes: {
    r'toolCode_dataType': IndexSchema(
      id: -4183122769995865564,
      name: r'toolCode_dataType',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'toolCode',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'dataType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _converterToolsDataGetId,
  getLinks: _converterToolsDataGetLinks,
  attach: _converterToolsDataAttach,
  version: '3.0.5',
);

int _converterToolsDataEstimateSize(
  ConverterToolsData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dataType.length * 3;
  bytesCount += 3 + object.jsonData.length * 3;
  {
    final value = object.metadata;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.toolCode.length * 3;
  bytesCount += 3 + object.uniqueKey.length * 3;
  return bytesCount;
}

void _converterToolsDataSerialize(
  ConverterToolsData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dataType);
  writer.writeString(offsets[1], object.jsonData);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.metadata);
  writer.writeString(offsets[4], object.toolCode);
  writer.writeString(offsets[5], object.uniqueKey);
}

ConverterToolsData _converterToolsDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConverterToolsData();
  object.dataType = reader.readString(offsets[0]);
  object.id = id;
  object.jsonData = reader.readString(offsets[1]);
  object.lastUpdated = reader.readDateTime(offsets[2]);
  object.metadata = reader.readStringOrNull(offsets[3]);
  object.toolCode = reader.readString(offsets[4]);
  return object;
}

P _converterToolsDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _converterToolsDataGetId(ConverterToolsData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _converterToolsDataGetLinks(
    ConverterToolsData object) {
  return [];
}

void _converterToolsDataAttach(
    IsarCollection<dynamic> col, Id id, ConverterToolsData object) {
  object.id = id;
}

extension ConverterToolsDataByIndex on IsarCollection<ConverterToolsData> {
  Future<ConverterToolsData?> getByToolCodeDataType(
      String toolCode, String dataType) {
    return getByIndex(r'toolCode_dataType', [toolCode, dataType]);
  }

  ConverterToolsData? getByToolCodeDataTypeSync(
      String toolCode, String dataType) {
    return getByIndexSync(r'toolCode_dataType', [toolCode, dataType]);
  }

  Future<bool> deleteByToolCodeDataType(String toolCode, String dataType) {
    return deleteByIndex(r'toolCode_dataType', [toolCode, dataType]);
  }

  bool deleteByToolCodeDataTypeSync(String toolCode, String dataType) {
    return deleteByIndexSync(r'toolCode_dataType', [toolCode, dataType]);
  }

  Future<List<ConverterToolsData?>> getAllByToolCodeDataType(
      List<String> toolCodeValues, List<String> dataTypeValues) {
    final len = toolCodeValues.length;
    assert(dataTypeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([toolCodeValues[i], dataTypeValues[i]]);
    }

    return getAllByIndex(r'toolCode_dataType', values);
  }

  List<ConverterToolsData?> getAllByToolCodeDataTypeSync(
      List<String> toolCodeValues, List<String> dataTypeValues) {
    final len = toolCodeValues.length;
    assert(dataTypeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([toolCodeValues[i], dataTypeValues[i]]);
    }

    return getAllByIndexSync(r'toolCode_dataType', values);
  }

  Future<int> deleteAllByToolCodeDataType(
      List<String> toolCodeValues, List<String> dataTypeValues) {
    final len = toolCodeValues.length;
    assert(dataTypeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([toolCodeValues[i], dataTypeValues[i]]);
    }

    return deleteAllByIndex(r'toolCode_dataType', values);
  }

  int deleteAllByToolCodeDataTypeSync(
      List<String> toolCodeValues, List<String> dataTypeValues) {
    final len = toolCodeValues.length;
    assert(dataTypeValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([toolCodeValues[i], dataTypeValues[i]]);
    }

    return deleteAllByIndexSync(r'toolCode_dataType', values);
  }

  Future<Id> putByToolCodeDataType(ConverterToolsData object) {
    return putByIndex(r'toolCode_dataType', object);
  }

  Id putByToolCodeDataTypeSync(ConverterToolsData object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'toolCode_dataType', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByToolCodeDataType(List<ConverterToolsData> objects) {
    return putAllByIndex(r'toolCode_dataType', objects);
  }

  List<Id> putAllByToolCodeDataTypeSync(List<ConverterToolsData> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'toolCode_dataType', objects,
        saveLinks: saveLinks);
  }
}

extension ConverterToolsDataQueryWhereSort
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QWhere> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConverterToolsDataQueryWhere
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QWhereClause> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
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

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
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

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      toolCodeEqualToAnyDataType(String toolCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'toolCode_dataType',
        value: [toolCode],
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      toolCodeNotEqualToAnyDataType(String toolCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [],
              upper: [toolCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [],
              upper: [toolCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      toolCodeDataTypeEqualTo(String toolCode, String dataType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'toolCode_dataType',
        value: [toolCode, dataType],
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterWhereClause>
      toolCodeEqualToDataTypeNotEqualTo(String toolCode, String dataType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode],
              upper: [toolCode, dataType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode, dataType],
              includeLower: false,
              upper: [toolCode],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode, dataType],
              includeLower: false,
              upper: [toolCode],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolCode_dataType',
              lower: [toolCode],
              upper: [toolCode, dataType],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConverterToolsDataQueryFilter
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QFilterCondition> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataType',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      dataTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataType',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
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

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
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

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
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

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jsonData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonData',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      jsonDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonData',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadata',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadata',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      metadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toolCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toolCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      toolCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toolCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterFilterCondition>
      uniqueKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }
}

extension ConverterToolsDataQueryObject
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QFilterCondition> {}

extension ConverterToolsDataQueryLinks
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QFilterCondition> {}

extension ConverterToolsDataQuerySortBy
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QSortBy> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByDataType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByDataTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByJsonData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByJsonDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByToolCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByToolCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension ConverterToolsDataQuerySortThenBy
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QSortThenBy> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByDataType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByDataTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByJsonData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByJsonDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByToolCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByToolCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.desc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension ConverterToolsDataQueryWhereDistinct
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct> {
  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByDataType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByJsonData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByMetadata({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadata', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByToolCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toolCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConverterToolsData, ConverterToolsData, QDistinct>
      distinctByUniqueKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueKey', caseSensitive: caseSensitive);
    });
  }
}

extension ConverterToolsDataQueryProperty
    on QueryBuilder<ConverterToolsData, ConverterToolsData, QQueryProperty> {
  QueryBuilder<ConverterToolsData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConverterToolsData, String, QQueryOperations>
      dataTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataType');
    });
  }

  QueryBuilder<ConverterToolsData, String, QQueryOperations>
      jsonDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonData');
    });
  }

  QueryBuilder<ConverterToolsData, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ConverterToolsData, String?, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<ConverterToolsData, String, QQueryOperations>
      toolCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toolCode');
    });
  }

  QueryBuilder<ConverterToolsData, String, QQueryOperations>
      uniqueKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueKey');
    });
  }
}
