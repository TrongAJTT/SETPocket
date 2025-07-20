// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_tools_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCalculatorToolsDataCollection on Isar {
  IsarCollection<CalculatorToolsData> get calculatorToolsDatas =>
      this.collection();
}

const CalculatorToolsDataSchema = CollectionSchema(
  name: r'CalculatorToolsData',
  id: -949341117906944116,
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
  estimateSize: _calculatorToolsDataEstimateSize,
  serialize: _calculatorToolsDataSerialize,
  deserialize: _calculatorToolsDataDeserialize,
  deserializeProp: _calculatorToolsDataDeserializeProp,
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
  getId: _calculatorToolsDataGetId,
  getLinks: _calculatorToolsDataGetLinks,
  attach: _calculatorToolsDataAttach,
  version: '3.1.0+1',
);

int _calculatorToolsDataEstimateSize(
  CalculatorToolsData object,
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

void _calculatorToolsDataSerialize(
  CalculatorToolsData object,
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

CalculatorToolsData _calculatorToolsDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CalculatorToolsData();
  object.dataType = reader.readString(offsets[0]);
  object.id = id;
  object.jsonData = reader.readString(offsets[1]);
  object.lastUpdated = reader.readDateTime(offsets[2]);
  object.metadata = reader.readStringOrNull(offsets[3]);
  object.toolCode = reader.readString(offsets[4]);
  return object;
}

P _calculatorToolsDataDeserializeProp<P>(
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

Id _calculatorToolsDataGetId(CalculatorToolsData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _calculatorToolsDataGetLinks(
    CalculatorToolsData object) {
  return [];
}

void _calculatorToolsDataAttach(
    IsarCollection<dynamic> col, Id id, CalculatorToolsData object) {
  object.id = id;
}

extension CalculatorToolsDataByIndex on IsarCollection<CalculatorToolsData> {
  Future<CalculatorToolsData?> getByToolCodeDataType(
      String toolCode, String dataType) {
    return getByIndex(r'toolCode_dataType', [toolCode, dataType]);
  }

  CalculatorToolsData? getByToolCodeDataTypeSync(
      String toolCode, String dataType) {
    return getByIndexSync(r'toolCode_dataType', [toolCode, dataType]);
  }

  Future<bool> deleteByToolCodeDataType(String toolCode, String dataType) {
    return deleteByIndex(r'toolCode_dataType', [toolCode, dataType]);
  }

  bool deleteByToolCodeDataTypeSync(String toolCode, String dataType) {
    return deleteByIndexSync(r'toolCode_dataType', [toolCode, dataType]);
  }

  Future<List<CalculatorToolsData?>> getAllByToolCodeDataType(
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

  List<CalculatorToolsData?> getAllByToolCodeDataTypeSync(
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

  Future<Id> putByToolCodeDataType(CalculatorToolsData object) {
    return putByIndex(r'toolCode_dataType', object);
  }

  Id putByToolCodeDataTypeSync(CalculatorToolsData object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'toolCode_dataType', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByToolCodeDataType(List<CalculatorToolsData> objects) {
    return putAllByIndex(r'toolCode_dataType', objects);
  }

  List<Id> putAllByToolCodeDataTypeSync(List<CalculatorToolsData> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'toolCode_dataType', objects,
        saveLinks: saveLinks);
  }
}

extension CalculatorToolsDataQueryWhereSort
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QWhere> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CalculatorToolsDataQueryWhere
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QWhereClause> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
      toolCodeEqualToAnyDataType(String toolCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'toolCode_dataType',
        value: [toolCode],
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
      toolCodeDataTypeEqualTo(String toolCode, String dataType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'toolCode_dataType',
        value: [toolCode, dataType],
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterWhereClause>
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

extension CalculatorToolsDataQueryFilter on QueryBuilder<CalculatorToolsData,
    CalculatorToolsData, QFilterCondition> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      dataTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      dataTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      dataTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataType',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      dataTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataType',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      jsonDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      jsonDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      jsonDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonData',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      jsonDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonData',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadata',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadata',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadata',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      metadataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadata',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      toolCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toolCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      toolCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toolCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      toolCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      toolCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toolCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
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

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      uniqueKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      uniqueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      uniqueKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterFilterCondition>
      uniqueKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueKey',
        value: '',
      ));
    });
  }
}

extension CalculatorToolsDataQueryObject on QueryBuilder<CalculatorToolsData,
    CalculatorToolsData, QFilterCondition> {}

extension CalculatorToolsDataQueryLinks on QueryBuilder<CalculatorToolsData,
    CalculatorToolsData, QFilterCondition> {}

extension CalculatorToolsDataQuerySortBy
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QSortBy> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByDataType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByDataTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByJsonData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByJsonDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByToolCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByToolCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      sortByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension CalculatorToolsDataQuerySortThenBy
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QSortThenBy> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByDataType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByDataTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataType', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByJsonData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByJsonDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonData', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByMetadata() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByMetadataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadata', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByToolCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByToolCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolCode', Sort.desc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByUniqueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.asc);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QAfterSortBy>
      thenByUniqueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueKey', Sort.desc);
    });
  }
}

extension CalculatorToolsDataQueryWhereDistinct
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct> {
  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByDataType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByJsonData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByMetadata({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadata', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByToolCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toolCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalculatorToolsData, CalculatorToolsData, QDistinct>
      distinctByUniqueKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueKey', caseSensitive: caseSensitive);
    });
  }
}

extension CalculatorToolsDataQueryProperty
    on QueryBuilder<CalculatorToolsData, CalculatorToolsData, QQueryProperty> {
  QueryBuilder<CalculatorToolsData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CalculatorToolsData, String, QQueryOperations>
      dataTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataType');
    });
  }

  QueryBuilder<CalculatorToolsData, String, QQueryOperations>
      jsonDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonData');
    });
  }

  QueryBuilder<CalculatorToolsData, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<CalculatorToolsData, String?, QQueryOperations>
      metadataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadata');
    });
  }

  QueryBuilder<CalculatorToolsData, String, QQueryOperations>
      toolCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toolCode');
    });
  }

  QueryBuilder<CalculatorToolsData, String, QQueryOperations>
      uniqueKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueKey');
    });
  }
}
