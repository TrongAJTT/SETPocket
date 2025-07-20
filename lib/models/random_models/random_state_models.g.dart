// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_state_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNumberGeneratorStateCollection on Isar {
  IsarCollection<NumberGeneratorState> get numberGeneratorStates =>
      this.collection();
}

const NumberGeneratorStateSchema = CollectionSchema(
  name: r'NumberGeneratorState',
  id: -6870471639702179438,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'isInteger': PropertySchema(
      id: 1,
      name: r'isInteger',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'maxValue': PropertySchema(
      id: 3,
      name: r'maxValue',
      type: IsarType.double,
    ),
    r'minValue': PropertySchema(
      id: 4,
      name: r'minValue',
      type: IsarType.double,
    ),
    r'quantity': PropertySchema(
      id: 5,
      name: r'quantity',
      type: IsarType.long,
    )
  },
  estimateSize: _numberGeneratorStateEstimateSize,
  serialize: _numberGeneratorStateSerialize,
  deserialize: _numberGeneratorStateDeserialize,
  deserializeProp: _numberGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _numberGeneratorStateGetId,
  getLinks: _numberGeneratorStateGetLinks,
  attach: _numberGeneratorStateAttach,
  version: '3.1.0+1',
);

int _numberGeneratorStateEstimateSize(
  NumberGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _numberGeneratorStateSerialize(
  NumberGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeBool(offsets[1], object.isInteger);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeDouble(offsets[3], object.maxValue);
  writer.writeDouble(offsets[4], object.minValue);
  writer.writeLong(offsets[5], object.quantity);
}

NumberGeneratorState _numberGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NumberGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.id = id;
  object.isInteger = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.maxValue = reader.readDouble(offsets[3]);
  object.minValue = reader.readDouble(offsets[4]);
  object.quantity = reader.readLong(offsets[5]);
  return object;
}

P _numberGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _numberGeneratorStateGetId(NumberGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _numberGeneratorStateGetLinks(
    NumberGeneratorState object) {
  return [];
}

void _numberGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, NumberGeneratorState object) {
  object.id = id;
}

extension NumberGeneratorStateQueryWhereSort
    on QueryBuilder<NumberGeneratorState, NumberGeneratorState, QWhere> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NumberGeneratorStateQueryWhere
    on QueryBuilder<NumberGeneratorState, NumberGeneratorState, QWhereClause> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhereClause>
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterWhereClause>
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
}

extension NumberGeneratorStateQueryFilter on QueryBuilder<NumberGeneratorState,
    NumberGeneratorState, QFilterCondition> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> isIntegerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInteger',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> maxValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> maxValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> maxValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> maxValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> minValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> minValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> minValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> minValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState,
      QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NumberGeneratorStateQueryObject on QueryBuilder<NumberGeneratorState,
    NumberGeneratorState, QFilterCondition> {}

extension NumberGeneratorStateQueryLinks on QueryBuilder<NumberGeneratorState,
    NumberGeneratorState, QFilterCondition> {}

extension NumberGeneratorStateQuerySortBy
    on QueryBuilder<NumberGeneratorState, NumberGeneratorState, QSortBy> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByIsInteger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInteger', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByIsIntegerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInteger', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension NumberGeneratorStateQuerySortThenBy
    on QueryBuilder<NumberGeneratorState, NumberGeneratorState, QSortThenBy> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByIsInteger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInteger', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByIsIntegerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInteger', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension NumberGeneratorStateQueryWhereDistinct
    on QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct> {
  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByIsInteger() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInteger');
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxValue');
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minValue');
    });
  }

  QueryBuilder<NumberGeneratorState, NumberGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }
}

extension NumberGeneratorStateQueryProperty on QueryBuilder<
    NumberGeneratorState, NumberGeneratorState, QQueryProperty> {
  QueryBuilder<NumberGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NumberGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<NumberGeneratorState, bool, QQueryOperations>
      isIntegerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInteger');
    });
  }

  QueryBuilder<NumberGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<NumberGeneratorState, double, QQueryOperations>
      maxValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxValue');
    });
  }

  QueryBuilder<NumberGeneratorState, double, QQueryOperations>
      minValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minValue');
    });
  }

  QueryBuilder<NumberGeneratorState, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPasswordGeneratorStateCollection on Isar {
  IsarCollection<PasswordGeneratorState> get passwordGeneratorStates =>
      this.collection();
}

const PasswordGeneratorStateSchema = CollectionSchema(
  name: r'PasswordGeneratorState',
  id: 3145882875069307163,
  properties: {
    r'includeLowercase': PropertySchema(
      id: 0,
      name: r'includeLowercase',
      type: IsarType.bool,
    ),
    r'includeNumbers': PropertySchema(
      id: 1,
      name: r'includeNumbers',
      type: IsarType.bool,
    ),
    r'includeSpecial': PropertySchema(
      id: 2,
      name: r'includeSpecial',
      type: IsarType.bool,
    ),
    r'includeUppercase': PropertySchema(
      id: 3,
      name: r'includeUppercase',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'passwordLength': PropertySchema(
      id: 5,
      name: r'passwordLength',
      type: IsarType.long,
    )
  },
  estimateSize: _passwordGeneratorStateEstimateSize,
  serialize: _passwordGeneratorStateSerialize,
  deserialize: _passwordGeneratorStateDeserialize,
  deserializeProp: _passwordGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _passwordGeneratorStateGetId,
  getLinks: _passwordGeneratorStateGetLinks,
  attach: _passwordGeneratorStateAttach,
  version: '3.1.0+1',
);

int _passwordGeneratorStateEstimateSize(
  PasswordGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _passwordGeneratorStateSerialize(
  PasswordGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.includeLowercase);
  writer.writeBool(offsets[1], object.includeNumbers);
  writer.writeBool(offsets[2], object.includeSpecial);
  writer.writeBool(offsets[3], object.includeUppercase);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeLong(offsets[5], object.passwordLength);
}

PasswordGeneratorState _passwordGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PasswordGeneratorState();
  object.id = id;
  object.includeLowercase = reader.readBool(offsets[0]);
  object.includeNumbers = reader.readBool(offsets[1]);
  object.includeSpecial = reader.readBool(offsets[2]);
  object.includeUppercase = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[4]);
  object.passwordLength = reader.readLong(offsets[5]);
  return object;
}

