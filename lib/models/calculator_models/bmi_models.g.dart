// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmi_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetBmiHistoryEntryCollection on Isar {
  IsarCollection<BmiHistoryEntry> get bmiHistoryEntrys => this.collection();
}

const BmiHistoryEntrySchema = CollectionSchema(
  name: r'BmiHistoryEntry',
  id: 3590145505753095761,
  properties: {
    r'calculationData': PropertySchema(
      id: 0,
      name: r'calculationData',
      type: IsarType.object,
      target: r'BmiCalculationData',
    ),
    r'data': PropertySchema(
      id: 1,
      name: r'data',
      type: IsarType.object,
      target: r'BmiData',
    )
  },
  estimateSize: _bmiHistoryEntryEstimateSize,
  serialize: _bmiHistoryEntrySerialize,
  deserialize: _bmiHistoryEntryDeserialize,
  deserializeProp: _bmiHistoryEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'BmiData': BmiDataSchema,
    r'BmiCalculationData': BmiCalculationDataSchema
  },
  getId: _bmiHistoryEntryGetId,
  getLinks: _bmiHistoryEntryGetLinks,
  attach: _bmiHistoryEntryAttach,
  version: '3.0.5',
);

int _bmiHistoryEntryEstimateSize(
  BmiHistoryEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 +
      BmiCalculationDataSchema.estimateSize(
          object.calculationData, allOffsets[BmiCalculationData]!, allOffsets);
  bytesCount += 3 +
      BmiDataSchema.estimateSize(object.data, allOffsets[BmiData]!, allOffsets);
  return bytesCount;
}

void _bmiHistoryEntrySerialize(
  BmiHistoryEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObject<BmiCalculationData>(
    offsets[0],
    allOffsets,
    BmiCalculationDataSchema.serialize,
    object.calculationData,
  );
  writer.writeObject<BmiData>(
    offsets[1],
    allOffsets,
    BmiDataSchema.serialize,
    object.data,
  );
}

BmiHistoryEntry _bmiHistoryEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BmiHistoryEntry();
  object.calculationData = reader.readObjectOrNull<BmiCalculationData>(
        offsets[0],
        BmiCalculationDataSchema.deserialize,
        allOffsets,
      ) ??
      BmiCalculationData();
  object.data = reader.readObjectOrNull<BmiData>(
        offsets[1],
        BmiDataSchema.deserialize,
        allOffsets,
      ) ??
      BmiData();
  object.id = id;
  return object;
}

