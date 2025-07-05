// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetSettingsModelCollection on Isar {
  IsarCollection<SettingsModel> get settingsModels => this.collection();
}

const SettingsModelSchema = CollectionSchema(
  name: r'SettingsModel',
  id: 4013777327486952906,
  properties: {
    r'currencyFetchMode': PropertySchema(
      id: 0,
      name: r'currencyFetchMode',
      type: IsarType.byte,
      enumMap: _SettingsModelcurrencyFetchModeEnumValueMap,
    ),
    r'featureStateSavingEnabled': PropertySchema(
      id: 1,
      name: r'featureStateSavingEnabled',
      type: IsarType.bool,
    ),
    r'fetchRetryTimes': PropertySchema(
      id: 2,
      name: r'fetchRetryTimes',
      type: IsarType.long,
    ),
    r'fetchTimeoutSeconds': PropertySchema(
      id: 3,
      name: r'fetchTimeoutSeconds',
      type: IsarType.long,
    ),
    r'focusModeEnabled': PropertySchema(
      id: 4,
      name: r'focusModeEnabled',
      type: IsarType.bool,
    ),
    r'logRetentionDays': PropertySchema(
      id: 5,
      name: r'logRetentionDays',
      type: IsarType.long,
    ),
    r'saveRandomToolsState': PropertySchema(
      id: 6,
      name: r'saveRandomToolsState',
      type: IsarType.bool,
    )
  },
  estimateSize: _settingsModelEstimateSize,
  serialize: _settingsModelSerialize,
  deserialize: _settingsModelDeserialize,
  deserializeProp: _settingsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsModelGetId,
  getLinks: _settingsModelGetLinks,
  attach: _settingsModelAttach,
  version: '3.0.5',
);

int _settingsModelEstimateSize(
  SettingsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _settingsModelSerialize(
  SettingsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.currencyFetchMode.index);
  writer.writeBool(offsets[1], object.featureStateSavingEnabled);
  writer.writeLong(offsets[2], object.fetchRetryTimes);
  writer.writeLong(offsets[3], object.fetchTimeoutSeconds);
  writer.writeBool(offsets[4], object.focusModeEnabled);
  writer.writeLong(offsets[5], object.logRetentionDays);
  writer.writeBool(offsets[6], object.saveRandomToolsState);
}

SettingsModel _settingsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsModel(
    currencyFetchMode: _SettingsModelcurrencyFetchModeValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        CurrencyFetchMode.onceADay,
    featureStateSavingEnabled: reader.readBoolOrNull(offsets[1]) ?? true,
    fetchRetryTimes: reader.readLongOrNull(offsets[2]) ?? 1,
    fetchTimeoutSeconds: reader.readLongOrNull(offsets[3]) ?? 10,
    focusModeEnabled: reader.readBoolOrNull(offsets[4]) ?? false,
    logRetentionDays: reader.readLongOrNull(offsets[5]) ?? 5,
    saveRandomToolsState: reader.readBoolOrNull(offsets[6]) ?? true,
  );
  object.id = id;
  return object;
}

P _settingsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SettingsModelcurrencyFetchModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          CurrencyFetchMode.onceADay) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 5) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsModelcurrencyFetchModeEnumValueMap = {
  'manual': 0,
  'onceADay': 1,
};
const _SettingsModelcurrencyFetchModeValueEnumMap = {
  0: CurrencyFetchMode.manual,
  1: CurrencyFetchMode.onceADay,
};

