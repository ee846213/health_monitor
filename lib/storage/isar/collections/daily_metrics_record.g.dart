// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_metrics_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyMetricsRecordCollection on Isar {
  IsarCollection<DailyMetricsRecord> get dailyMetricsRecords =>
      this.collection();
}

const DailyMetricsRecordSchema = CollectionSchema(
  name: r'DailyMetricsRecord',
  id: -492020278697652983,
  properties: {
    r'dateKey': PropertySchema(
      id: 0,
      name: r'dateKey',
      type: IsarType.string,
    ),
    r'highNoiseExposureSeconds': PropertySchema(
      id: 1,
      name: r'highNoiseExposureSeconds',
      type: IsarType.long,
    ),
    r'outdoorSeconds': PropertySchema(
      id: 2,
      name: r'outdoorSeconds',
      type: IsarType.long,
    ),
    r'postureRiskCount': PropertySchema(
      id: 3,
      name: r'postureRiskCount',
      type: IsarType.long,
    ),
    r'screenOnSeconds': PropertySchema(
      id: 4,
      name: r'screenOnSeconds',
      type: IsarType.long,
    ),
    r'sedentarySeconds': PropertySchema(
      id: 5,
      name: r'sedentarySeconds',
      type: IsarType.long,
    ),
    r'stepCount': PropertySchema(
      id: 6,
      name: r'stepCount',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyMetricsRecordEstimateSize,
  serialize: _dailyMetricsRecordSerialize,
  deserialize: _dailyMetricsRecordDeserialize,
  deserializeProp: _dailyMetricsRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'dateKey': IndexSchema(
      id: 7975223786082927131,
      name: r'dateKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyMetricsRecordGetId,
  getLinks: _dailyMetricsRecordGetLinks,
  attach: _dailyMetricsRecordAttach,
  version: '3.1.0+1',
);

int _dailyMetricsRecordEstimateSize(
  DailyMetricsRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateKey.length * 3;
  return bytesCount;
}

void _dailyMetricsRecordSerialize(
  DailyMetricsRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dateKey);
  writer.writeLong(offsets[1], object.highNoiseExposureSeconds);
  writer.writeLong(offsets[2], object.outdoorSeconds);
  writer.writeLong(offsets[3], object.postureRiskCount);
  writer.writeLong(offsets[4], object.screenOnSeconds);
  writer.writeLong(offsets[5], object.sedentarySeconds);
  writer.writeLong(offsets[6], object.stepCount);
}

DailyMetricsRecord _dailyMetricsRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyMetricsRecord();
  object.dateKey = reader.readString(offsets[0]);
  object.highNoiseExposureSeconds = reader.readLong(offsets[1]);
  object.id = id;
  object.outdoorSeconds = reader.readLong(offsets[2]);
  object.postureRiskCount = reader.readLong(offsets[3]);
  object.screenOnSeconds = reader.readLong(offsets[4]);
  object.sedentarySeconds = reader.readLong(offsets[5]);
  object.stepCount = reader.readLong(offsets[6]);
  return object;
}

P _dailyMetricsRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyMetricsRecordGetId(DailyMetricsRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyMetricsRecordGetLinks(
    DailyMetricsRecord object) {
  return [];
}

void _dailyMetricsRecordAttach(
    IsarCollection<dynamic> col, Id id, DailyMetricsRecord object) {
  object.id = id;
}

extension DailyMetricsRecordQueryWhereSort
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QWhere> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyMetricsRecordQueryWhere
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QWhereClause> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
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

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
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

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
      dateKeyEqualTo(String dateKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateKey',
        value: [dateKey],
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterWhereClause>
      dateKeyNotEqualTo(String dateKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateKey',
              lower: [],
              upper: [dateKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateKey',
              lower: [dateKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateKey',
              lower: [dateKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateKey',
              lower: [],
              upper: [dateKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DailyMetricsRecordQueryFilter
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QFilterCondition> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      dateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      highNoiseExposureSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'highNoiseExposureSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      highNoiseExposureSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'highNoiseExposureSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      highNoiseExposureSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'highNoiseExposureSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      highNoiseExposureSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'highNoiseExposureSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
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

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
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

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
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

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      outdoorSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outdoorSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      outdoorSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outdoorSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      outdoorSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outdoorSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      outdoorSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outdoorSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      postureRiskCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postureRiskCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      postureRiskCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postureRiskCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      postureRiskCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postureRiskCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      postureRiskCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postureRiskCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      screenOnSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'screenOnSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      screenOnSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'screenOnSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      screenOnSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'screenOnSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      screenOnSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'screenOnSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      sedentarySecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sedentarySeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      sedentarySecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sedentarySeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      sedentarySecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sedentarySeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      sedentarySecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sedentarySeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      stepCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      stepCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      stepCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterFilterCondition>
      stepCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyMetricsRecordQueryObject
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QFilterCondition> {}

extension DailyMetricsRecordQueryLinks
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QFilterCondition> {}

extension DailyMetricsRecordQuerySortBy
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QSortBy> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByHighNoiseExposureSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highNoiseExposureSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByHighNoiseExposureSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highNoiseExposureSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByOutdoorSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByOutdoorSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByPostureRiskCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskCount', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByPostureRiskCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskCount', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByScreenOnSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortBySedentarySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentarySeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortBySedentarySecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentarySeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      sortByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }
}

extension DailyMetricsRecordQuerySortThenBy
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QSortThenBy> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByHighNoiseExposureSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highNoiseExposureSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByHighNoiseExposureSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highNoiseExposureSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByOutdoorSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByOutdoorSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByPostureRiskCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskCount', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByPostureRiskCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskCount', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByScreenOnSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenBySedentarySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentarySeconds', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenBySedentarySecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentarySeconds', Sort.desc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QAfterSortBy>
      thenByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }
}

extension DailyMetricsRecordQueryWhereDistinct
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct> {
  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByDateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByHighNoiseExposureSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highNoiseExposureSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByOutdoorSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outdoorSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByPostureRiskCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postureRiskCount');
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'screenOnSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctBySedentarySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sedentarySeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QDistinct>
      distinctByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepCount');
    });
  }
}

extension DailyMetricsRecordQueryProperty
    on QueryBuilder<DailyMetricsRecord, DailyMetricsRecord, QQueryProperty> {
  QueryBuilder<DailyMetricsRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyMetricsRecord, String, QQueryOperations> dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations>
      highNoiseExposureSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highNoiseExposureSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations>
      outdoorSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outdoorSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations>
      postureRiskCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postureRiskCount');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations>
      screenOnSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'screenOnSeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations>
      sedentarySecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sedentarySeconds');
    });
  }

  QueryBuilder<DailyMetricsRecord, int, QQueryOperations> stepCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepCount');
    });
  }
}
