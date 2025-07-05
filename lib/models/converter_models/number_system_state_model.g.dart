// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'number_system_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetNumberSystemStateModelCollection on Isar {
  IsarCollection<NumberSystemStateModel> get numberSystemStateModels =>
      this.collection();
}

const NumberSystemStateModelSchema = CollectionSchema(
  name: r'NumberSystemStateModel',
  id: -1975871196050626921,
  properties: {
    r'cards': PropertySchema(
      id: 0,
      name: r'cards',
      type: IsarType.objectList,
      target: r'NumberSystemCardState',
    ),
    r'globalVisibleUnits': PropertySchema(
      id: 1,
      name: r'globalVisibleUnits',
      type: IsarType.stringList,
    ),
    r'isFocusMode': PropertySchema(
      id: 2,
      name: r'isFocusMode',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'viewMode': PropertySchema(
      id: 4,
      name: r'viewMode',
      type: IsarType.string,
    )
  },
  estimateSize: _numberSystemStateModelEstimateSize,
  serialize: _numberSystemStateModelSerialize,
  deserialize: _numberSystemStateModelDeserialize,
  deserializeProp: _numberSystemStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'NumberSystemCardState': NumberSystemCardStateSchema},
  getId: _numberSystemStateModelGetId,
  getLinks: _numberSystemStateModelGetLinks,
  attach: _numberSystemStateModelAttach,
  version: '3.0.5',
);

int _numberSystemStateModelEstimateSize(
  NumberSystemStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cards.length * 3;
  {
    final offsets = allOffsets[NumberSystemCardState]!;
    for (var i = 0; i < object.cards.length; i++) {
      final value = object.cards[i];
      bytesCount +=
          NumberSystemCardStateSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.globalVisibleUnits.length * 3;
  {
    for (var i = 0; i < object.globalVisibleUnits.length; i++) {
      final value = object.globalVisibleUnits[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.viewMode.length * 3;
  return bytesCount;
}

void _numberSystemStateModelSerialize(
  NumberSystemStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<NumberSystemCardState>(
    offsets[0],
    allOffsets,
    NumberSystemCardStateSchema.serialize,
    object.cards,
  );
  writer.writeStringList(offsets[1], object.globalVisibleUnits);
  writer.writeBool(offsets[2], object.isFocusMode);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeString(offsets[4], object.viewMode);
}

NumberSystemStateModel _numberSystemStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NumberSystemStateModel(
    cards: reader.readObjectList<NumberSystemCardState>(
          offsets[0],
          NumberSystemCardStateSchema.deserialize,
          allOffsets,
          NumberSystemCardState(),
        ) ??
        [],
    globalVisibleUnits: reader.readStringList(offsets[1]) ?? [],
    isFocusMode: reader.readBool(offsets[2]),
    lastUpdated: reader.readDateTime(offsets[3]),
    viewMode: reader.readString(offsets[4]),
  );
  object.id = id;
  return object;
}

P _numberSystemStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<NumberSystemCardState>(
            offset,
            NumberSystemCardStateSchema.deserialize,
            allOffsets,
            NumberSystemCardState(),
          ) ??
          []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _numberSystemStateModelGetId(NumberSystemStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _numberSystemStateModelGetLinks(
    NumberSystemStateModel object) {
  return [];
}

void _numberSystemStateModelAttach(
    IsarCollection<dynamic> col, Id id, NumberSystemStateModel object) {
  object.id = id;
}

extension NumberSystemStateModelQueryWhereSort
    on QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QWhere> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NumberSystemStateModelQueryWhere on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QWhereClause> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

extension NumberSystemStateModelQueryFilter on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QFilterCondition> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'globalVisibleUnits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
          QAfterFilterCondition>
      globalVisibleUnitsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'globalVisibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
          QAfterFilterCondition>
      globalVisibleUnitsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'globalVisibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'globalVisibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'globalVisibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> globalVisibleUnitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'globalVisibleUnits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> isFocusModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFocusMode',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> lastUpdatedGreaterThan(
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> lastUpdatedLessThan(
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> lastUpdatedBetween(
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
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

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
      QAfterFilterCondition> viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewMode',
        value: '',
      ));
    });
  }
}

extension NumberSystemStateModelQueryObject on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QFilterCondition> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel,
          QAfterFilterCondition>
      cardsElement(FilterQuery<NumberSystemCardState> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cards');
    });
  }
}

extension NumberSystemStateModelQueryLinks on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QFilterCondition> {}

extension NumberSystemStateModelQuerySortBy
    on QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QSortBy> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension NumberSystemStateModelQuerySortThenBy on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QSortThenBy> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension NumberSystemStateModelQueryWhereDistinct
    on QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QDistinct> {
  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QDistinct>
      distinctByGlobalVisibleUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'globalVisibleUnits');
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QDistinct>
      distinctByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFocusMode');
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<NumberSystemStateModel, NumberSystemStateModel, QDistinct>
      distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }
}

extension NumberSystemStateModelQueryProperty on QueryBuilder<
    NumberSystemStateModel, NumberSystemStateModel, QQueryProperty> {
  QueryBuilder<NumberSystemStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NumberSystemStateModel, List<NumberSystemCardState>,
      QQueryOperations> cardsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cards');
    });
  }

  QueryBuilder<NumberSystemStateModel, List<String>, QQueryOperations>
      globalVisibleUnitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'globalVisibleUnits');
    });
  }

  QueryBuilder<NumberSystemStateModel, bool, QQueryOperations>
      isFocusModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFocusMode');
    });
  }

  QueryBuilder<NumberSystemStateModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<NumberSystemStateModel, String, QQueryOperations>
      viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const NumberSystemCardStateSchema = Schema(
  name: r'NumberSystemCardState',
  id: 7668783176556565774,
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
  estimateSize: _numberSystemCardStateEstimateSize,
  serialize: _numberSystemCardStateSerialize,
  deserialize: _numberSystemCardStateDeserialize,
  deserializeProp: _numberSystemCardStateDeserializeProp,
);

int _numberSystemCardStateEstimateSize(
  NumberSystemCardState object,
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
  bytesCount += 3 + object.unitCode.length * 3;
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

void _numberSystemCardStateSerialize(
  NumberSystemCardState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.unitCode);
  writer.writeStringList(offsets[3], object.visibleUnits);
}

NumberSystemCardState _numberSystemCardStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NumberSystemCardState(
    amount: reader.readDoubleOrNull(offsets[0]) ?? 0.0,
    name: reader.readStringOrNull(offsets[1]),
    unitCode: reader.readStringOrNull(offsets[2]) ?? 'decimal',
    visibleUnits: reader.readStringList(offsets[3]),
  );
  return object;
}

P _numberSystemCardStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? 'decimal') as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension NumberSystemCardStateQueryFilter on QueryBuilder<
    NumberSystemCardState, NumberSystemCardState, QFilterCondition> {
  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> amountEqualTo(
    double value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> amountGreaterThan(
    double value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> amountLessThan(
    double value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeEqualTo(
    String value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeGreaterThan(
    String value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeLessThan(
    String value, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeBetween(
    String lower,
    String upper, {
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> unitCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> visibleUnitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> visibleUnitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
      QAfterFilterCondition> visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

  QueryBuilder<NumberSystemCardState, NumberSystemCardState,
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

extension NumberSystemCardStateQueryObject on QueryBuilder<
    NumberSystemCardState, NumberSystemCardState, QFilterCondition> {}
