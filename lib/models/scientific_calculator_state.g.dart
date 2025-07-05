// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scientific_calculator_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetScientificCalculatorStateCollection on Isar {
  IsarCollection<ScientificCalculatorState> get scientificCalculatorStates =>
      this.collection();
}

const ScientificCalculatorStateSchema = CollectionSchema(
  name: r'ScientificCalculatorState',
  id: 5236484096215090705,
  properties: {
    r'calculationStack': PropertySchema(
      id: 0,
      name: r'calculationStack',
      type: IsarType.stringList,
    ),
    r'display': PropertySchema(
      id: 1,
      name: r'display',
      type: IsarType.string,
    ),
    r'expression': PropertySchema(
      id: 2,
      name: r'expression',
      type: IsarType.string,
    ),
    r'isRadians': PropertySchema(
      id: 3,
      name: r'isRadians',
      type: IsarType.bool,
    ),
    r'justCalculated': PropertySchema(
      id: 4,
      name: r'justCalculated',
      type: IsarType.bool,
    ),
    r'realTimeResult': PropertySchema(
      id: 5,
      name: r'realTimeResult',
      type: IsarType.string,
    ),
    r'showSecondaryFunctions': PropertySchema(
      id: 6,
      name: r'showSecondaryFunctions',
      type: IsarType.bool,
    )
  },
  estimateSize: _scientificCalculatorStateEstimateSize,
  serialize: _scientificCalculatorStateSerialize,
  deserialize: _scientificCalculatorStateDeserialize,
  deserializeProp: _scientificCalculatorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _scientificCalculatorStateGetId,
  getLinks: _scientificCalculatorStateGetLinks,
  attach: _scientificCalculatorStateAttach,
  version: '3.0.5',
);

int _scientificCalculatorStateEstimateSize(
  ScientificCalculatorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.calculationStack;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.display;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.expression;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.realTimeResult;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _scientificCalculatorStateSerialize(
  ScientificCalculatorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.calculationStack);
  writer.writeString(offsets[1], object.display);
  writer.writeString(offsets[2], object.expression);
  writer.writeBool(offsets[3], object.isRadians);
  writer.writeBool(offsets[4], object.justCalculated);
  writer.writeString(offsets[5], object.realTimeResult);
  writer.writeBool(offsets[6], object.showSecondaryFunctions);
}

ScientificCalculatorState _scientificCalculatorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScientificCalculatorState();
  object.calculationStack = reader.readStringList(offsets[0]);
  object.display = reader.readStringOrNull(offsets[1]);
  object.expression = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isRadians = reader.readBoolOrNull(offsets[3]);
  object.justCalculated = reader.readBoolOrNull(offsets[4]);
  object.realTimeResult = reader.readStringOrNull(offsets[5]);
  object.showSecondaryFunctions = reader.readBoolOrNull(offsets[6]);
  return object;
}

P _scientificCalculatorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scientificCalculatorStateGetId(ScientificCalculatorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scientificCalculatorStateGetLinks(
    ScientificCalculatorState object) {
  return [];
}

void _scientificCalculatorStateAttach(
    IsarCollection<dynamic> col, Id id, ScientificCalculatorState object) {
  object.id = id;
}

extension ScientificCalculatorStateQueryWhereSort on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QWhere> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScientificCalculatorStateQueryWhere on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QWhereClause> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
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

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
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

extension ScientificCalculatorStateQueryFilter on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QFilterCondition> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'calculationStack',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'calculationStack',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calculationStack',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      calculationStackElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'calculationStack',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      calculationStackElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'calculationStack',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculationStack',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'calculationStack',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> calculationStackLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'calculationStack',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'display',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'display',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'display',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      displayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'display',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      displayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'display',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'display',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> displayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'display',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expression',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expression',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expression',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      expressionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      expressionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expression',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expression',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> expressionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expression',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
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

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
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

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
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

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> isRadiansIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isRadians',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> isRadiansIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isRadians',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> isRadiansEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRadians',
        value: value,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> justCalculatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'justCalculated',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> justCalculatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'justCalculated',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> justCalculatedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'justCalculated',
        value: value,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'realTimeResult',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'realTimeResult',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realTimeResult',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      realTimeResultContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'realTimeResult',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
          QAfterFilterCondition>
      realTimeResultMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'realTimeResult',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realTimeResult',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> realTimeResultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'realTimeResult',
        value: '',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> showSecondaryFunctionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'showSecondaryFunctions',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> showSecondaryFunctionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'showSecondaryFunctions',
      ));
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterFilterCondition> showSecondaryFunctionsEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showSecondaryFunctions',
        value: value,
      ));
    });
  }
}

extension ScientificCalculatorStateQueryObject on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QFilterCondition> {}

extension ScientificCalculatorStateQueryLinks on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QFilterCondition> {}

extension ScientificCalculatorStateQuerySortBy on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QSortBy> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByDisplay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'display', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByDisplayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'display', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByExpression() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expression', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByExpressionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expression', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByIsRadians() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRadians', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByIsRadiansDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRadians', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByJustCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justCalculated', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByJustCalculatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justCalculated', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByRealTimeResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realTimeResult', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByRealTimeResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realTimeResult', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByShowSecondaryFunctions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSecondaryFunctions', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> sortByShowSecondaryFunctionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSecondaryFunctions', Sort.desc);
    });
  }
}

extension ScientificCalculatorStateQuerySortThenBy on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QSortThenBy> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByDisplay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'display', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByDisplayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'display', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByExpression() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expression', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByExpressionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expression', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByIsRadians() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRadians', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByIsRadiansDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRadians', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByJustCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justCalculated', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByJustCalculatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'justCalculated', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByRealTimeResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realTimeResult', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByRealTimeResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realTimeResult', Sort.desc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByShowSecondaryFunctions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSecondaryFunctions', Sort.asc);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState,
      QAfterSortBy> thenByShowSecondaryFunctionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSecondaryFunctions', Sort.desc);
    });
  }
}

extension ScientificCalculatorStateQueryWhereDistinct on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QDistinct> {
  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByCalculationStack() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calculationStack');
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByDisplay({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'display', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByExpression({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expression', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByIsRadians() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRadians');
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByJustCalculated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'justCalculated');
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByRealTimeResult({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realTimeResult',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScientificCalculatorState, ScientificCalculatorState, QDistinct>
      distinctByShowSecondaryFunctions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showSecondaryFunctions');
    });
  }
}

extension ScientificCalculatorStateQueryProperty on QueryBuilder<
    ScientificCalculatorState, ScientificCalculatorState, QQueryProperty> {
  QueryBuilder<ScientificCalculatorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScientificCalculatorState, List<String>?, QQueryOperations>
      calculationStackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculationStack');
    });
  }

  QueryBuilder<ScientificCalculatorState, String?, QQueryOperations>
      displayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'display');
    });
  }

  QueryBuilder<ScientificCalculatorState, String?, QQueryOperations>
      expressionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expression');
    });
  }

  QueryBuilder<ScientificCalculatorState, bool?, QQueryOperations>
      isRadiansProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRadians');
    });
  }

  QueryBuilder<ScientificCalculatorState, bool?, QQueryOperations>
      justCalculatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'justCalculated');
    });
  }

  QueryBuilder<ScientificCalculatorState, String?, QQueryOperations>
      realTimeResultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realTimeResult');
    });
  }

  QueryBuilder<ScientificCalculatorState, bool?, QQueryOperations>
      showSecondaryFunctionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showSecondaryFunctions');
    });
  }
}
