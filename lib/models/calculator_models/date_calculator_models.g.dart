// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_calculator_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDateCalculationHistoryCollection on Isar {
  IsarCollection<DateCalculationHistory> get dateCalculationHistorys =>
      this.collection();
}

const DateCalculationHistorySchema = CollectionSchema(
  name: r'DateCalculationHistory',
  id: 8297151515272173219,
  properties: {
    r'displayTitle': PropertySchema(
      id: 0,
      name: r'displayTitle',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
      enumMap: _DateCalculationHistorytypeEnumValueMap,
    )
  },
  estimateSize: _dateCalculationHistoryEstimateSize,
  serialize: _dateCalculationHistorySerialize,
  deserialize: _dateCalculationHistoryDeserialize,
  deserializeProp: _dateCalculationHistoryDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dateCalculationHistoryGetId,
  getLinks: _dateCalculationHistoryGetLinks,
  attach: _dateCalculationHistoryAttach,
  version: '3.1.0+1',
);

int _dateCalculationHistoryEstimateSize(
  DateCalculationHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayTitle.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _dateCalculationHistorySerialize(
  DateCalculationHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayTitle);
  writer.writeString(offsets[1], object.id);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeString(offsets[3], object.type.name);
}

DateCalculationHistory _dateCalculationHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DateCalculationHistory();
  object.displayTitle = reader.readString(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.isarId = id;
  object.timestamp = reader.readDateTime(offsets[2]);
  object.type = _DateCalculationHistorytypeValueEnumMap[
          reader.readStringOrNull(offsets[3])] ??
      DateCalculationType.dateDifference;
  return object;
}

P _dateCalculationHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_DateCalculationHistorytypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          DateCalculationType.dateDifference) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DateCalculationHistorytypeEnumValueMap = {
  r'dateDifference': r'dateDifference',
  r'addSubtract': r'addSubtract',
  r'age': r'age',
  r'workingDays': r'workingDays',
  r'timezone': r'timezone',
  r'recurring': r'recurring',
  r'countdown': r'countdown',
  r'dateInfo': r'dateInfo',
  r'timeUnit': r'timeUnit',
  r'nthWeekday': r'nthWeekday',
};
const _DateCalculationHistorytypeValueEnumMap = {
  r'dateDifference': DateCalculationType.dateDifference,
  r'addSubtract': DateCalculationType.addSubtract,
  r'age': DateCalculationType.age,
  r'workingDays': DateCalculationType.workingDays,
  r'timezone': DateCalculationType.timezone,
  r'recurring': DateCalculationType.recurring,
  r'countdown': DateCalculationType.countdown,
  r'dateInfo': DateCalculationType.dateInfo,
  r'timeUnit': DateCalculationType.timeUnit,
  r'nthWeekday': DateCalculationType.nthWeekday,
};

