// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetTemperatureStateModelCollection on Isar {
  IsarCollection<TemperatureStateModel> get temperatureStateModels =>
      this.collection();
}

const TemperatureStateModelSchema = CollectionSchema(
  name: r'TemperatureStateModel',
  id: 4556600056083154976,
  properties: {
    r'cards': PropertySchema(
      id: 0,
      name: r'cards',
      type: IsarType.objectList,
      target: r'TemperatureCardState',
    ),
    r'isFocusMode': PropertySchema(
      id: 1,
      name: r'isFocusMode',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'viewMode': PropertySchema(
      id: 3,
      name: r'viewMode',
      type: IsarType.string,
    ),
    r'visibleUnits': PropertySchema(
      id: 4,
      name: r'visibleUnits',
      type: IsarType.stringList,
    )
  },
  estimateSize: _temperatureStateModelEstimateSize,
  serialize: _temperatureStateModelSerialize,
  deserialize: _temperatureStateModelDeserialize,
  deserializeProp: _temperatureStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'TemperatureCardState': TemperatureCardStateSchema},
  getId: _temperatureStateModelGetId,
  getLinks: _temperatureStateModelGetLinks,
  attach: _temperatureStateModelAttach,
  version: '3.0.5',
);

int _temperatureStateModelEstimateSize(
  TemperatureStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cards.length * 3;
  {
    final offsets = allOffsets[TemperatureCardState]!;
    for (var i = 0; i < object.cards.length; i++) {
      final value = object.cards[i];
      bytesCount +=
          TemperatureCardStateSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.viewMode.length * 3;
  bytesCount += 3 + object.visibleUnits.length * 3;
  {
    for (var i = 0; i < object.visibleUnits.length; i++) {
      final value = object.visibleUnits[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _temperatureStateModelSerialize(
  TemperatureStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<TemperatureCardState>(
    offsets[0],
    allOffsets,
    TemperatureCardStateSchema.serialize,
    object.cards,
  );
  writer.writeBool(offsets[1], object.isFocusMode);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.viewMode);
  writer.writeStringList(offsets[4], object.visibleUnits);
}

TemperatureStateModel _temperatureStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemperatureStateModel();
  object.cards = reader.readObjectList<TemperatureCardState>(
        offsets[0],
        TemperatureCardStateSchema.deserialize,
        allOffsets,
        TemperatureCardState(),
      ) ??
      [];
  object.id = id;
  object.isFocusMode = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.viewMode = reader.readString(offsets[3]);
  object.visibleUnits = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _temperatureStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<TemperatureCardState>(
            offset,
            TemperatureCardStateSchema.deserialize,
            allOffsets,
            TemperatureCardState(),
          ) ??
          []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _temperatureStateModelGetId(TemperatureStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _temperatureStateModelGetLinks(
    TemperatureStateModel object) {
  return [];
}

void _temperatureStateModelAttach(
    IsarCollection<dynamic> col, Id id, TemperatureStateModel object) {
  object.id = id;
}

extension TemperatureStateModelQueryWhereSort
    on QueryBuilder<TemperatureStateModel, TemperatureStateModel, QWhere> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TemperatureStateModelQueryWhere on QueryBuilder<TemperatureStateModel,
    TemperatureStateModel, QWhereClause> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhereClause>
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterWhereClause>
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

extension TemperatureStateModelQueryFilter on QueryBuilder<
    TemperatureStateModel, TemperatureStateModel, QFilterCondition> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cards',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> isFocusModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFocusMode',
        value: value,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
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

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
          QAfterFilterCondition>
      viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
          QAfterFilterCondition>
      viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'viewMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visibleUnits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
          QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
          QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> visibleUnitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TemperatureStateModelQueryObject on QueryBuilder<
    TemperatureStateModel, TemperatureStateModel, QFilterCondition> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel,
      QAfterFilterCondition> cardsElement(FilterQuery<TemperatureCardState> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cards');
    });
  }
}

extension TemperatureStateModelQueryLinks on QueryBuilder<TemperatureStateModel,
    TemperatureStateModel, QFilterCondition> {}

extension TemperatureStateModelQuerySortBy
    on QueryBuilder<TemperatureStateModel, TemperatureStateModel, QSortBy> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension TemperatureStateModelQuerySortThenBy
    on QueryBuilder<TemperatureStateModel, TemperatureStateModel, QSortThenBy> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension TemperatureStateModelQueryWhereDistinct
    on QueryBuilder<TemperatureStateModel, TemperatureStateModel, QDistinct> {
  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QDistinct>
      distinctByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFocusMode');
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QDistinct>
      distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemperatureStateModel, TemperatureStateModel, QDistinct>
      distinctByVisibleUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibleUnits');
    });
  }
}

extension TemperatureStateModelQueryProperty on QueryBuilder<
    TemperatureStateModel, TemperatureStateModel, QQueryProperty> {
  QueryBuilder<TemperatureStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TemperatureStateModel, List<TemperatureCardState>,
      QQueryOperations> cardsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cards');
    });
  }

  QueryBuilder<TemperatureStateModel, bool, QQueryOperations>
      isFocusModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFocusMode');
    });
  }

  QueryBuilder<TemperatureStateModel, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<TemperatureStateModel, String, QQueryOperations>
      viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }

  QueryBuilder<TemperatureStateModel, List<String>, QQueryOperations>
      visibleUnitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visibleUnits');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const TemperatureCardStateSchema = Schema(
  name: r'TemperatureCardState',
  id: 2187527017940670651,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'unitCode': PropertySchema(
      id: 2,
      name: r'unitCode',
      type: IsarType.string,
    ),
    r'visibleUnits': PropertySchema(
      id: 3,
      name: r'visibleUnits',
      type: IsarType.stringList,
    )
  },
  estimateSize: _temperatureCardStateEstimateSize,
  serialize: _temperatureCardStateSerialize,
  deserialize: _temperatureCardStateDeserialize,
  deserializeProp: _temperatureCardStateDeserializeProp,
);

int _temperatureCardStateEstimateSize(
  TemperatureCardState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.unitCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.visibleUnits;
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
  return bytesCount;
}

void _temperatureCardStateSerialize(
  TemperatureCardState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.unitCode);
  writer.writeStringList(offsets[3], object.visibleUnits);
}

TemperatureCardState _temperatureCardStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TemperatureCardState(
    amount: reader.readDoubleOrNull(offsets[0]),
    name: reader.readStringOrNull(offsets[1]),
    unitCode: reader.readStringOrNull(offsets[2]),
    visibleUnits: reader.readStringList(offsets[3]),
  );
  return object;
}

P _temperatureCardStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TemperatureCardStateQueryFilter on QueryBuilder<TemperatureCardState,
    TemperatureCardState, QFilterCondition> {
  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> amountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      unitCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      unitCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unitCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> unitCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visibleUnits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
          QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TemperatureCardState, TemperatureCardState,
      QAfterFilterCondition> visibleUnitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleUnits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TemperatureCardStateQueryObject on QueryBuilder<TemperatureCardState,
    TemperatureCardState, QFilterCondition> {}