P _bmiHistoryEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectOrNull<BmiCalculationData>(
            offset,
            BmiCalculationDataSchema.deserialize,
            allOffsets,
          ) ??
          BmiCalculationData()) as P;
    case 1:
      return (reader.readObjectOrNull<BmiData>(
            offset,
            BmiDataSchema.deserialize,
            allOffsets,
          ) ??
          BmiData()) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bmiHistoryEntryGetId(BmiHistoryEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bmiHistoryEntryGetLinks(BmiHistoryEntry object) {
  return [];
}

void _bmiHistoryEntryAttach(
    IsarCollection<dynamic> col, Id id, BmiHistoryEntry object) {
  object.id = id;
}

extension BmiHistoryEntryQueryWhereSort
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QWhere> {
  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BmiHistoryEntryQueryWhere
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QWhereClause> {
  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhereClause>
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

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterWhereClause> idBetween(
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

extension BmiHistoryEntryQueryFilter
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QFilterCondition> {
  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition>
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

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition>
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

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition>
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
}

extension BmiHistoryEntryQueryObject
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QFilterCondition> {
  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition>
      calculationData(FilterQuery<BmiCalculationData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'calculationData');
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterFilterCondition> data(
      FilterQuery<BmiData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'data');
    });
  }
}

extension BmiHistoryEntryQueryLinks
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QFilterCondition> {}

extension BmiHistoryEntryQuerySortBy
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QSortBy> {}

extension BmiHistoryEntryQuerySortThenBy
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QSortThenBy> {
  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension BmiHistoryEntryQueryWhereDistinct
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QDistinct> {}

extension BmiHistoryEntryQueryProperty
    on QueryBuilder<BmiHistoryEntry, BmiHistoryEntry, QQueryProperty> {
  QueryBuilder<BmiHistoryEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiCalculationData, QQueryOperations>
      calculationDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculationData');
    });
  }

  QueryBuilder<BmiHistoryEntry, BmiData, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const BmiDataSchema = Schema(
  name: r'BmiData',
  id: 708016119066849099,
  properties: {
    r'ageGroup': PropertySchema(
      id: 0,
      name: r'ageGroup',
      type: IsarType.byte,
      enumMap: _BmiDataageGroupEnumValueMap,
    ),
    r'calculatedAt': PropertySchema(
      id: 1,
      name: r'calculatedAt',
      type: IsarType.dateTime,
    ),
    r'gender': PropertySchema(
      id: 2,
      name: r'gender',
      type: IsarType.byte,
      enumMap: _BmiDatagenderEnumValueMap,
    ),
    r'height': PropertySchema(
      id: 3,
      name: r'height',
      type: IsarType.double,
    ),
    r'unitSystem': PropertySchema(
      id: 4,
      name: r'unitSystem',
      type: IsarType.byte,
      enumMap: _BmiDataunitSystemEnumValueMap,
    ),
    r'weight': PropertySchema(
      id: 5,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _bmiDataEstimateSize,
  serialize: _bmiDataSerialize,
  deserialize: _bmiDataDeserialize,
  deserializeProp: _bmiDataDeserializeProp,
);

int _bmiDataEstimateSize(
  BmiData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _bmiDataSerialize(
  BmiData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.ageGroup.index);
  writer.writeDateTime(offsets[1], object.calculatedAt);
  writer.writeByte(offsets[2], object.gender.index);
  writer.writeDouble(offsets[3], object.height);
  writer.writeByte(offsets[4], object.unitSystem.index);
  writer.writeDouble(offsets[5], object.weight);
}

BmiData _bmiDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BmiData();
  object.ageGroup =
      _BmiDataageGroupValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          AgeGroup.under18;
  object.calculatedAt = reader.readDateTime(offsets[1]);
  object.gender =
      _BmiDatagenderValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          Gender.male;
  object.height = reader.readDouble(offsets[3]);
  object.unitSystem =
      _BmiDataunitSystemValueEnumMap[reader.readByteOrNull(offsets[4])] ??
          UnitSystem.metric;
  object.weight = reader.readDouble(offsets[5]);
  return object;
}

P _bmiDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_BmiDataageGroupValueEnumMap[reader.readByteOrNull(offset)] ??
          AgeGroup.under18) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (_BmiDatagenderValueEnumMap[reader.readByteOrNull(offset)] ??
          Gender.male) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (_BmiDataunitSystemValueEnumMap[reader.readByteOrNull(offset)] ??
          UnitSystem.metric) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BmiDataageGroupEnumValueMap = {
  'under18': 0,
  'adult18Plus': 1,
};
const _BmiDataageGroupValueEnumMap = {
  0: AgeGroup.under18,
  1: AgeGroup.adult18Plus,
};
const _BmiDatagenderEnumValueMap = {
  'male': 0,
  'female': 1,
  'other': 2,
};
const _BmiDatagenderValueEnumMap = {
  0: Gender.male,
  1: Gender.female,
  2: Gender.other,
};
const _BmiDataunitSystemEnumValueMap = {
  'metric': 0,
  'imperial': 1,
};
const _BmiDataunitSystemValueEnumMap = {
  0: UnitSystem.metric,
  1: UnitSystem.imperial,
};

