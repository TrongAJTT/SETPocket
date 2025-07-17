// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinancialCalculationHistoryCollection on Isar {
  IsarCollection<FinancialCalculationHistory>
      get financialCalculationHistorys => this.collection();
}

final FinancialCalculationHistorySchema = CollectionSchema(
  name: r'FinancialCalculationHistory',
  id: 1151823705567661945,
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
      enumMap: _FinancialCalculationHistorytypeEnumValueMap,
    )
  },
  estimateSize: _financialCalculationHistoryEstimateSize,
  serialize: _financialCalculationHistorySerialize,
  deserialize: _financialCalculationHistoryDeserialize,
  deserializeProp: _financialCalculationHistoryDeserializeProp,
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
  getId: _financialCalculationHistoryGetId,
  getLinks: _financialCalculationHistoryGetLinks,
  attach: _financialCalculationHistoryAttach,
  version: '3.1.0+1',
);

int _financialCalculationHistoryEstimateSize(
  FinancialCalculationHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayTitle.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _financialCalculationHistorySerialize(
  FinancialCalculationHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayTitle);
  writer.writeString(offsets[1], object.id);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeString(offsets[3], object.type.name);
}

FinancialCalculationHistory _financialCalculationHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialCalculationHistory();
  object.displayTitle = reader.readString(offsets[0]);
  object.id = reader.readString(offsets[1]);
  object.isarId = id;
  object.timestamp = reader.readDateTime(offsets[2]);
  object.type = _FinancialCalculationHistorytypeValueEnumMap[
          reader.readStringOrNull(offsets[3])] ??
      FinancialCalculationType.loan;
  return object;
}

