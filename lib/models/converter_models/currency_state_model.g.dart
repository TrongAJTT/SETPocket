// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_state_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetCurrencyStateModelCollection on Isar {
  IsarCollection<CurrencyStateModel> get currencyStateModels =>
      this.collection();
}

const CurrencyStateModelSchema = CollectionSchema(
  name: r'CurrencyStateModel',
  id: 2404266216728252849,
  properties: {
    r'cards': PropertySchema(
      id: 0,
      name: r'cards',
      type: IsarType.objectList,
      target: r'CurrencyCardState',
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
    r'visibleCurrencies': PropertySchema(
      id: 4,
      name: r'visibleCurrencies',
      type: IsarType.stringList,
    )
  },
  estimateSize: _currencyStateModelEstimateSize,
  serialize: _currencyStateModelSerialize,
  deserialize: _currencyStateModelDeserialize,
  deserializeProp: _currencyStateModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'CurrencyCardState': CurrencyCardStateSchema},
  getId: _currencyStateModelGetId,
  getLinks: _currencyStateModelGetLinks,
  attach: _currencyStateModelAttach,
  version: '3.0.5',
);

int _currencyStateModelEstimateSize(
  CurrencyStateModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cards.length * 3;
  {
    final offsets = allOffsets[CurrencyCardState]!;
    for (var i = 0; i < object.cards.length; i++) {
      final value = object.cards[i];
      bytesCount +=
          CurrencyCardStateSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.viewMode.length * 3;
  bytesCount += 3 + object.visibleCurrencies.length * 3;
  {
    for (var i = 0; i < object.visibleCurrencies.length; i++) {
      final value = object.visibleCurrencies[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _currencyStateModelSerialize(
  CurrencyStateModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<CurrencyCardState>(
    offsets[0],
    allOffsets,
    CurrencyCardStateSchema.serialize,
    object.cards,
  );
  writer.writeBool(offsets[1], object.isFocusMode);
  writer.writeDateTime(offsets[2], object.lastUpdated);
  writer.writeString(offsets[3], object.viewMode);
  writer.writeStringList(offsets[4], object.visibleCurrencies);
}

CurrencyStateModel _currencyStateModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyStateModel();
  object.cards = reader.readObjectList<CurrencyCardState>(
        offsets[0],
        CurrencyCardStateSchema.deserialize,
        allOffsets,
        CurrencyCardState(),
      ) ??
      [];
  object.id = id;
  object.isFocusMode = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTimeOrNull(offsets[2]);
  object.viewMode = reader.readString(offsets[3]);
  object.visibleCurrencies = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _currencyStateModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<CurrencyCardState>(
            offset,
            CurrencyCardStateSchema.deserialize,
            allOffsets,
            CurrencyCardState(),
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

Id _currencyStateModelGetId(CurrencyStateModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _currencyStateModelGetLinks(
    CurrencyStateModel object) {
  return [];
}

void _currencyStateModelAttach(
    IsarCollection<dynamic> col, Id id, CurrencyStateModel object) {
  object.id = id;
}

extension CurrencyStateModelQueryWhereSort
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QWhere> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurrencyStateModelQueryWhere
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QWhereClause> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhereClause>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterWhereClause>
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

extension CurrencyStateModelQueryFilter
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QFilterCondition> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      isFocusModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFocusMode',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      lastUpdatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      lastUpdatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdated',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      viewModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'viewMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      viewModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'viewMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      viewModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      viewModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'viewMode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visibleCurrencies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visibleCurrencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visibleCurrencies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visibleCurrencies',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visibleCurrencies',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      visibleCurrenciesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visibleCurrencies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CurrencyStateModelQueryObject
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QFilterCondition> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterFilterCondition>
      cardsElement(FilterQuery<CurrencyCardState> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'cards');
    });
  }
}

extension CurrencyStateModelQueryLinks
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QFilterCondition> {}

extension CurrencyStateModelQuerySortBy
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QSortBy> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      sortByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension CurrencyStateModelQuerySortThenBy
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QSortThenBy> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByIsFocusModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFocusMode', Sort.desc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByViewMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.asc);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QAfterSortBy>
      thenByViewModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewMode', Sort.desc);
    });
  }
}

extension CurrencyStateModelQueryWhereDistinct
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QDistinct> {
  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QDistinct>
      distinctByIsFocusMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFocusMode');
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QDistinct>
      distinctByViewMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrencyStateModel, CurrencyStateModel, QDistinct>
      distinctByVisibleCurrencies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visibleCurrencies');
    });
  }
}

extension CurrencyStateModelQueryProperty
    on QueryBuilder<CurrencyStateModel, CurrencyStateModel, QQueryProperty> {
  QueryBuilder<CurrencyStateModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CurrencyStateModel, List<CurrencyCardState>, QQueryOperations>
      cardsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cards');
    });
  }

  QueryBuilder<CurrencyStateModel, bool, QQueryOperations>
      isFocusModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFocusMode');
    });
  }

  QueryBuilder<CurrencyStateModel, DateTime?, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<CurrencyStateModel, String, QQueryOperations>
      viewModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewMode');
    });
  }

  QueryBuilder<CurrencyStateModel, List<String>, QQueryOperations>
      visibleCurrenciesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visibleCurrencies');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const CurrencyCardStateSchema = Schema(
  name: r'CurrencyCardState',
  id: -4394162323272627520,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'currencies': PropertySchema(
      id: 1,
      name: r'currencies',
      type: IsarType.stringList,
    ),
    r'currencyCode': PropertySchema(
      id: 2,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _currencyCardStateEstimateSize,
  serialize: _currencyCardStateSerialize,
  deserialize: _currencyCardStateDeserialize,
  deserializeProp: _currencyCardStateDeserializeProp,
);

int _currencyCardStateEstimateSize(
  CurrencyCardState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.currencies;
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
    final value = object.currencyCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _currencyCardStateSerialize(
  CurrencyCardState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeStringList(offsets[1], object.currencies);
  writer.writeString(offsets[2], object.currencyCode);
  writer.writeString(offsets[3], object.name);
}

CurrencyCardState _currencyCardStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyCardState(
    amount: reader.readDoubleOrNull(offsets[0]),
    currencies: reader.readStringList(offsets[1]),
    currencyCode: reader.readStringOrNull(offsets[2]),
    name: reader.readStringOrNull(offsets[3]),
  );
  return object;
}

P _currencyCardStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CurrencyCardStateQueryFilter
    on QueryBuilder<CurrencyCardState, CurrencyCardState, QFilterCondition> {
  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currencies',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currencies',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currencies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currencies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencies',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currencies',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currenciesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currencyCode',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currencyCode',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencyCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currencyCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currencyCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrencyCardState, CurrencyCardState, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CurrencyCardStateQueryObject
    on QueryBuilder<CurrencyCardState, CurrencyCardState, QFilterCondition> {}