Id _dateCalculationHistoryGetId(DateCalculationHistory object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _dateCalculationHistoryGetLinks(
    DateCalculationHistory object) {
  return [];
}

void _dateCalculationHistoryAttach(
    IsarCollection<dynamic> col, Id id, DateCalculationHistory object) {
  object.isarId = id;
}

extension DateCalculationHistoryQueryWhereSort
    on QueryBuilder<DateCalculationHistory, DateCalculationHistory, QWhere> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterWhere>
      anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension DateCalculationHistoryQueryWhere on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QWhereClause> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DateCalculationHistoryQueryFilter on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QFilterCondition> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      displayTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      displayTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> displayTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeEqualTo(
    DateCalculationType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeGreaterThan(
    DateCalculationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeLessThan(
    DateCalculationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeBetween(
    DateCalculationType lower,
    DateCalculationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension DateCalculationHistoryQueryObject on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QFilterCondition> {}

extension DateCalculationHistoryQueryLinks on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QFilterCondition> {}

extension DateCalculationHistoryQuerySortBy
    on QueryBuilder<DateCalculationHistory, DateCalculationHistory, QSortBy> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByDisplayTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByDisplayTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension DateCalculationHistoryQuerySortThenBy on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QSortThenBy> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByDisplayTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByDisplayTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension DateCalculationHistoryQueryWhereDistinct
    on QueryBuilder<DateCalculationHistory, DateCalculationHistory, QDistinct> {
  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QDistinct>
      distinctByDisplayTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationHistory, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension DateCalculationHistoryQueryProperty on QueryBuilder<
    DateCalculationHistory, DateCalculationHistory, QQueryProperty> {
  QueryBuilder<DateCalculationHistory, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DateCalculationHistory, String, QQueryOperations>
      displayTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayTitle');
    });
  }

  QueryBuilder<DateCalculationHistory, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DateCalculationHistory, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<DateCalculationHistory, DateCalculationType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDateCalculatorStateCollection on Isar {
  IsarCollection<DateCalculatorState> get dateCalculatorStates =>
      this.collection();
}

const DateCalculatorStateSchema = CollectionSchema(
  name: r'DateCalculatorState',
  id: -965660668008464411,
  properties: {
    r'activeTab': PropertySchema(
      id: 0,
      name: r'activeTab',
      type: IsarType.string,
      enumMap: _DateCalculatorStateactiveTabEnumValueMap,
    ),
    r'isDataConstraintEnabled': PropertySchema(
      id: 1,
      name: r'isDataConstraintEnabled',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 2,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _dateCalculatorStateEstimateSize,
  serialize: _dateCalculatorStateSerialize,
  deserialize: _dateCalculatorStateDeserialize,
  deserializeProp: _dateCalculatorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dateCalculatorStateGetId,
  getLinks: _dateCalculatorStateGetLinks,
  attach: _dateCalculatorStateAttach,
  version: '3.1.0+1',
);

int _dateCalculatorStateEstimateSize(
  DateCalculatorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeTab.name.length * 3;
  return bytesCount;
}

void _dateCalculatorStateSerialize(
  DateCalculatorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeTab.name);
  writer.writeBool(offsets[1], object.isDataConstraintEnabled);
  writer.writeDateTime(offsets[2], object.lastUpdated);
}

DateCalculatorState _dateCalculatorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DateCalculatorState();
  object.activeTab = _DateCalculatorStateactiveTabValueEnumMap[
          reader.readStringOrNull(offsets[0])] ??
      DateCalculationType.dateDifference;
  object.id = id;
  object.isDataConstraintEnabled = reader.readBool(offsets[1]);
  object.lastUpdated = reader.readDateTime(offsets[2]);
  return object;
}

P _dateCalculatorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_DateCalculatorStateactiveTabValueEnumMap[
              reader.readStringOrNull(offset)] ??
          DateCalculationType.dateDifference) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DateCalculatorStateactiveTabEnumValueMap = {
  r'dateDifference': r'dateDifference',
  r'addSubtract': r'addSubtract',
  r'age': r'age',
  r'workingDays': r'workingDays',
  r'timezone': r'timezone',
  r'recurring': r'recurring',
  r'countdown': r'countdown',
  r'dateInfo': r'dateInfo',
  r'timeUnit': r'timeUnit',
  r'nthWeekday': r'nthWeekday',
};
const _DateCalculatorStateactiveTabValueEnumMap = {
  r'dateDifference': DateCalculationType.dateDifference,
  r'addSubtract': DateCalculationType.addSubtract,
  r'age': DateCalculationType.age,
  r'workingDays': DateCalculationType.workingDays,
  r'timezone': DateCalculationType.timezone,
  r'recurring': DateCalculationType.recurring,
  r'countdown': DateCalculationType.countdown,
  r'dateInfo': DateCalculationType.dateInfo,
  r'timeUnit': DateCalculationType.timeUnit,
  r'nthWeekday': DateCalculationType.nthWeekday,
};

Id _dateCalculatorStateGetId(DateCalculatorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dateCalculatorStateGetLinks(
    DateCalculatorState object) {
  return [];
}

void _dateCalculatorStateAttach(
    IsarCollection<dynamic> col, Id id, DateCalculatorState object) {
  object.id = id;
}

extension DateCalculatorStateQueryWhereSort
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QWhere> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DateCalculatorStateQueryWhere
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QWhereClause> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhereClause>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterWhereClause>
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

extension DateCalculatorStateQueryFilter on QueryBuilder<DateCalculatorState,
    DateCalculatorState, QFilterCondition> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabEqualTo(
    DateCalculationType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabGreaterThan(
    DateCalculationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabLessThan(
    DateCalculationType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabBetween(
    DateCalculationType lower,
    DateCalculationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeTab',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeTab',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeTab',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeTab',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      activeTabIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeTab',
        value: '',
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      isDataConstraintEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDataConstraintEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterFilterCondition>
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
}

extension DateCalculatorStateQueryObject on QueryBuilder<DateCalculatorState,
    DateCalculatorState, QFilterCondition> {}

extension DateCalculatorStateQueryLinks on QueryBuilder<DateCalculatorState,
    DateCalculatorState, QFilterCondition> {}

extension DateCalculatorStateQuerySortBy
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QSortBy> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByActiveTab() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTab', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByActiveTabDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTab', Sort.desc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByIsDataConstraintEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDataConstraintEnabled', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByIsDataConstraintEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDataConstraintEnabled', Sort.desc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension DateCalculatorStateQuerySortThenBy
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QSortThenBy> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByActiveTab() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTab', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByActiveTabDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTab', Sort.desc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByIsDataConstraintEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDataConstraintEnabled', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByIsDataConstraintEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDataConstraintEnabled', Sort.desc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }
}

extension DateCalculatorStateQueryWhereDistinct
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QDistinct> {
  QueryBuilder<DateCalculatorState, DateCalculatorState, QDistinct>
      distinctByActiveTab({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeTab', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QDistinct>
      distinctByIsDataConstraintEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDataConstraintEnabled');
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculatorState, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }
}

extension DateCalculatorStateQueryProperty
    on QueryBuilder<DateCalculatorState, DateCalculatorState, QQueryProperty> {
  QueryBuilder<DateCalculatorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DateCalculatorState, DateCalculationType, QQueryOperations>
      activeTabProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeTab');
    });
  }

  QueryBuilder<DateCalculatorState, bool, QQueryOperations>
      isDataConstraintEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDataConstraintEnabled');
    });
  }

  QueryBuilder<DateCalculatorState, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }
}