Id _settingsModelGetId(SettingsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsModelGetLinks(SettingsModel object) {
  return [];
}

void _settingsModelAttach(
    IsarCollection<dynamic> col, Id id, SettingsModel object) {
  object.id = id;
}

extension SettingsModelQueryWhereSort
    on QueryBuilder<SettingsModel, SettingsModel, QWhere> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsModelQueryWhere
    on QueryBuilder<SettingsModel, SettingsModel, QWhereClause> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idBetween(
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

extension SettingsModelQueryFilter
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      currencyFetchModeEqualTo(CurrencyFetchMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyFetchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      currencyFetchModeGreaterThan(
    CurrencyFetchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencyFetchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      currencyFetchModeLessThan(
    CurrencyFetchMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencyFetchMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      currencyFetchModeBetween(
    CurrencyFetchMode lower,
    CurrencyFetchMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencyFetchMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      featureStateSavingEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'featureStateSavingEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchRetryTimesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fetchRetryTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchRetryTimesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fetchRetryTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchRetryTimesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fetchRetryTimes',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchRetryTimesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fetchRetryTimes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchTimeoutSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fetchTimeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchTimeoutSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fetchTimeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchTimeoutSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fetchTimeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      fetchTimeoutSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fetchTimeoutSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      focusModeEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusModeEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      logRetentionDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logRetentionDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      logRetentionDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logRetentionDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      logRetentionDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logRetentionDays',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      logRetentionDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logRetentionDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      saveRandomToolsStateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveRandomToolsState',
        value: value,
      ));
    });
  }
}

extension SettingsModelQueryObject
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {}

extension SettingsModelQueryLinks
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {}

extension SettingsModelQuerySortBy
    on QueryBuilder<SettingsModel, SettingsModel, QSortBy> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByCurrencyFetchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyFetchMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByCurrencyFetchModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyFetchMode', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFeatureStateSavingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureStateSavingEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFeatureStateSavingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureStateSavingEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFetchRetryTimes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchRetryTimes', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFetchRetryTimesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchRetryTimes', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFetchTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchTimeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFetchTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchTimeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFocusModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByFocusModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByLogRetentionDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logRetentionDays', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByLogRetentionDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logRetentionDays', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortBySaveRandomToolsState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveRandomToolsState', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortBySaveRandomToolsStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveRandomToolsState', Sort.desc);
    });
  }
}

extension SettingsModelQuerySortThenBy
    on QueryBuilder<SettingsModel, SettingsModel, QSortThenBy> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByCurrencyFetchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyFetchMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByCurrencyFetchModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyFetchMode', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFeatureStateSavingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureStateSavingEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFeatureStateSavingEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'featureStateSavingEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFetchRetryTimes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchRetryTimes', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFetchRetryTimesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchRetryTimes', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFetchTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchTimeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFetchTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchTimeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFocusModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusModeEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByFocusModeEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusModeEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByLogRetentionDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logRetentionDays', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByLogRetentionDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logRetentionDays', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenBySaveRandomToolsState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveRandomToolsState', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenBySaveRandomToolsStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveRandomToolsState', Sort.desc);
    });
  }
}

extension SettingsModelQueryWhereDistinct
    on QueryBuilder<SettingsModel, SettingsModel, QDistinct> {
  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByCurrencyFetchMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyFetchMode');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByFeatureStateSavingEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'featureStateSavingEnabled');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByFetchRetryTimes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchRetryTimes');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByFetchTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchTimeoutSeconds');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByFocusModeEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusModeEnabled');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByLogRetentionDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logRetentionDays');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctBySaveRandomToolsState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveRandomToolsState');
    });
  }
}

extension SettingsModelQueryProperty
    on QueryBuilder<SettingsModel, SettingsModel, QQueryProperty> {
  QueryBuilder<SettingsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsModel, CurrencyFetchMode, QQueryOperations>
      currencyFetchModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyFetchMode');
    });
  }

  QueryBuilder<SettingsModel, bool, QQueryOperations>
      featureStateSavingEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'featureStateSavingEnabled');
    });
  }

  QueryBuilder<SettingsModel, int, QQueryOperations> fetchRetryTimesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchRetryTimes');
    });
  }

  QueryBuilder<SettingsModel, int, QQueryOperations>
      fetchTimeoutSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchTimeoutSeconds');
    });
  }

  QueryBuilder<SettingsModel, bool, QQueryOperations>
      focusModeEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusModeEnabled');
    });
  }

  QueryBuilder<SettingsModel, int, QQueryOperations>
      logRetentionDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logRetentionDays');
    });
  }

  QueryBuilder<SettingsModel, bool, QQueryOperations>
      saveRandomToolsStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveRandomToolsState');
    });
  }
}