P _passwordGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _passwordGeneratorStateGetId(PasswordGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _passwordGeneratorStateGetLinks(
    PasswordGeneratorState object) {
  return [];
}

void _passwordGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, PasswordGeneratorState object) {
  object.id = id;
}

extension PasswordGeneratorStateQueryWhereSort
    on QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QWhere> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PasswordGeneratorStateQueryWhere on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QWhereClause> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterWhereClause> idBetween(
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

extension PasswordGeneratorStateQueryFilter on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QFilterCondition> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> includeLowercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeLowercase',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> includeNumbersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeNumbers',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> includeSpecialEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeSpecial',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> includeUppercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeUppercase',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> passwordLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passwordLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> passwordLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'passwordLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> passwordLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'passwordLength',
        value: value,
      ));
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState,
      QAfterFilterCondition> passwordLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'passwordLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PasswordGeneratorStateQueryObject on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QFilterCondition> {}

extension PasswordGeneratorStateQueryLinks on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QFilterCondition> {}

extension PasswordGeneratorStateQuerySortBy
    on QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QSortBy> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeNumbersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeSpecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByIncludeUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByPasswordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordLength', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      sortByPasswordLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordLength', Sort.desc);
    });
  }
}

extension PasswordGeneratorStateQuerySortThenBy on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QSortThenBy> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeNumbersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeSpecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByIncludeUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByPasswordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordLength', Sort.asc);
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QAfterSortBy>
      thenByPasswordLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordLength', Sort.desc);
    });
  }
}

extension PasswordGeneratorStateQueryWhereDistinct
    on QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct> {
  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeLowercase');
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeNumbers');
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeSpecial');
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeUppercase');
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<PasswordGeneratorState, PasswordGeneratorState, QDistinct>
      distinctByPasswordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passwordLength');
    });
  }
}

extension PasswordGeneratorStateQueryProperty on QueryBuilder<
    PasswordGeneratorState, PasswordGeneratorState, QQueryProperty> {
  QueryBuilder<PasswordGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PasswordGeneratorState, bool, QQueryOperations>
      includeLowercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeLowercase');
    });
  }

  QueryBuilder<PasswordGeneratorState, bool, QQueryOperations>
      includeNumbersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeNumbers');
    });
  }

  QueryBuilder<PasswordGeneratorState, bool, QQueryOperations>
      includeSpecialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeSpecial');
    });
  }

  QueryBuilder<PasswordGeneratorState, bool, QQueryOperations>
      includeUppercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeUppercase');
    });
  }

  QueryBuilder<PasswordGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<PasswordGeneratorState, int, QQueryOperations>
      passwordLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passwordLength');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDateGeneratorStateCollection on Isar {
  IsarCollection<DateGeneratorState> get dateGeneratorStates =>
      this.collection();
}

const DateGeneratorStateSchema = CollectionSchema(
  name: r'DateGeneratorState',
  id: 5674200133836957957,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'dateCount': PropertySchema(
      id: 1,
      name: r'dateCount',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 2,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 4,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _dateGeneratorStateEstimateSize,
  serialize: _dateGeneratorStateSerialize,
  deserialize: _dateGeneratorStateDeserialize,
  deserializeProp: _dateGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dateGeneratorStateGetId,
  getLinks: _dateGeneratorStateGetLinks,
  attach: _dateGeneratorStateAttach,
  version: '3.1.0+1',
);

int _dateGeneratorStateEstimateSize(
  DateGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dateGeneratorStateSerialize(
  DateGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeLong(offsets[1], object.dateCount);
  writer.writeDateTime(offsets[2], object.endDate);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeDateTime(offsets[4], object.startDate);
}

DateGeneratorState _dateGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DateGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.dateCount = reader.readLong(offsets[1]);
  object.endDate = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[3]);
  object.startDate = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _dateGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dateGeneratorStateGetId(DateGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dateGeneratorStateGetLinks(
    DateGeneratorState object) {
  return [];
}

void _dateGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, DateGeneratorState object) {
  object.id = id;
}

extension DateGeneratorStateQueryWhereSort
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QWhere> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DateGeneratorStateQueryWhere
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QWhereClause> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhereClause>
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterWhereClause>
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
}

extension DateGeneratorStateQueryFilter
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QFilterCondition> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      dateCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      dateCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      dateCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      dateCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterFilterCondition>
      startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DateGeneratorStateQueryObject
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QFilterCondition> {}

extension DateGeneratorStateQueryLinks
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QFilterCondition> {}

extension DateGeneratorStateQuerySortBy
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QSortBy> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByDateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCount', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByDateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCount', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension DateGeneratorStateQuerySortThenBy
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QSortThenBy> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByDateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCount', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByDateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateCount', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension DateGeneratorStateQueryWhereDistinct
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct> {
  QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct>
      distinctByDateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateCount');
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct>
      distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<DateGeneratorState, DateGeneratorState, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension DateGeneratorStateQueryProperty
    on QueryBuilder<DateGeneratorState, DateGeneratorState, QQueryProperty> {
  QueryBuilder<DateGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DateGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<DateGeneratorState, int, QQueryOperations> dateCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateCount');
    });
  }

  QueryBuilder<DateGeneratorState, DateTime?, QQueryOperations>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<DateGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<DateGeneratorState, DateTime?, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetColorGeneratorStateCollection on Isar {
  IsarCollection<ColorGeneratorState> get colorGeneratorStates =>
      this.collection();
}

const ColorGeneratorStateSchema = CollectionSchema(
  name: r'ColorGeneratorState',
  id: -5728070979846270080,
  properties: {
    r'lastUpdated': PropertySchema(
      id: 0,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'withAlpha': PropertySchema(
      id: 1,
      name: r'withAlpha',
      type: IsarType.bool,
    )
  },
  estimateSize: _colorGeneratorStateEstimateSize,
  serialize: _colorGeneratorStateSerialize,
  deserialize: _colorGeneratorStateDeserialize,
  deserializeProp: _colorGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _colorGeneratorStateGetId,
  getLinks: _colorGeneratorStateGetLinks,
  attach: _colorGeneratorStateAttach,
  version: '3.1.0+1',
);

int _colorGeneratorStateEstimateSize(
  ColorGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _colorGeneratorStateSerialize(
  ColorGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastUpdated);
  writer.writeBool(offsets[1], object.withAlpha);
}

ColorGeneratorState _colorGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ColorGeneratorState();
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[0]);
  object.withAlpha = reader.readBool(offsets[1]);
  return object;
}

