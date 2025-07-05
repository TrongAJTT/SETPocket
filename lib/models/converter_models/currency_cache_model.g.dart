// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetCurrencyCacheModelCollection on Isar {
  IsarCollection<CurrencyCacheModel> get currencyCacheModels =>
      this.collection();
}

const CurrencyCacheModelSchema = CollectionSchema(
  name: r'CurrencyCacheModel',
  id: 6240116028331618211,
  properties: {
    r'currencyFetchTimes': PropertySchema(
      id: 0,
      name: r'currencyFetchTimes',
      type: IsarType.objectList,
      target: r'FetchTimeEntry',
    ),
    r'currencyStatuses': PropertySchema(
      id: 1,
      name: r'currencyStatuses',
      type: IsarType.objectList,
      target: r'StatusEntry',
    ),
    r'isValid': PropertySchema(
      id: 2,
      name: r'isValid',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'rates': PropertySchema(
      id: 4,
      name: r'rates',
      type: IsarType.objectList,
      target: r'RateEntry',
    )
  },
  estimateSize: _currencyCacheModelEstimateSize,
  serialize: _currencyCacheModelSerialize,
  deserialize: _currencyCacheModelDeserialize,
  deserializeProp: _currencyCacheModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'RateEntry': RateEntrySchema,
    r'StatusEntry': StatusEntrySchema,
    r'FetchTimeEntry': FetchTimeEntrySchema
  },
  getId: _currencyCacheModelGetId,
  getLinks: _currencyCacheModelGetLinks,
  attach: _currencyCacheModelAttach,
  version: '3.0.5',
);

int _currencyCacheModelEstimateSize(
  CurrencyCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currencyFetchTimes.length * 3;
  {
    final offsets = allOffsets[FetchTimeEntry]!;
    for (var i = 0; i < object.currencyFetchTimes.length; i++) {
      final value = object.currencyFetchTimes[i];
      bytesCount +=
          FetchTimeEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.currencyStatuses.length * 3;
  {
    final offsets = allOffsets[StatusEntry]!;
    for (var i = 0; i < object.currencyStatuses.length; i++) {
      final value = object.currencyStatuses[i];
      bytesCount += StatusEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.rates.length * 3;
  {
    final offsets = allOffsets[RateEntry]!;
    for (var i = 0; i < object.rates.length; i++) {
      final value = object.rates[i];
      bytesCount += RateEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _currencyCacheModelSerialize(
  CurrencyCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<FetchTimeEntry>(
    offsets[0],
    allOffsets,
    FetchTimeEntrySchema.serialize,
    object.currencyFetchTimes,
  );
  writer.writeObjectList<StatusEntry>(
    offsets[1],
    allOffsets,
    StatusEntrySchema.serialize,
    object.currencyStatuses,
  );
  writer.writeBool(offsets[2], object.isValid);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeObjectList<RateEntry>(
    offsets[4],
    allOffsets,
    RateEntrySchema.serialize,
    object.rates,
  );
}

CurrencyCacheModel _currencyCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyCacheModel(
    currencyFetchTimes: reader.readObjectList<FetchTimeEntry>(
          offsets[0],
          FetchTimeEntrySchema.deserialize,
          allOffsets,
          FetchTimeEntry(),
        ) ??
        const [],
    currencyStatuses: reader.readObjectList<StatusEntry>(
          offsets[1],
          StatusEntrySchema.deserialize,
          allOffsets,
          StatusEntry(),
        ) ??
        const [],
    isValid: reader.readBoolOrNull(offsets[2]) ?? true,
    lastUpdated: reader.readDateTime(offsets[3]),
    rates: reader.readObjectList<RateEntry>(
          offsets[4],
          RateEntrySchema.deserialize,
          allOffsets,
          RateEntry(),
        ) ??
        [],
  );
  object.id = id;
  return object;
}

P _currencyCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<FetchTimeEntry>(
            offset,
            FetchTimeEntrySchema.deserialize,
            allOffsets,
            FetchTimeEntry(),
          ) ??
          const []) as P;
    case 1:
      return (reader.readObjectList<StatusEntry>(
            offset,
            StatusEntrySchema.deserialize,
            allOffsets,
            StatusEntry(),
          ) ??
          const []) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readObjectList<RateEntry>(
            offset,
            RateEntrySchema.deserialize,
            allOffsets,
            RateEntry(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _currencyCacheModelGetId(CurrencyCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _currencyCacheModelGetLinks(
    CurrencyCacheModel object) {
  return [];
}

void _currencyCacheModelAttach(
    IsarCollection<dynamic> col, Id id, CurrencyCacheModel object) {
  object.id = id;
}

extension CurrencyCacheModelQueryWhereSort
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QWhere> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurrencyCacheModelQueryWhere
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QWhereClause> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhereClause>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterWhereClause>
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

extension CurrencyCacheModelQueryFilter
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QFilterCondition> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyFetchTimes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currencyStatuses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      isValidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isValid',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
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

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CurrencyCacheModelQueryObject
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QFilterCondition> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyFetchTimesElement(FilterQuery<FetchTimeEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'currencyFetchTimes');
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      currencyStatusesElement(FilterQuery<StatusEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'currencyStatuses');
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterFilterCondition>
      ratesElement(FilterQuery<RateEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'rates');
    });
  }
}

extension CurrencyCacheModelQueryLinks
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QFilterCondition> {}

extension CurrencyCacheModelQuerySortBy
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QSortBy> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      sortByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      sortByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension CurrencyCacheModelQuerySortThenBy
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QSortThenBy> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension CurrencyCacheModelQueryWhereDistinct
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QDistinct> {
  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QDistinct>
      distinctByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isValid');
    });
  }

  QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }
}

