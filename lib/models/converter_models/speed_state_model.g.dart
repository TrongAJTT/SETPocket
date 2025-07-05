// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetSpeedStateModelCollection on Isar {
  IsarCollection<SpeedStateModel> get speedStateModels => this.collection();
}

const SpeedStateModelSchema = CollectionSchema(
  name: r'SpeedStateModel',
  id: -4847627486974637309,
  properties: {
    r'cards': PropertySchema(
      id: 0,
      name: r'cards',
      type: IsarType.objectList,
      target: r'SpeedCardState',
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
  estimateSize: _speedStateModelEstimateSize,
  serialize: _speedStateModelSerialize,
  deserialize: _speedStateModelDeserialize,
  deserializeProp: _speedStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'SpeedCardState': SpeedCardStateSchema},
  getId: _speedStateModelGetId,
  getLinks: _speedStateModelGetLinks,
  attach: _speedStateModelAttach,
  version: '3.0.5',
);

int _speedStateModelEstimateSize(
  SpeedStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cards.length * 3;
  {
    final offsets = allOffsets[SpeedCardState]!;
    for (var i = 0; i < object.cards.length; i++) {
      final value = object.cards[i];
      bytesCount +=
          SpeedCardStateSchema.estimateSize(value, offsets, allOffsets);
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

void _speedStateModelSerialize(
  SpeedStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<SpeedCardState>(
    offsets[0],
    allOffsets,
    SpeedCardStateSchema.serialize,
    object.cards,
  );
  writer.writeBool(offsets[1], object.isFocusMode);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.viewMode);
  writer.writeStringList(offsets[4], object.visibleUnits);
}

SpeedStateModel _speedStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SpeedStateModel();
  object.cards = reader.readObjectList<SpeedCardState>(
        offsets[0],
        SpeedCardStateSchema.deserialize,
        allOffsets,
        SpeedCardState(),
      ) ??
      [];
  object.id = id;
  object.isFocusMode = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.viewMode = reader.readString(offsets[3]);
  object.visibleUnits = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _speedStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<SpeedCardState>(
            offset,
            SpeedCardStateSchema.deserialize,
            allOffsets,
            SpeedCardState(),
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

Id _speedStateModelGetId(SpeedStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _speedStateModelGetLinks(SpeedStateModel object) {
  return [];
}

void _speedStateModelAttach(
    IsarCollection<dynamic> col, Id id, SpeedStateModel object) {
  object.id = id;
}

extension SpeedStateModelQueryWhereSort
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QWhere> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SpeedStateModelQueryWhere
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QWhereClause> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhereClause>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterWhereClause> idBetween(
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

extension SpeedStateModelQueryFilter
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QFilterCondition> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsLengthEqualTo(int length) {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsIsEmpty() {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsIsNotEmpty() {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsLengthLessThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsLengthGreaterThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsLengthBetween(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      isFocusModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFocusMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeEqualTo(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeGreaterThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeLessThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeBetween(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeStartsWith(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeEndsWith(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'viewMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementEqualTo(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementGreaterThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementLessThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementBetween(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementStartsWith(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementEndsWith(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsLengthEqualTo(int length) {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsIsEmpty() {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsIsNotEmpty() {
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsLengthLessThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsLengthGreaterThan(
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

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      visibleUnitsLengthBetween(
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

extension SpeedStateModelQueryObject
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QFilterCondition> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterFilterCondition>
      cardsElement(FilterQuery<SpeedCardState> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cards');
    });
  }
}

extension SpeedStateModelQueryLinks
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QFilterCondition> {}

extension SpeedStateModelQuerySortBy
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QSortBy> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension SpeedStateModelQuerySortThenBy
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QSortThenBy> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension SpeedStateModelQueryWhereDistinct
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QDistinct> {
  QueryBuilder<SpeedStateModel, SpeedStateModel, QDistinct>
      distinctByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFocusMode');
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QDistinct> distinctByViewMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpeedStateModel, SpeedStateModel, QDistinct>
      distinctByVisibleUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibleUnits');
    });
  }
}

extension SpeedStateModelQueryProperty
    on QueryBuilder<SpeedStateModel, SpeedStateModel, QQueryProperty> {
  QueryBuilder<SpeedStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SpeedStateModel, List<SpeedCardState>, QQueryOperations>
      cardsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cards');
    });
  }

  QueryBuilder<SpeedStateModel, bool, QQueryOperations> isFocusModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFocusMode');
    });
  }

  QueryBuilder<SpeedStateModel, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<SpeedStateModel, String, QQueryOperations> viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }

  QueryBuilder<SpeedStateModel, List<String>, QQueryOperations>
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

const SpeedCardStateSchema = Schema(
  name: r'SpeedCardState',
  id: 3487261898413708197,
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
  estimateSize: _speedCardStateEstimateSize,
  serialize: _speedCardStateSerialize,
  deserialize: _speedCardStateDeserialize,
  deserializeProp: _speedCardStateDeserializeProp,
);

int _speedCardStateEstimateSize(
  SpeedCardState object,
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

void _speedCardStateSerialize(
  SpeedCardState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.unitCode);
  writer.writeStringList(offsets[3], object.visibleUnits);
}

SpeedCardState _speedCardStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SpeedCardState(
    amount: reader.readDoubleOrNull(offsets[0]),
    name: reader.readStringOrNull(offsets[1]),
    unitCode: reader.readStringOrNull(offsets[2]),
    visibleUnits: reader.readStringList(offsets[3]),
  );
  return object;
}

P _speedCardStateDeserializeProp<P>(
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

extension SpeedCardStateQueryFilter
    on QueryBuilder<SpeedCardState, SpeedCardState, QFilterCondition> {
  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountEqualTo(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountGreaterThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountLessThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      amountBetween(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeEqualTo(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeGreaterThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeLessThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeBetween(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeStartsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeEndsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unitCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      unitCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementEqualTo(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementGreaterThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementLessThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementBetween(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementStartsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementEndsWith(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsLengthEqualTo(int length) {
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsIsEmpty() {
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsIsNotEmpty() {
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsLengthLessThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsLengthGreaterThan(
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

  QueryBuilder<SpeedCardState, SpeedCardState, QAfterFilterCondition>
      visibleUnitsLengthBetween(
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

extension SpeedCardStateQueryObject
    on QueryBuilder<SpeedCardState, SpeedCardState, QFilterCondition> {}