P _colorGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _colorGeneratorStateGetId(ColorGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _colorGeneratorStateGetLinks(
    ColorGeneratorState object) {
  return [];
}

void _colorGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, ColorGeneratorState object) {
  object.id = id;
}

extension ColorGeneratorStateQueryWhereSort
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QWhere> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ColorGeneratorStateQueryWhere
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QWhereClause> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhereClause>
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterWhereClause>
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
}

extension ColorGeneratorStateQueryFilter on QueryBuilder<ColorGeneratorState,
    ColorGeneratorState, QFilterCondition> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterFilterCondition>
      withAlphaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withAlpha',
        value: value,
      ));
    });
  }
}

extension ColorGeneratorStateQueryObject on QueryBuilder<ColorGeneratorState,
    ColorGeneratorState, QFilterCondition> {}

extension ColorGeneratorStateQueryLinks on QueryBuilder<ColorGeneratorState,
    ColorGeneratorState, QFilterCondition> {}

extension ColorGeneratorStateQuerySortBy
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QSortBy> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      sortByWithAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withAlpha', Sort.asc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      sortByWithAlphaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withAlpha', Sort.desc);
    });
  }
}

extension ColorGeneratorStateQuerySortThenBy
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QSortThenBy> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenByWithAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withAlpha', Sort.asc);
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QAfterSortBy>
      thenByWithAlphaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withAlpha', Sort.desc);
    });
  }
}

extension ColorGeneratorStateQueryWhereDistinct
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QDistinct> {
  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ColorGeneratorState, ColorGeneratorState, QDistinct>
      distinctByWithAlpha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'withAlpha');
    });
  }
}

extension ColorGeneratorStateQueryProperty
    on QueryBuilder<ColorGeneratorState, ColorGeneratorState, QQueryProperty> {
  QueryBuilder<ColorGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ColorGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ColorGeneratorState, bool, QQueryOperations>
      withAlphaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withAlpha');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDateTimeGeneratorStateCollection on Isar {
  IsarCollection<DateTimeGeneratorState> get dateTimeGeneratorStates =>
      this.collection();
}

const DateTimeGeneratorStateSchema = CollectionSchema(
  name: r'DateTimeGeneratorState',
  id: -1052635046332609604,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'dateTimeCount': PropertySchema(
      id: 1,
      name: r'dateTimeCount',
      type: IsarType.long,
    ),
    r'endDateTime': PropertySchema(
      id: 2,
      name: r'endDateTime',
      type: IsarType.dateTime,
    ),
    r'includeSeconds': PropertySchema(
      id: 3,
      name: r'includeSeconds',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'startDateTime': PropertySchema(
      id: 5,
      name: r'startDateTime',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _dateTimeGeneratorStateEstimateSize,
  serialize: _dateTimeGeneratorStateSerialize,
  deserialize: _dateTimeGeneratorStateDeserialize,
  deserializeProp: _dateTimeGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dateTimeGeneratorStateGetId,
  getLinks: _dateTimeGeneratorStateGetLinks,
  attach: _dateTimeGeneratorStateAttach,
  version: '3.1.0+1',
);

int _dateTimeGeneratorStateEstimateSize(
  DateTimeGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dateTimeGeneratorStateSerialize(
  DateTimeGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeLong(offsets[1], object.dateTimeCount);
  writer.writeDateTime(offsets[2], object.endDateTime);
  writer.writeBool(offsets[3], object.includeSeconds);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeDateTime(offsets[5], object.startDateTime);
}

DateTimeGeneratorState _dateTimeGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DateTimeGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.dateTimeCount = reader.readLong(offsets[1]);
  object.endDateTime = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.includeSeconds = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[4]);
  object.startDateTime = reader.readDateTimeOrNull(offsets[5]);
  return object;
}

P _dateTimeGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dateTimeGeneratorStateGetId(DateTimeGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dateTimeGeneratorStateGetLinks(
    DateTimeGeneratorState object) {
  return [];
}

void _dateTimeGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, DateTimeGeneratorState object) {
  object.id = id;
}

extension DateTimeGeneratorStateQueryWhereSort
    on QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QWhere> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DateTimeGeneratorStateQueryWhere on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QWhereClause> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterWhereClause> idBetween(
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

extension DateTimeGeneratorStateQueryFilter on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QFilterCondition> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> dateTimeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTimeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> dateTimeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTimeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> dateTimeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTimeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> dateTimeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTimeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDateTime',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDateTime',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> endDateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> includeSecondsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDateTime',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDateTime',
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState,
      QAfterFilterCondition> startDateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DateTimeGeneratorStateQueryObject on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QFilterCondition> {}

extension DateTimeGeneratorStateQueryLinks on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QFilterCondition> {}

extension DateTimeGeneratorStateQuerySortBy
    on QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QSortBy> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByDateTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTimeCount', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByDateTimeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTimeCount', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByEndDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByIncludeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      sortByStartDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.desc);
    });
  }
}

extension DateTimeGeneratorStateQuerySortThenBy on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QSortThenBy> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByDateTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTimeCount', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByDateTimeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTimeCount', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByEndDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDateTime', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByIncludeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.asc);
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QAfterSortBy>
      thenByStartDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDateTime', Sort.desc);
    });
  }
}

extension DateTimeGeneratorStateQueryWhereDistinct
    on QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct> {
  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByDateTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTimeCount');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByEndDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDateTime');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeSeconds');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTimeGeneratorState, QDistinct>
      distinctByStartDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDateTime');
    });
  }
}

extension DateTimeGeneratorStateQueryProperty on QueryBuilder<
    DateTimeGeneratorState, DateTimeGeneratorState, QQueryProperty> {
  QueryBuilder<DateTimeGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DateTimeGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<DateTimeGeneratorState, int, QQueryOperations>
      dateTimeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTimeCount');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTime?, QQueryOperations>
      endDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDateTime');
    });
  }

  QueryBuilder<DateTimeGeneratorState, bool, QQueryOperations>
      includeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeSeconds');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<DateTimeGeneratorState, DateTime?, QQueryOperations>
      startDateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDateTime');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimeGeneratorStateCollection on Isar {
  IsarCollection<TimeGeneratorState> get timeGeneratorStates =>
      this.collection();
}