extension CurrencyCacheModelQueryProperty
    on QueryBuilder<CurrencyCacheModel, CurrencyCacheModel, QQueryProperty> {
  QueryBuilder<CurrencyCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CurrencyCacheModel, List<FetchTimeEntry>, QQueryOperations>
      currencyFetchTimesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyFetchTimes');
    });
  }

  QueryBuilder<CurrencyCacheModel, List<StatusEntry>, QQueryOperations>
      currencyStatusesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyStatuses');
    });
  }

  QueryBuilder<CurrencyCacheModel, bool, QQueryOperations> isValidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isValid');
    });
  }

  QueryBuilder<CurrencyCacheModel, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<CurrencyCacheModel, List<RateEntry>, QQueryOperations>
      ratesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rates');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const RateEntrySchema = Schema(
  name: r'RateEntry',
  id: 3702062866418272834,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'value': PropertySchema(
      id: 1,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _rateEntryEstimateSize,
  serialize: _rateEntrySerialize,
  deserialize: _rateEntryDeserialize,
  deserializeProp: _rateEntryDeserializeProp,
);

int _rateEntryEstimateSize(
  RateEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _rateEntrySerialize(
  RateEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeDouble(offsets[1], object.value);
}

RateEntry _rateEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RateEntry();
  object.key = reader.readStringOrNull(offsets[0]);
  object.value = reader.readDoubleOrNull(offsets[1]);
  return object;
}

P _rateEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RateEntryQueryFilter
    on QueryBuilder<RateEntry, RateEntry, QFilterCondition> {
  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RateEntry, RateEntry, QAfterFilterCondition> valueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension RateEntryQueryObject
    on QueryBuilder<RateEntry, RateEntry, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const StatusEntrySchema = Schema(
  name: r'StatusEntry',
  id: -2958221261568450543,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'value': PropertySchema(
      id: 1,
      name: r'value',
      type: IsarType.long,
    )
  },
  estimateSize: _statusEntryEstimateSize,
  serialize: _statusEntrySerialize,
  deserialize: _statusEntryDeserialize,
  deserializeProp: _statusEntryDeserializeProp,
);

int _statusEntryEstimateSize(
  StatusEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _statusEntrySerialize(
  StatusEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeLong(offsets[1], object.value);
}

StatusEntry _statusEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StatusEntry();
  object.key = reader.readStringOrNull(offsets[0]);
  object.value = reader.readLongOrNull(offsets[1]);
  return object;
}