P _financialCalculationHistoryDeserializeProp<P>(
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
      return (_FinancialCalculationHistorytypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          FinancialCalculationType.loan) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FinancialCalculationHistorytypeEnumValueMap = {
  r'loan': r'loan',
  r'investment': r'investment',
  r'compoundInterest': r'compoundInterest',
};
const _FinancialCalculationHistorytypeValueEnumMap = {
  r'loan': FinancialCalculationType.loan,
  r'investment': FinancialCalculationType.investment,
  r'compoundInterest': FinancialCalculationType.compoundInterest,
};

Id _financialCalculationHistoryGetId(FinancialCalculationHistory object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _financialCalculationHistoryGetLinks(
    FinancialCalculationHistory object) {
  return [];
}

void _financialCalculationHistoryAttach(
    IsarCollection<dynamic> col, Id id, FinancialCalculationHistory object) {
  object.isarId = id;
}

extension FinancialCalculationHistoryQueryWhereSort on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QWhere> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension FinancialCalculationHistoryQueryWhere on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QWhereClause> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterWhereClause> timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

extension FinancialCalculationHistoryQueryFilter on QueryBuilder<
    FinancialCalculationHistory,
    FinancialCalculationHistory,
    QFilterCondition> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> displayTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> displayTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeEqualTo(
    FinancialCalculationType value, {
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeGreaterThan(
    FinancialCalculationType value, {
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeLessThan(
    FinancialCalculationType value, {
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeBetween(
    FinancialCalculationType lower,
    FinancialCalculationType upper, {
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
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

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension FinancialCalculationHistoryQueryObject on QueryBuilder<
    FinancialCalculationHistory,
    FinancialCalculationHistory,
    QFilterCondition> {}

extension FinancialCalculationHistoryQueryLinks on QueryBuilder<
    FinancialCalculationHistory,
    FinancialCalculationHistory,
    QFilterCondition> {}

extension FinancialCalculationHistoryQuerySortBy on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QSortBy> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByDisplayTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByDisplayTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension FinancialCalculationHistoryQuerySortThenBy on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QSortThenBy> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByDisplayTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByDisplayTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayTitle', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension FinancialCalculationHistoryQueryWhereDistinct on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QDistinct> {
  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QDistinct> distinctByDisplayTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QDistinct> distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationHistory,
      QDistinct> distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension FinancialCalculationHistoryQueryProperty on QueryBuilder<
    FinancialCalculationHistory, FinancialCalculationHistory, QQueryProperty> {
  QueryBuilder<FinancialCalculationHistory, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FinancialCalculationHistory, String, QQueryOperations>
      displayTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayTitle');
    });
  }

  QueryBuilder<FinancialCalculationHistory, String, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialCalculationHistory, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<FinancialCalculationHistory, FinancialCalculationType,
      QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinancialCalculatorStateCollection on Isar {
  IsarCollection<FinancialCalculatorState> get financialCalculatorStates =>
      this.collection();
}

final FinancialCalculatorStateSchema = CollectionSchema(
  name: r'FinancialCalculatorState',
  id: -6838229852067599508,
  properties: {
    r'activeTabIndex': PropertySchema(
      id: 0,
      name: r'activeTabIndex',
      type: IsarType.long,
    ),
    r'lastModified': PropertySchema(
      id: 1,
      name: r'lastModified',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _financialCalculatorStateEstimateSize,
  serialize: _financialCalculatorStateSerialize,
  deserialize: _financialCalculatorStateDeserialize,
  deserializeProp: _financialCalculatorStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _financialCalculatorStateGetId,
  getLinks: _financialCalculatorStateGetLinks,
  attach: _financialCalculatorStateAttach,
  version: '3.1.0+1',
);

int _financialCalculatorStateEstimateSize(
  FinancialCalculatorState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _financialCalculatorStateSerialize(
  FinancialCalculatorState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeTabIndex);
  writer.writeDateTime(offsets[1], object.lastModified);
}

FinancialCalculatorState _financialCalculatorStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialCalculatorState();
  object.activeTabIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.lastModified = reader.readDateTime(offsets[1]);
  return object;
}

P _financialCalculatorStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financialCalculatorStateGetId(FinancialCalculatorState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financialCalculatorStateGetLinks(
    FinancialCalculatorState object) {
  return [];
}

void _financialCalculatorStateAttach(
    IsarCollection<dynamic> col, Id id, FinancialCalculatorState object) {
  object.id = id;
}

extension FinancialCalculatorStateQueryWhereSort on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QWhere> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinancialCalculatorStateQueryWhere on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QWhereClause> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
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

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
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

extension FinancialCalculatorStateQueryFilter on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QFilterCondition> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> activeTabIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> activeTabIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> activeTabIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeTabIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> activeTabIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeTabIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
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

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
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

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
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

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> lastModifiedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> lastModifiedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> lastModifiedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState,
      QAfterFilterCondition> lastModifiedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinancialCalculatorStateQueryObject on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QFilterCondition> {}

extension FinancialCalculatorStateQueryLinks on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QFilterCondition> {}

extension FinancialCalculatorStateQuerySortBy on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QSortBy> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      sortByActiveTabIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTabIndex', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      sortByActiveTabIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTabIndex', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      sortByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      sortByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }
}

extension FinancialCalculatorStateQuerySortThenBy on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QSortThenBy> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenByActiveTabIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTabIndex', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenByActiveTabIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeTabIndex', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QAfterSortBy>
      thenByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }
}

extension FinancialCalculatorStateQueryWhereDistinct on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QDistinct> {
  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QDistinct>
      distinctByActiveTabIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeTabIndex');
    });
  }

  QueryBuilder<FinancialCalculatorState, FinancialCalculatorState, QDistinct>
      distinctByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModified');
    });
  }
}

extension FinancialCalculatorStateQueryProperty on QueryBuilder<
    FinancialCalculatorState, FinancialCalculatorState, QQueryProperty> {
  QueryBuilder<FinancialCalculatorState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialCalculatorState, int, QQueryOperations>
      activeTabIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeTabIndex');
    });
  }

  QueryBuilder<FinancialCalculatorState, DateTime, QQueryOperations>
      lastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModified');
    });
  }
}