extension BmiDataQueryFilter
    on QueryBuilder<BmiData, BmiData, QFilterCondition> {
  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> ageGroupEqualTo(
      AgeGroup value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ageGroup',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> ageGroupGreaterThan(
    AgeGroup value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ageGroup',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> ageGroupLessThan(
    AgeGroup value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ageGroup',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> ageGroupBetween(
    AgeGroup lower,
    AgeGroup upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ageGroup',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> calculatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> calculatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calculatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> calculatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calculatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> calculatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calculatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> genderEqualTo(
      Gender value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> genderGreaterThan(
    Gender value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> genderLessThan(
    Gender value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> genderBetween(
    Gender lower,
    Gender upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> heightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> heightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> heightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> heightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> unitSystemEqualTo(
      UnitSystem value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitSystem',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> unitSystemGreaterThan(
    UnitSystem value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitSystem',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> unitSystemLessThan(
    UnitSystem value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitSystem',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> unitSystemBetween(
    UnitSystem lower,
    UnitSystem upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitSystem',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiData, BmiData, QAfterFilterCondition> weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BmiDataQueryObject
    on QueryBuilder<BmiData, BmiData, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const BmiCalculationDataSchema = Schema(
  name: r'BmiCalculationData',
  id: -7591033992794325016,
  properties: {
    r'bmi': PropertySchema(
      id: 0,
      name: r'bmi',
      type: IsarType.double,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.byte,
      enumMap: _BmiCalculationDatacategoryEnumValueMap,
    ),
    r'interpretation': PropertySchema(
      id: 2,
      name: r'interpretation',
      type: IsarType.string,
    ),
    r'recommendations': PropertySchema(
      id: 3,
      name: r'recommendations',
      type: IsarType.stringList,
    )
  },
  estimateSize: _bmiCalculationDataEstimateSize,
  serialize: _bmiCalculationDataSerialize,
  deserialize: _bmiCalculationDataDeserialize,
  deserializeProp: _bmiCalculationDataDeserializeProp,
);

int _bmiCalculationDataEstimateSize(
  BmiCalculationData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.interpretation.length * 3;
  bytesCount += 3 + object.recommendations.length * 3;
  {
    for (var i = 0; i < object.recommendations.length; i++) {
      final value = object.recommendations[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _bmiCalculationDataSerialize(
  BmiCalculationData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bmi);
  writer.writeByte(offsets[1], object.category.index);
  writer.writeString(offsets[2], object.interpretation);
  writer.writeStringList(offsets[3], object.recommendations);
}

BmiCalculationData _bmiCalculationDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BmiCalculationData();
  object.bmi = reader.readDouble(offsets[0]);
  object.category = _BmiCalculationDatacategoryValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      BmiCategory.underweight;
  object.interpretation = reader.readString(offsets[2]);
  object.recommendations = reader.readStringList(offsets[3]) ?? [];
  return object;
}

P _bmiCalculationDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (_BmiCalculationDatacategoryValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BmiCategory.underweight) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BmiCalculationDatacategoryEnumValueMap = {
  'underweight': 0,
  'normalWeight': 1,
  'overweightI': 2,
  'overweightII': 3,
  'obeseI': 4,
  'obeseII': 5,
  'obeseIII': 6,
};
const _BmiCalculationDatacategoryValueEnumMap = {
  0: BmiCategory.underweight,
  1: BmiCategory.normalWeight,
  2: BmiCategory.overweightI,
  3: BmiCategory.overweightII,
  4: BmiCategory.obeseI,
  5: BmiCategory.obeseII,
  6: BmiCategory.obeseIII,
};

extension BmiCalculationDataQueryFilter
    on QueryBuilder<BmiCalculationData, BmiCalculationData, QFilterCondition> {
  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      bmiEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      bmiGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      bmiLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bmi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      bmiBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bmi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      categoryEqualTo(BmiCategory value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      categoryGreaterThan(
    BmiCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      categoryLessThan(
    BmiCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      categoryBetween(
    BmiCategory lower,
    BmiCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interpretation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'interpretation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'interpretation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interpretation',
        value: '',
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      interpretationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'interpretation',
        value: '',
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendations',
        value: '',
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendations',
        value: '',
      ));
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BmiCalculationData, BmiCalculationData, QAfterFilterCondition>
      recommendationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recommendations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension BmiCalculationDataQueryObject
    on QueryBuilder<BmiCalculationData, BmiCalculationData, QFilterCondition> {}
