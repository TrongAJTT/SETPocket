// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length_preset_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetLengthPresetModelCollection on Isar {
  IsarCollection<LengthPresetModel> get lengthPresetModels => this.collection();
}

const LengthPresetModelSchema = CollectionSchema(
  name: r'LengthPresetModel',
  id: 5223873922012780125,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'presetId': PropertySchema(
      id: 3,
      name: r'presetId',
      type: IsarType.string,
    ),
    r'units': PropertySchema(
      id: 4,
      name: r'units',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _lengthPresetModelEstimateSize,
  serialize: _lengthPresetModelSerialize,
  deserialize: _lengthPresetModelDeserialize,
  deserializeProp: _lengthPresetModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'presetId': IndexSchema(
      id: -2454531593692408596,
      name: r'presetId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'presetId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _lengthPresetModelGetId,
  getLinks: _lengthPresetModelGetLinks,
  attach: _lengthPresetModelAttach,
  version: '3.0.5',
);

int _lengthPresetModelEstimateSize(
  LengthPresetModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.presetId.length * 3;
  bytesCount += 3 + object.units.length * 3;
  {
    for (var i = 0; i < object.units.length; i++) {
      final value = object.units[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _lengthPresetModelSerialize(
  LengthPresetModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.presetId);
  writer.writeStringList(offsets[4], object.units);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

LengthPresetModel _lengthPresetModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LengthPresetModel(
    createdAt: reader.readDateTime(offsets[0]),
    id: id,
    name: reader.readString(offsets[2]),
    presetId: reader.readString(offsets[3]),
    units: reader.readStringList(offsets[4]) ?? [],
    updatedAt: reader.readDateTime(offsets[5]),
  );
  return object;
}

P _lengthPresetModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lengthPresetModelGetId(LengthPresetModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lengthPresetModelGetLinks(
    LengthPresetModel object) {
  return [];
}

void _lengthPresetModelAttach(
    IsarCollection<dynamic> col, Id id, LengthPresetModel object) {
  object.id = id;
}

extension LengthPresetModelByIndex on IsarCollection<LengthPresetModel> {
  Future<LengthPresetModel?> getByPresetId(String presetId) {
    return getByIndex(r'presetId', [presetId]);
  }

  LengthPresetModel? getByPresetIdSync(String presetId) {
    return getByIndexSync(r'presetId', [presetId]);
  }

  Future<bool> deleteByPresetId(String presetId) {
    return deleteByIndex(r'presetId', [presetId]);
  }

  bool deleteByPresetIdSync(String presetId) {
    return deleteByIndexSync(r'presetId', [presetId]);
  }

  Future<List<LengthPresetModel?>> getAllByPresetId(
      List<String> presetIdValues) {
    final values = presetIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'presetId', values);
  }

  List<LengthPresetModel?> getAllByPresetIdSync(List<String> presetIdValues) {
    final values = presetIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'presetId', values);
  }

  Future<int> deleteAllByPresetId(List<String> presetIdValues) {
    final values = presetIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'presetId', values);
  }

  int deleteAllByPresetIdSync(List<String> presetIdValues) {
    final values = presetIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'presetId', values);
  }

  Future<Id> putByPresetId(LengthPresetModel object) {
    return putByIndex(r'presetId', object);
  }

  Id putByPresetIdSync(LengthPresetModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'presetId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPresetId(List<LengthPresetModel> objects) {
    return putAllByIndex(r'presetId', objects);
  }

  List<Id> putAllByPresetIdSync(List<LengthPresetModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'presetId', objects, saveLinks: saveLinks);
  }
}

extension LengthPresetModelQueryWhereSort
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QWhere> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LengthPresetModelQueryWhere
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QWhereClause> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
      presetIdEqualTo(String presetId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'presetId',
        value: [presetId],
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterWhereClause>
      presetIdNotEqualTo(String presetId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'presetId',
              lower: [],
              upper: [presetId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'presetId',
              lower: [presetId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'presetId',
              lower: [presetId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'presetId',
              lower: [],
              upper: [presetId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LengthPresetModelQueryFilter
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QFilterCondition> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
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

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'presetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'presetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'presetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presetId',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      presetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'presetId',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'units',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'units',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'units',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'units',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'units',
        value: '',
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      unitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'units',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LengthPresetModelQueryObject
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QFilterCondition> {}

extension LengthPresetModelQueryLinks
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QFilterCondition> {}

extension LengthPresetModelQuerySortBy
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QSortBy> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByPresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetId', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByPresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetId', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LengthPresetModelQuerySortThenBy
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QSortThenBy> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByPresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetId', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByPresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presetId', Sort.desc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LengthPresetModelQueryWhereDistinct
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct> {
  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct>
      distinctByPresetId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct>
      distinctByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'units');
    });
  }

  QueryBuilder<LengthPresetModel, LengthPresetModel, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LengthPresetModelQueryProperty
    on QueryBuilder<LengthPresetModel, LengthPresetModel, QQueryProperty> {
  QueryBuilder<LengthPresetModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LengthPresetModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LengthPresetModel, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<LengthPresetModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<LengthPresetModel, String, QQueryOperations> presetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presetId');
    });
  }

  QueryBuilder<LengthPresetModel, List<String>, QQueryOperations>
      unitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'units');
    });
  }

  QueryBuilder<LengthPresetModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