const TimeGeneratorStateSchema = CollectionSchema(
  name: r'TimeGeneratorState',
  id: -2685172112002548250,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'endHour': PropertySchema(
      id: 1,
      name: r'endHour',
      type: IsarType.long,
    ),
    r'endMinute': PropertySchema(
      id: 2,
      name: r'endMinute',
      type: IsarType.long,
    ),
    r'includeSeconds': PropertySchema(
      id: 3,
      name: r'includeSeconds',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'startHour': PropertySchema(
      id: 5,
      name: r'startHour',
      type: IsarType.long,
    ),
    r'startMinute': PropertySchema(
      id: 6,
      name: r'startMinute',
      type: IsarType.long,
    ),
    r'timeCount': PropertySchema(
      id: 7,
      name: r'timeCount',
      type: IsarType.long,
    )
  },
  estimateSize: _timeGeneratorStateEstimateSize,
  serialize: _timeGeneratorStateSerialize,
  deserialize: _timeGeneratorStateDeserialize,
  deserializeProp: _timeGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _timeGeneratorStateGetId,
  getLinks: _timeGeneratorStateGetLinks,
  attach: _timeGeneratorStateAttach,
  version: '3.1.0+1',
);

int _timeGeneratorStateEstimateSize(
  TimeGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _timeGeneratorStateSerialize(
  TimeGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeLong(offsets[1], object.endHour);
  writer.writeLong(offsets[2], object.endMinute);
  writer.writeBool(offsets[3], object.includeSeconds);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeLong(offsets[5], object.startHour);
  writer.writeLong(offsets[6], object.startMinute);
  writer.writeLong(offsets[7], object.timeCount);
}

TimeGeneratorState _timeGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimeGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.endHour = reader.readLong(offsets[1]);
  object.endMinute = reader.readLong(offsets[2]);
  object.id = id;
  object.includeSeconds = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[4]);
  object.startHour = reader.readLong(offsets[5]);
  object.startMinute = reader.readLong(offsets[6]);
  object.timeCount = reader.readLong(offsets[7]);
  return object;
}

P _timeGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timeGeneratorStateGetId(TimeGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timeGeneratorStateGetLinks(
    TimeGeneratorState object) {
  return [];
}

void _timeGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, TimeGeneratorState object) {
  object.id = id;
}

extension TimeGeneratorStateQueryWhereSort
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QWhere> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TimeGeneratorStateQueryWhere
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QWhereClause> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhereClause>
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterWhereClause>
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
}

extension TimeGeneratorStateQueryFilter
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QFilterCondition> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      endMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      includeSecondsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      startMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      timeCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      timeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      timeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterFilterCondition>
      timeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimeGeneratorStateQueryObject
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QFilterCondition> {}

extension TimeGeneratorStateQueryLinks
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QFilterCondition> {}

extension TimeGeneratorStateQuerySortBy
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QSortBy> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByIncludeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeCount', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      sortByTimeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeCount', Sort.desc);
    });
  }
}

extension TimeGeneratorStateQuerySortThenBy
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QSortThenBy> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByIncludeSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSeconds', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeCount', Sort.asc);
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QAfterSortBy>
      thenByTimeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeCount', Sort.desc);
    });
  }
}

extension TimeGeneratorStateQueryWhereDistinct
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct> {
  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endHour');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMinute');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByIncludeSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeSeconds');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startHour');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMinute');
    });
  }

  QueryBuilder<TimeGeneratorState, TimeGeneratorState, QDistinct>
      distinctByTimeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeCount');
    });
  }
}

extension TimeGeneratorStateQueryProperty
    on QueryBuilder<TimeGeneratorState, TimeGeneratorState, QQueryProperty> {
  QueryBuilder<TimeGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimeGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<TimeGeneratorState, int, QQueryOperations> endHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endHour');
    });
  }

  QueryBuilder<TimeGeneratorState, int, QQueryOperations> endMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMinute');
    });
  }

  QueryBuilder<TimeGeneratorState, bool, QQueryOperations>
      includeSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeSeconds');
    });
  }

  QueryBuilder<TimeGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<TimeGeneratorState, int, QQueryOperations> startHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startHour');
    });
  }

  QueryBuilder<TimeGeneratorState, int, QQueryOperations>
      startMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMinute');
    });
  }

  QueryBuilder<TimeGeneratorState, int, QQueryOperations> timeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeCount');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSimpleGeneratorStateCollection on Isar {
  IsarCollection<SimpleGeneratorState> get simpleGeneratorStates =>
      this.collection();
}

const SimpleGeneratorStateSchema = CollectionSchema(
  name: r'SimpleGeneratorState',
  id: -2331032547444031588,
  properties: {
    r'lastUpdated': PropertySchema(
      id: 0,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'skipAnimation': PropertySchema(
      id: 1,
      name: r'skipAnimation',
      type: IsarType.bool,
    )
  },
  estimateSize: _simpleGeneratorStateEstimateSize,
  serialize: _simpleGeneratorStateSerialize,
  deserialize: _simpleGeneratorStateDeserialize,
  deserializeProp: _simpleGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _simpleGeneratorStateGetId,
  getLinks: _simpleGeneratorStateGetLinks,
  attach: _simpleGeneratorStateAttach,
  version: '3.1.0+1',
);

int _simpleGeneratorStateEstimateSize(
  SimpleGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _simpleGeneratorStateSerialize(
  SimpleGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastUpdated);
  writer.writeBool(offsets[1], object.skipAnimation);
}

SimpleGeneratorState _simpleGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SimpleGeneratorState();
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[0]);
  object.skipAnimation = reader.readBool(offsets[1]);
  return object;
}

P _simpleGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _simpleGeneratorStateGetId(SimpleGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _simpleGeneratorStateGetLinks(
    SimpleGeneratorState object) {
  return [];
}

void _simpleGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, SimpleGeneratorState object) {
  object.id = id;
}

extension SimpleGeneratorStateQueryWhereSort
    on QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QWhere> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SimpleGeneratorStateQueryWhere
    on QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QWhereClause> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhereClause>
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterWhereClause>
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
}

extension SimpleGeneratorStateQueryFilter on QueryBuilder<SimpleGeneratorState,
    SimpleGeneratorState, QFilterCondition> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState,
      QAfterFilterCondition> skipAnimationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipAnimation',
        value: value,
      ));
    });
  }
}

extension SimpleGeneratorStateQueryObject on QueryBuilder<SimpleGeneratorState,
    SimpleGeneratorState, QFilterCondition> {}

