// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_sample_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivitySampleRecordCollection on Isar {
  IsarCollection<ActivitySampleRecord> get activitySampleRecords =>
      this.collection();
}

const ActivitySampleRecordSchema = CollectionSchema(
  name: r'ActivitySampleRecord',
  id: 6808847886015704893,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'confidence': PropertySchema(
      id: 1,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'durationSeconds': PropertySchema(
      id: 2,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'sourceKey': PropertySchema(
      id: 3,
      name: r'sourceKey',
      type: IsarType.string,
    ),
    r'stepCount': PropertySchema(
      id: 4,
      name: r'stepCount',
      type: IsarType.long,
    ),
    r'typeKey': PropertySchema(
      id: 5,
      name: r'typeKey',
      type: IsarType.string,
    )
  },
  estimateSize: _activitySampleRecordEstimateSize,
  serialize: _activitySampleRecordSerialize,
  deserialize: _activitySampleRecordDeserialize,
  deserializeProp: _activitySampleRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _activitySampleRecordGetId,
  getLinks: _activitySampleRecordGetLinks,
  attach: _activitySampleRecordAttach,
  version: '3.1.0+1',
);

int _activitySampleRecordEstimateSize(
  ActivitySampleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.sourceKey.length * 3;
  bytesCount += 3 + object.typeKey.length * 3;
  return bytesCount;
}

void _activitySampleRecordSerialize(
  ActivitySampleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeDouble(offsets[1], object.confidence);
  writer.writeLong(offsets[2], object.durationSeconds);
  writer.writeString(offsets[3], object.sourceKey);
  writer.writeLong(offsets[4], object.stepCount);
  writer.writeString(offsets[5], object.typeKey);
}

ActivitySampleRecord _activitySampleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivitySampleRecord();
  object.capturedAt = reader.readDateTime(offsets[0]);
  object.confidence = reader.readDouble(offsets[1]);
  object.durationSeconds = reader.readLong(offsets[2]);
  object.id = id;
  object.sourceKey = reader.readString(offsets[3]);
  object.stepCount = reader.readLong(offsets[4]);
  object.typeKey = reader.readString(offsets[5]);
  return object;
}

P _activitySampleRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activitySampleRecordGetId(ActivitySampleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activitySampleRecordGetLinks(
    ActivitySampleRecord object) {
  return [];
}

void _activitySampleRecordAttach(
    IsarCollection<dynamic> col, Id id, ActivitySampleRecord object) {
  object.id = id;
}

extension ActivitySampleRecordQueryWhereSort
    on QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QWhere> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActivitySampleRecordQueryWhere
    on QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QWhereClause> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhereClause>
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterWhereClause>
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

extension ActivitySampleRecordQueryFilter on QueryBuilder<ActivitySampleRecord,
    ActivitySampleRecord, QFilterCondition> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> capturedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> capturedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> capturedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capturedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> confidenceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> confidenceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> confidenceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> confidenceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> durationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> durationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> durationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
          QAfterFilterCondition>
      sourceKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
          QAfterFilterCondition>
      sourceKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> sourceKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> stepCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> stepCountGreaterThan(
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> stepCountLessThan(
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> stepCountBetween(
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

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'typeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
          QAfterFilterCondition>
      typeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'typeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
          QAfterFilterCondition>
      typeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'typeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord,
      QAfterFilterCondition> typeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'typeKey',
        value: '',
      ));
    });
  }
}

extension ActivitySampleRecordQueryObject on QueryBuilder<ActivitySampleRecord,
    ActivitySampleRecord, QFilterCondition> {}

extension ActivitySampleRecordQueryLinks on QueryBuilder<ActivitySampleRecord,
    ActivitySampleRecord, QFilterCondition> {}

extension ActivitySampleRecordQuerySortBy
    on QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QSortBy> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortBySourceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortBySourceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      sortByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ActivitySampleRecordQuerySortThenBy
    on QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QSortThenBy> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenBySourceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenBySourceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QAfterSortBy>
      thenByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ActivitySampleRecordQueryWhereDistinct
    on QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct> {
  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctBySourceKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepCount');
    });
  }

  QueryBuilder<ActivitySampleRecord, ActivitySampleRecord, QDistinct>
      distinctByTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeKey', caseSensitive: caseSensitive);
    });
  }
}

extension ActivitySampleRecordQueryProperty on QueryBuilder<
    ActivitySampleRecord, ActivitySampleRecord, QQueryProperty> {
  QueryBuilder<ActivitySampleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivitySampleRecord, DateTime, QQueryOperations>
      capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<ActivitySampleRecord, double, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<ActivitySampleRecord, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<ActivitySampleRecord, String, QQueryOperations>
      sourceKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceKey');
    });
  }

  QueryBuilder<ActivitySampleRecord, int, QQueryOperations>
      stepCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepCount');
    });
  }

  QueryBuilder<ActivitySampleRecord, String, QQueryOperations>
      typeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeKey');
    });
  }
}
