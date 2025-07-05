// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetLengthStateModelCollection on Isar {
  IsarCollection<LengthStateModel> get lengthStateModels => this.collection();
}

const LengthStateModelSchema = CollectionSchema(
  name: r'LengthStateModel',
  id: -1150259286716685091,
  properties: {
    r'cards': PropertySchema(
      id: 0,
      name: r'cards',
      type: IsarType.objectList,
      target: r'LengthCardState',
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
  estimateSize: _lengthStateModelEstimateSize,
  serialize: _lengthStateModelSerialize,
  deserialize: _lengthStateModelDeserialize,
  deserializeProp: _lengthStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'LengthCardState': LengthCardStateSchema},
  getId: _lengthStateModelGetId,
  getLinks: _lengthStateModelGetLinks,
  attach: _lengthStateModelAttach,
  version: '3.0.5',
);

int _lengthStateModelEstimateSize(
  LengthStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cards.length * 3;
  {
    final offsets = allOffsets[LengthCardState]!;
    for (var i = 0; i < object.cards.length; i++) {
      final value = object.cards[i];
      bytesCount +=
          LengthCardStateSchema.estimateSize(value, offsets, allOffsets);
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

void _lengthStateModelSerialize(
  LengthStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<LengthCardState>(
    offsets[0],
    allOffsets,
    LengthCardStateSchema.serialize,
    object.cards,
  );
  writer.writeBool(offsets[1], object.isFocusMode);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.viewMode);
  writer.writeStringList(offsets[4], object.visibleUnits);
}

LengthStateModel _lengthStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LengthStateModel();
  object.cards = reader.readObjectList<LengthCardState>(
        offsets[0],
        LengthCardStateSchema.deserialize,
        allOffsets,
        LengthCardState(),
      ) ??
      [];
  object.id = id;
  object.isFocusMode = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.viewMode = reader.readString(offsets[3]);
  object.visibleUnits = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _lengthStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<LengthCardState>(
            offset,
            LengthCardStateSchema.deserialize,
            allOffsets,
            LengthCardState(),
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

Id _lengthStateModelGetId(LengthStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lengthStateModelGetLinks(LengthStateModel object) {
  return [];
}

void _lengthStateModelAttach(
    IsarCollection<dynamic> col, Id id, LengthStateModel object) {
  object.id = id;
}

extension LengthStateModelQueryWhereSort
    on QueryBuilder<LengthStateModel, LengthStateModel, QWhere> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LengthStateModelQueryWhere
    on QueryBuilder<LengthStateModel, LengthStateModel, QWhereClause> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhereClause>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterWhereClause> idBetween(
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

extension LengthStateModelQueryFilter
    on QueryBuilder<LengthStateModel, LengthStateModel, QFilterCondition> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      isFocusModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFocusMode',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'viewMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
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

extension LengthStateModelQueryObject
    on QueryBuilder<LengthStateModel, LengthStateModel, QFilterCondition> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterFilterCondition>
      cardsElement(FilterQuery<LengthCardState> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cards');
    });
  }
}

extension LengthStateModelQueryLinks
    on QueryBuilder<LengthStateModel, LengthStateModel, QFilterCondition> {}

extension LengthStateModelQuerySortBy
    on QueryBuilder<LengthStateModel, LengthStateModel, QSortBy> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension LengthStateModelQuerySortThenBy
    on QueryBuilder<LengthStateModel, LengthStateModel, QSortThenBy> {
  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension LengthStateModelQueryWhereDistinct
    on QueryBuilder<LengthStateModel, LengthStateModel, QDistinct> {
  QueryBuilder<LengthStateModel, LengthStateModel, QDistinct>
      distinctByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFocusMode');
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QDistinct>
      distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LengthStateModel, LengthStateModel, QDistinct>
      distinctByVisibleUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibleUnits');
    });
  }
}

extension LengthStateModelQueryProperty
    on QueryBuilder<LengthStateModel, LengthStateModel, QQueryProperty> {
  QueryBuilder<LengthStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LengthStateModel, List<LengthCardState>, QQueryOperations>
      cardsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cards');
    });
  }

  QueryBuilder<LengthStateModel, bool, QQueryOperations> isFocusModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFocusMode');
    });
  }

  QueryBuilder<LengthStateModel, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<LengthStateModel, String, QQueryOperations> viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }

  QueryBuilder<LengthStateModel, List<String>, QQueryOperations>
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

const LengthCardStateSchema = Schema(
  name: r'LengthCardState',
  id: 2760429177905647182,
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
  estimateSize: _lengthCardStateEstimateSize,
  serialize: _lengthCardStateSerialize,
  deserialize: _lengthCardStateDeserialize,
  deserializeProp: _lengthCardStateDeserializeProp,
);

int _lengthCardStateEstimateSize(
  LengthCardState object,
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

void _lengthCardStateSerialize(
  LengthCardState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.unitCode);
  writer.writeStringList(offsets[3], object.visibleUnits);
}

LengthCardState _lengthCardStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LengthCardState(
    amount: reader.readDoubleOrNull(offsets[0]),
    name: reader.readStringOrNull(offsets[1]),
    unitCode: reader.readStringOrNull(offsets[2]),
    visibleUnits: reader.readStringList(offsets[3]),
  );
  return object;
}

P _lengthCardStateDeserializeProp<P>(
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

extension LengthCardStateQueryFilter
    on QueryBuilder<LengthCardState, LengthCardState, QFilterCondition> {
  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unitCode',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unitCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unitCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      unitCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'visibleUnits',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleUnits',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleUnits',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
      visibleUnitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleUnits',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

  QueryBuilder<LengthCardState, LengthCardState, QAfterFilterCondition>
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

extension LengthCardStateQueryObject
    on QueryBuilder<LengthCardState, LengthCardState, QFilterCondition> {}