extension SimpleGeneratorStateQueryLinks on QueryBuilder<SimpleGeneratorState,
    SimpleGeneratorState, QFilterCondition> {}

extension SimpleGeneratorStateQuerySortBy
    on QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QSortBy> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      sortBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.asc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      sortBySkipAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.desc);
    });
  }
}

extension SimpleGeneratorStateQuerySortThenBy
    on QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QSortThenBy> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.asc);
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QAfterSortBy>
      thenBySkipAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.desc);
    });
  }
}

extension SimpleGeneratorStateQueryWhereDistinct
    on QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QDistinct> {
  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<SimpleGeneratorState, SimpleGeneratorState, QDistinct>
      distinctBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipAnimation');
    });
  }
}

extension SimpleGeneratorStateQueryProperty on QueryBuilder<
    SimpleGeneratorState, SimpleGeneratorState, QQueryProperty> {
  QueryBuilder<SimpleGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SimpleGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<SimpleGeneratorState, bool, QQueryOperations>
      skipAnimationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipAnimation');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUuidGeneratorStateCollection on Isar {
  IsarCollection<UuidGeneratorState> get uuidGeneratorStates =>
      this.collection();
}

const UuidGeneratorStateSchema = CollectionSchema(
  name: r'UuidGeneratorState',
  id: 7898149454024905870,
  properties: {
    r'lastUpdated': PropertySchema(
      id: 0,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'quantity': PropertySchema(
      id: 1,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'uppercase': PropertySchema(
      id: 2,
      name: r'uppercase',
      type: IsarType.bool,
    ),
    r'withHyphens': PropertySchema(
      id: 3,
      name: r'withHyphens',
      type: IsarType.bool,
    )
  },
  estimateSize: _uuidGeneratorStateEstimateSize,
  serialize: _uuidGeneratorStateSerialize,
  deserialize: _uuidGeneratorStateDeserialize,
  deserializeProp: _uuidGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _uuidGeneratorStateGetId,
  getLinks: _uuidGeneratorStateGetLinks,
  attach: _uuidGeneratorStateAttach,
  version: '3.1.0+1',
);

int _uuidGeneratorStateEstimateSize(
  UuidGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _uuidGeneratorStateSerialize(
  UuidGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastUpdated);
  writer.writeLong(offsets[1], object.quantity);
  writer.writeBool(offsets[2], object.uppercase);
  writer.writeBool(offsets[3], object.withHyphens);
}

UuidGeneratorState _uuidGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UuidGeneratorState();
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[0]);
  object.quantity = reader.readLong(offsets[1]);
  object.uppercase = reader.readBool(offsets[2]);
  object.withHyphens = reader.readBool(offsets[3]);
  return object;
}

P _uuidGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _uuidGeneratorStateGetId(UuidGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _uuidGeneratorStateGetLinks(
    UuidGeneratorState object) {
  return [];
}

void _uuidGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, UuidGeneratorState object) {
  object.id = id;
}

extension UuidGeneratorStateQueryWhereSort
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QWhere> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UuidGeneratorStateQueryWhere
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QWhereClause> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhereClause>
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterWhereClause>
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
}

extension UuidGeneratorStateQueryFilter
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QFilterCondition> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      uppercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uppercase',
        value: value,
      ));
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterFilterCondition>
      withHyphensEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'withHyphens',
        value: value,
      ));
    });
  }
}

extension UuidGeneratorStateQueryObject
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QFilterCondition> {}

extension UuidGeneratorStateQueryLinks
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QFilterCondition> {}

extension UuidGeneratorStateQuerySortBy
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QSortBy> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByWithHyphens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withHyphens', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      sortByWithHyphensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withHyphens', Sort.desc);
    });
  }
}

extension UuidGeneratorStateQuerySortThenBy
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QSortThenBy> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.desc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByWithHyphens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withHyphens', Sort.asc);
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QAfterSortBy>
      thenByWithHyphensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'withHyphens', Sort.desc);
    });
  }
}

extension UuidGeneratorStateQueryWhereDistinct
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QDistinct> {
  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QDistinct>
      distinctByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uppercase');
    });
  }

  QueryBuilder<UuidGeneratorState, UuidGeneratorState, QDistinct>
      distinctByWithHyphens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'withHyphens');
    });
  }
}

extension UuidGeneratorStateQueryProperty
    on QueryBuilder<UuidGeneratorState, UuidGeneratorState, QQueryProperty> {
  QueryBuilder<UuidGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UuidGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<UuidGeneratorState, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<UuidGeneratorState, bool, QQueryOperations> uppercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uppercase');
    });
  }

  QueryBuilder<UuidGeneratorState, bool, QQueryOperations>
      withHyphensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'withHyphens');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStringGeneratorStateCollection on Isar {
  IsarCollection<StringGeneratorState> get stringGeneratorStates =>
      this.collection();
}

