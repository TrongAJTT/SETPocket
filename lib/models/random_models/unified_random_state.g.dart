// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_random_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUnifiedRandomStateCollection on Isar {
  IsarCollection<UnifiedRandomState> get unifiedRandomStates =>
      this.collection();
}

const UnifiedRandomStateSchema = CollectionSchema(
  name: r'UnifiedRandomState',
  id: 6948725424467877474,
  properties: {
    r'lastUpdated': PropertySchema(
      id: 0,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'stateData': PropertySchema(
      id: 1,
      name: r'stateData',
      type: IsarType.string,
    ),
    r'toolId': PropertySchema(
      id: 2,
      name: r'toolId',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 3,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _unifiedRandomStateEstimateSize,
  serialize: _unifiedRandomStateSerialize,
  deserialize: _unifiedRandomStateDeserialize,
  deserializeProp: _unifiedRandomStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _unifiedRandomStateGetId,
  getLinks: _unifiedRandomStateGetLinks,
  attach: _unifiedRandomStateAttach,
  version: '3.1.0+1',
);

int _unifiedRandomStateEstimateSize(
  UnifiedRandomState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.stateData.length * 3;
  bytesCount += 3 + object.toolId.length * 3;
  return bytesCount;
}

void _unifiedRandomStateSerialize(
  UnifiedRandomState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastUpdated);
  writer.writeString(offsets[1], object.stateData);
  writer.writeString(offsets[2], object.toolId);
  writer.writeLong(offsets[3], object.version);
}

UnifiedRandomState _unifiedRandomStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UnifiedRandomState();
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[0]);
  object.stateData = reader.readString(offsets[1]);
  object.toolId = reader.readString(offsets[2]);
  object.version = reader.readLong(offsets[3]);
  return object;
}

P _unifiedRandomStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _unifiedRandomStateGetId(UnifiedRandomState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _unifiedRandomStateGetLinks(
    UnifiedRandomState object) {
  return [];
}

void _unifiedRandomStateAttach(
    IsarCollection<dynamic> col, Id id, UnifiedRandomState object) {
  object.id = id;
}

extension UnifiedRandomStateQueryWhereSort
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QWhere> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UnifiedRandomStateQueryWhere
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QWhereClause> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhereClause>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterWhereClause>
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

extension UnifiedRandomStateQueryFilter
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QFilterCondition> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
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

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateData',
        value: '',
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      stateDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateData',
        value: '',
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolId',
        value: '',
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      toolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toolId',
        value: '',
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UnifiedRandomStateQueryObject
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QFilterCondition> {}

extension UnifiedRandomStateQueryLinks
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QFilterCondition> {}

extension UnifiedRandomStateQuerySortBy
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QSortBy> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByStateData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateData', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByStateDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateData', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByToolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByToolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension UnifiedRandomStateQuerySortThenBy
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QSortThenBy> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByStateData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateData', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByStateDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateData', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByToolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByToolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.desc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension UnifiedRandomStateQueryWhereDistinct
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QDistinct> {
  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QDistinct>
      distinctByStateData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QDistinct>
      distinctByToolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UnifiedRandomState, UnifiedRandomState, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension UnifiedRandomStateQueryProperty
    on QueryBuilder<UnifiedRandomState, UnifiedRandomState, QQueryProperty> {
  QueryBuilder<UnifiedRandomState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UnifiedRandomState, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<UnifiedRandomState, String, QQueryOperations>
      stateDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateData');
    });
  }

  QueryBuilder<UnifiedRandomState, String, QQueryOperations> toolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toolId');
    });
  }

  QueryBuilder<UnifiedRandomState, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