P _statusEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StatusEntryQueryFilter
    on QueryBuilder<StatusEntry, StatusEntry, QFilterCondition> {
  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> valueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition>
      valueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> valueEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition>
      valueGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> valueLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<StatusEntry, StatusEntry, QAfterFilterCondition> valueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StatusEntryQueryObject
    on QueryBuilder<StatusEntry, StatusEntry, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const FetchTimeEntrySchema = Schema(
  name: r'FetchTimeEntry',
  id: -4673020294443194155,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'value': PropertySchema(
      id: 1,
      name: r'value',
      type: IsarType.long,
    )
  },
  estimateSize: _fetchTimeEntryEstimateSize,
  serialize: _fetchTimeEntrySerialize,
  deserialize: _fetchTimeEntryDeserialize,
  deserializeProp: _fetchTimeEntryDeserializeProp,
);

int _fetchTimeEntryEstimateSize(
  FetchTimeEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _fetchTimeEntrySerialize(
  FetchTimeEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeLong(offsets[1], object.value);
}

FetchTimeEntry _fetchTimeEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FetchTimeEntry();
  object.key = reader.readStringOrNull(offsets[0]);
  object.value = reader.readLongOrNull(offsets[1]);
  return object;
}

P _fetchTimeEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension FetchTimeEntryQueryFilter
    on QueryBuilder<FetchTimeEntry, FetchTimeEntry, QFilterCondition> {
  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'value',
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
      ));
    });
  }

  QueryBuilder<FetchTimeEntry, FetchTimeEntry, QAfterFilterCondition>
      valueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FetchTimeEntryQueryObject
    on QueryBuilder<FetchTimeEntry, FetchTimeEntry, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

const CurrencyFetchModeProxySchema = Schema(
  name: r'CurrencyFetchModeProxy',
  id: -2314010577763989201,
  properties: {
    r'mode': PropertySchema(
      id: 0,
      name: r'mode',
      type: IsarType.byte,
      enumMap: _CurrencyFetchModeProxymodeEnumValueMap,
    )
  },
  estimateSize: _currencyFetchModeProxyEstimateSize,
  serialize: _currencyFetchModeProxySerialize,
  deserialize: _currencyFetchModeProxyDeserialize,
  deserializeProp: _currencyFetchModeProxyDeserializeProp,
);

int _currencyFetchModeProxyEstimateSize(
  CurrencyFetchModeProxy object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _currencyFetchModeProxySerialize(
  CurrencyFetchModeProxy object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.mode.index);
}

CurrencyFetchModeProxy _currencyFetchModeProxyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrencyFetchModeProxy();
  object.mode = _CurrencyFetchModeProxymodeValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      CurrencyFetchMode.manual;
  return object;
}

P _currencyFetchModeProxyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_CurrencyFetchModeProxymodeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          CurrencyFetchMode.manual) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CurrencyFetchModeProxymodeEnumValueMap = {
  'manual': 0,
  'onceADay': 1,
};
const _CurrencyFetchModeProxymodeValueEnumMap = {
  0: CurrencyFetchMode.manual,
  1: CurrencyFetchMode.onceADay,
};

extension CurrencyFetchModeProxyQueryFilter on QueryBuilder<
    CurrencyFetchModeProxy, CurrencyFetchModeProxy, QFilterCondition> {
  QueryBuilder<CurrencyFetchModeProxy, CurrencyFetchModeProxy,
      QAfterFilterCondition> modeEqualTo(CurrencyFetchMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyFetchModeProxy, CurrencyFetchModeProxy,
      QAfterFilterCondition> modeGreaterThan(
    CurrencyFetchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyFetchModeProxy, CurrencyFetchModeProxy,
      QAfterFilterCondition> modeLessThan(
    CurrencyFetchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrencyFetchModeProxy, CurrencyFetchModeProxy,
      QAfterFilterCondition> modeBetween(
    CurrencyFetchMode lower,
    CurrencyFetchMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CurrencyFetchModeProxyQueryObject on QueryBuilder<
    CurrencyFetchModeProxy, CurrencyFetchModeProxy, QFilterCondition> {}