const StringGeneratorStateSchema = CollectionSchema(
  name: r'StringGeneratorState',
  id: -7106958830527332572,
  properties: {
    r'includeLowercase': PropertySchema(
      id: 0,
      name: r'includeLowercase',
      type: IsarType.bool,
    ),
    r'includeNumbers': PropertySchema(
      id: 1,
      name: r'includeNumbers',
      type: IsarType.bool,
    ),
    r'includeSpecial': PropertySchema(
      id: 2,
      name: r'includeSpecial',
      type: IsarType.bool,
    ),
    r'includeUppercase': PropertySchema(
      id: 3,
      name: r'includeUppercase',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 4,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'quantity': PropertySchema(
      id: 5,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'stringLength': PropertySchema(
      id: 6,
      name: r'stringLength',
      type: IsarType.long,
    )
  },
  estimateSize: _stringGeneratorStateEstimateSize,
  serialize: _stringGeneratorStateSerialize,
  deserialize: _stringGeneratorStateDeserialize,
  deserializeProp: _stringGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _stringGeneratorStateGetId,
  getLinks: _stringGeneratorStateGetLinks,
  attach: _stringGeneratorStateAttach,
  version: '3.1.0+1',
);

int _stringGeneratorStateEstimateSize(
  StringGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _stringGeneratorStateSerialize(
  StringGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.includeLowercase);
  writer.writeBool(offsets[1], object.includeNumbers);
  writer.writeBool(offsets[2], object.includeSpecial);
  writer.writeBool(offsets[3], object.includeUppercase);
  writer.writeDateTime(offsets[4], object.lastUpdated);
  writer.writeLong(offsets[5], object.quantity);
  writer.writeLong(offsets[6], object.stringLength);
}

StringGeneratorState _stringGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StringGeneratorState();
  object.id = id;
  object.includeLowercase = reader.readBool(offsets[0]);
  object.includeNumbers = reader.readBool(offsets[1]);
  object.includeSpecial = reader.readBool(offsets[2]);
  object.includeUppercase = reader.readBool(offsets[3]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[4]);
  object.quantity = reader.readLong(offsets[5]);
  object.stringLength = reader.readLong(offsets[6]);
  return object;
}

P _stringGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stringGeneratorStateGetId(StringGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stringGeneratorStateGetLinks(
    StringGeneratorState object) {
  return [];
}

void _stringGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, StringGeneratorState object) {
  object.id = id;
}

extension StringGeneratorStateQueryWhereSort
    on QueryBuilder<StringGeneratorState, StringGeneratorState, QWhere> {
  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StringGeneratorStateQueryWhere
    on QueryBuilder<StringGeneratorState, StringGeneratorState, QWhereClause> {
  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhereClause>
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

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterWhereClause>
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
}

extension StringGeneratorStateQueryFilter on QueryBuilder<StringGeneratorState,
    StringGeneratorState, QFilterCondition> {
  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> includeLowercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeLowercase',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> includeNumbersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeNumbers',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> includeSpecialEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeSpecial',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> includeUppercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeUppercase',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> stringLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringLength',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> stringLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringLength',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> stringLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringLength',
        value: value,
      ));
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState,
      QAfterFilterCondition> stringLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StringGeneratorStateQueryObject on QueryBuilder<StringGeneratorState,
    StringGeneratorState, QFilterCondition> {}

extension StringGeneratorStateQueryLinks on QueryBuilder<StringGeneratorState,
    StringGeneratorState, QFilterCondition> {}

extension StringGeneratorStateQuerySortBy
    on QueryBuilder<StringGeneratorState, StringGeneratorState, QSortBy> {
  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeNumbersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeSpecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByIncludeUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByStringLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringLength', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      sortByStringLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringLength', Sort.desc);
    });
  }
}

extension StringGeneratorStateQuerySortThenBy
    on QueryBuilder<StringGeneratorState, StringGeneratorState, QSortThenBy> {
  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeLowercase', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeNumbersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeNumbers', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeSpecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeSpecial', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByIncludeUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeUppercase', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByStringLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringLength', Sort.asc);
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QAfterSortBy>
      thenByStringLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringLength', Sort.desc);
    });
  }
}

extension StringGeneratorStateQueryWhereDistinct
    on QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct> {
  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByIncludeLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeLowercase');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByIncludeNumbers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeNumbers');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByIncludeSpecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeSpecial');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByIncludeUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeUppercase');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<StringGeneratorState, StringGeneratorState, QDistinct>
      distinctByStringLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringLength');
    });
  }
}

extension StringGeneratorStateQueryProperty on QueryBuilder<
    StringGeneratorState, StringGeneratorState, QQueryProperty> {
  QueryBuilder<StringGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StringGeneratorState, bool, QQueryOperations>
      includeLowercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeLowercase');
    });
  }

  QueryBuilder<StringGeneratorState, bool, QQueryOperations>
      includeNumbersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeNumbers');
    });
  }

  QueryBuilder<StringGeneratorState, bool, QQueryOperations>
      includeSpecialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeSpecial');
    });
  }

  QueryBuilder<StringGeneratorState, bool, QQueryOperations>
      includeUppercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeUppercase');
    });
  }

  QueryBuilder<StringGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<StringGeneratorState, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<StringGeneratorState, int, QQueryOperations>
      stringLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringLength');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetListGeneratorStateCollection on Isar {
  IsarCollection<ListGeneratorState> get listGeneratorStates =>
      this.collection();
}

const ListGeneratorStateSchema = CollectionSchema(
  name: r'ListGeneratorState',
  id: -3118342959546359802,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'items': PropertySchema(
      id: 1,
      name: r'items',
      type: IsarType.string,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'shuffleResults': PropertySchema(
      id: 4,
      name: r'shuffleResults',
      type: IsarType.bool,
    )
  },
  estimateSize: _listGeneratorStateEstimateSize,
  serialize: _listGeneratorStateSerialize,
  deserialize: _listGeneratorStateDeserialize,
  deserializeProp: _listGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _listGeneratorStateGetId,
  getLinks: _listGeneratorStateGetLinks,
  attach: _listGeneratorStateAttach,
  version: '3.1.0+1',
);

int _listGeneratorStateEstimateSize(
  ListGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.items.length * 3;
  return bytesCount;
}

void _listGeneratorStateSerialize(
  ListGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeString(offsets[1], object.items);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeLong(offsets[3], object.quantity);
  writer.writeBool(offsets[4], object.shuffleResults);
}

ListGeneratorState _listGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ListGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.id = id;
  object.items = reader.readString(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.quantity = reader.readLong(offsets[3]);
  object.shuffleResults = reader.readBool(offsets[4]);
  return object;
}

P _listGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _listGeneratorStateGetId(ListGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _listGeneratorStateGetLinks(
    ListGeneratorState object) {
  return [];
}

void _listGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, ListGeneratorState object) {
  object.id = id;
}

extension ListGeneratorStateQueryWhereSort
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QWhere> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ListGeneratorStateQueryWhere
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QWhereClause> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhereClause>
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterWhereClause>
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
}

extension ListGeneratorStateQueryFilter
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QFilterCondition> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'items',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'items',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'items',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'items',
        value: '',
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'items',
        value: '',
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterFilterCondition>
      shuffleResultsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shuffleResults',
        value: value,
      ));
    });
  }
}

extension ListGeneratorStateQueryObject
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QFilterCondition> {}

extension ListGeneratorStateQueryLinks
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QFilterCondition> {}

extension ListGeneratorStateQuerySortBy
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QSortBy> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByItems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'items', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByItemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'items', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByShuffleResults() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleResults', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      sortByShuffleResultsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleResults', Sort.desc);
    });
  }
}

extension ListGeneratorStateQuerySortThenBy
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QSortThenBy> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByItems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'items', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByItemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'items', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByShuffleResults() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleResults', Sort.asc);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QAfterSortBy>
      thenByShuffleResultsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleResults', Sort.desc);
    });
  }
}

extension ListGeneratorStateQueryWhereDistinct
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct> {
  QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct>
      distinctByItems({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'items', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<ListGeneratorState, ListGeneratorState, QDistinct>
      distinctByShuffleResults() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shuffleResults');
    });
  }
}

extension ListGeneratorStateQueryProperty
    on QueryBuilder<ListGeneratorState, ListGeneratorState, QQueryProperty> {
  QueryBuilder<ListGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ListGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<ListGeneratorState, String, QQueryOperations> itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<ListGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ListGeneratorState, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<ListGeneratorState, bool, QQueryOperations>
      shuffleResultsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shuffleResults');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiceRollGeneratorStateCollection on Isar {
  IsarCollection<DiceRollGeneratorState> get diceRollGeneratorStates =>
      this.collection();
}

const DiceRollGeneratorStateSchema = CollectionSchema(
  name: r'DiceRollGeneratorState',
  id: 858777766865356202,
  properties: {
    r'diceCount': PropertySchema(
      id: 0,
      name: r'diceCount',
      type: IsarType.long,
    ),
    r'diceSides': PropertySchema(
      id: 1,
      name: r'diceSides',
      type: IsarType.long,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'showSum': PropertySchema(
      id: 3,
      name: r'showSum',
      type: IsarType.bool,
    )
  },
  estimateSize: _diceRollGeneratorStateEstimateSize,
  serialize: _diceRollGeneratorStateSerialize,
  deserialize: _diceRollGeneratorStateDeserialize,
  deserializeProp: _diceRollGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _diceRollGeneratorStateGetId,
  getLinks: _diceRollGeneratorStateGetLinks,
  attach: _diceRollGeneratorStateAttach,
  version: '3.1.0+1',
);

int _diceRollGeneratorStateEstimateSize(
  DiceRollGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _diceRollGeneratorStateSerialize(
  DiceRollGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.diceCount);
  writer.writeLong(offsets[1], object.diceSides);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeBool(offsets[3], object.showSum);
}

DiceRollGeneratorState _diceRollGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiceRollGeneratorState();
  object.diceCount = reader.readLong(offsets[0]);
  object.diceSides = reader.readLong(offsets[1]);
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.showSum = reader.readBool(offsets[3]);
  return object;
}

P _diceRollGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _diceRollGeneratorStateGetId(DiceRollGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _diceRollGeneratorStateGetLinks(
    DiceRollGeneratorState object) {
  return [];
}

void _diceRollGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, DiceRollGeneratorState object) {
  object.id = id;
}

extension DiceRollGeneratorStateQueryWhereSort
    on QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QWhere> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiceRollGeneratorStateQueryWhere on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QWhereClause> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterWhereClause> idBetween(
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

extension DiceRollGeneratorStateQueryFilter on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QFilterCondition> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diceCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceSidesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diceSides',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceSidesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diceSides',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceSidesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diceSides',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> diceSidesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diceSides',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState,
      QAfterFilterCondition> showSumEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showSum',
        value: value,
      ));
    });
  }
}

extension DiceRollGeneratorStateQueryObject on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QFilterCondition> {}

extension DiceRollGeneratorStateQueryLinks on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QFilterCondition> {}

extension DiceRollGeneratorStateQuerySortBy
    on QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QSortBy> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByDiceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceCount', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByDiceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceCount', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByDiceSides() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceSides', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByDiceSidesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceSides', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByShowSum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSum', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      sortByShowSumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSum', Sort.desc);
    });
  }
}

extension DiceRollGeneratorStateQuerySortThenBy on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QSortThenBy> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByDiceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceCount', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByDiceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceCount', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByDiceSides() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceSides', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByDiceSidesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diceSides', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByShowSum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSum', Sort.asc);
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QAfterSortBy>
      thenByShowSumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSum', Sort.desc);
    });
  }
}

extension DiceRollGeneratorStateQueryWhereDistinct
    on QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QDistinct> {
  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QDistinct>
      distinctByDiceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diceCount');
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QDistinct>
      distinctByDiceSides() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diceSides');
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<DiceRollGeneratorState, DiceRollGeneratorState, QDistinct>
      distinctByShowSum() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showSum');
    });
  }
}

extension DiceRollGeneratorStateQueryProperty on QueryBuilder<
    DiceRollGeneratorState, DiceRollGeneratorState, QQueryProperty> {
  QueryBuilder<DiceRollGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiceRollGeneratorState, int, QQueryOperations>
      diceCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diceCount');
    });
  }

  QueryBuilder<DiceRollGeneratorState, int, QQueryOperations>
      diceSidesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diceSides');
    });
  }

  QueryBuilder<DiceRollGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<DiceRollGeneratorState, bool, QQueryOperations>
      showSumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showSum');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLatinLetterGeneratorStateCollection on Isar {
  IsarCollection<LatinLetterGeneratorState> get latinLetterGeneratorStates =>
      this.collection();
}

const LatinLetterGeneratorStateSchema = CollectionSchema(
  name: r'LatinLetterGeneratorState',
  id: -112186655833231801,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 1,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'lowercase': PropertySchema(
      id: 2,
      name: r'lowercase',
      type: IsarType.bool,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'skipAnimation': PropertySchema(
      id: 4,
      name: r'skipAnimation',
      type: IsarType.bool,
    ),
    r'uppercase': PropertySchema(
      id: 5,
      name: r'uppercase',
      type: IsarType.bool,
    )
  },
  estimateSize: _latinLetterGeneratorStateEstimateSize,
  serialize: _latinLetterGeneratorStateSerialize,
  deserialize: _latinLetterGeneratorStateDeserialize,
  deserializeProp: _latinLetterGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _latinLetterGeneratorStateGetId,
  getLinks: _latinLetterGeneratorStateGetLinks,
  attach: _latinLetterGeneratorStateAttach,
  version: '3.1.0+1',
);

int _latinLetterGeneratorStateEstimateSize(
  LatinLetterGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _latinLetterGeneratorStateSerialize(
  LatinLetterGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeDateTime(offsets[1], object.lastUpdated);
  writer.writeBool(offsets[2], object.lowercase);
  writer.writeLong(offsets[3], object.quantity);
  writer.writeBool(offsets[4], object.skipAnimation);
  writer.writeBool(offsets[5], object.uppercase);
}

LatinLetterGeneratorState _latinLetterGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LatinLetterGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.id = id;
  object.lastUpdated = reader.readDateTimeOrNull(offsets[1]);
  object.lowercase = reader.readBool(offsets[2]);
  object.quantity = reader.readLong(offsets[3]);
  object.skipAnimation = reader.readBool(offsets[4]);
  object.uppercase = reader.readBool(offsets[5]);
  return object;
}

P _latinLetterGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _latinLetterGeneratorStateGetId(LatinLetterGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _latinLetterGeneratorStateGetLinks(
    LatinLetterGeneratorState object) {
  return [];
}

void _latinLetterGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, LatinLetterGeneratorState object) {
  object.id = id;
}

extension LatinLetterGeneratorStateQueryWhereSort on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QWhere> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LatinLetterGeneratorStateQueryWhere on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QWhereClause> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterWhereClause> idBetween(
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

extension LatinLetterGeneratorStateQueryFilter on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QFilterCondition> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> lowercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lowercase',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> skipAnimationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipAnimation',
        value: value,
      ));
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterFilterCondition> uppercaseEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uppercase',
        value: value,
      ));
    });
  }
}

extension LatinLetterGeneratorStateQueryObject on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QFilterCondition> {}

extension LatinLetterGeneratorStateQueryLinks on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QFilterCondition> {}

extension LatinLetterGeneratorStateQuerySortBy on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QSortBy> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowercase', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowercase', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortBySkipAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> sortByUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.desc);
    });
  }
}

extension LatinLetterGeneratorStateQuerySortThenBy on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QSortThenBy> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowercase', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByLowercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowercase', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenBySkipAnimationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipAnimation', Sort.desc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.asc);
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState,
      QAfterSortBy> thenByUppercaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uppercase', Sort.desc);
    });
  }
}

extension LatinLetterGeneratorStateQueryWhereDistinct on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct> {
  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctByLowercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lowercase');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctBySkipAnimation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipAnimation');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, LatinLetterGeneratorState, QDistinct>
      distinctByUppercase() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uppercase');
    });
  }
}

extension LatinLetterGeneratorStateQueryProperty on QueryBuilder<
    LatinLetterGeneratorState, LatinLetterGeneratorState, QQueryProperty> {
  QueryBuilder<LatinLetterGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, bool, QQueryOperations>
      lowercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lowercase');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, int, QQueryOperations>
      quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, bool, QQueryOperations>
      skipAnimationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipAnimation');
    });
  }

  QueryBuilder<LatinLetterGeneratorState, bool, QQueryOperations>
      uppercaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uppercase');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayingCardGeneratorStateCollection on Isar {
  IsarCollection<PlayingCardGeneratorState> get playingCardGeneratorStates =>
      this.collection();
}

const PlayingCardGeneratorStateSchema = CollectionSchema(
  name: r'PlayingCardGeneratorState',
  id: -4041564923094062239,
  properties: {
    r'allowDuplicates': PropertySchema(
      id: 0,
      name: r'allowDuplicates',
      type: IsarType.bool,
    ),
    r'includeJokers': PropertySchema(
      id: 1,
      name: r'includeJokers',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'quantity': PropertySchema(
      id: 3,
      name: r'quantity',
      type: IsarType.long,
    )
  },
  estimateSize: _playingCardGeneratorStateEstimateSize,
  serialize: _playingCardGeneratorStateSerialize,
  deserialize: _playingCardGeneratorStateDeserialize,
  deserializeProp: _playingCardGeneratorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _playingCardGeneratorStateGetId,
  getLinks: _playingCardGeneratorStateGetLinks,
  attach: _playingCardGeneratorStateAttach,
  version: '3.1.0+1',
);

int _playingCardGeneratorStateEstimateSize(
  PlayingCardGeneratorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _playingCardGeneratorStateSerialize(
  PlayingCardGeneratorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.allowDuplicates);
  writer.writeBool(offsets[1], object.includeJokers);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeLong(offsets[3], object.quantity);
}

PlayingCardGeneratorState _playingCardGeneratorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayingCardGeneratorState();
  object.allowDuplicates = reader.readBool(offsets[0]);
  object.id = id;
  object.includeJokers = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.quantity = reader.readLong(offsets[3]);
  return object;
}

P _playingCardGeneratorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playingCardGeneratorStateGetId(PlayingCardGeneratorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playingCardGeneratorStateGetLinks(
    PlayingCardGeneratorState object) {
  return [];
}

void _playingCardGeneratorStateAttach(
    IsarCollection<dynamic> col, Id id, PlayingCardGeneratorState object) {
  object.id = id;
}

extension PlayingCardGeneratorStateQueryWhereSort on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QWhere> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayingCardGeneratorStateQueryWhere on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QWhereClause> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterWhereClause> idBetween(
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

extension PlayingCardGeneratorStateQueryFilter on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QFilterCondition> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> allowDuplicatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowDuplicates',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> includeJokersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'includeJokers',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime? value, {
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime? value, {
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayingCardGeneratorStateQueryObject on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QFilterCondition> {}

extension PlayingCardGeneratorStateQueryLinks on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QFilterCondition> {}

extension PlayingCardGeneratorStateQuerySortBy on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QSortBy> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByIncludeJokers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeJokers', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByIncludeJokersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeJokers', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension PlayingCardGeneratorStateQuerySortThenBy on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QSortThenBy> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByAllowDuplicatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allowDuplicates', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByIncludeJokers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeJokers', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByIncludeJokersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'includeJokers', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState,
      QAfterSortBy> thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }
}

extension PlayingCardGeneratorStateQueryWhereDistinct on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QDistinct> {
  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState, QDistinct>
      distinctByAllowDuplicates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowDuplicates');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState, QDistinct>
      distinctByIncludeJokers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'includeJokers');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, PlayingCardGeneratorState, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }
}

extension PlayingCardGeneratorStateQueryProperty on QueryBuilder<
    PlayingCardGeneratorState, PlayingCardGeneratorState, QQueryProperty> {
  QueryBuilder<PlayingCardGeneratorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, bool, QQueryOperations>
      allowDuplicatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowDuplicates');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, bool, QQueryOperations>
      includeJokersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'includeJokers');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<PlayingCardGeneratorState, int, QQueryOperations>
      quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }
}
