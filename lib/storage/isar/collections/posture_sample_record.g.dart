// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posture_sample_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPostureSampleRecordCollection on Isar {
  IsarCollection<PostureSampleRecord> get postureSampleRecords =>
      this.collection();
}

const PostureSampleRecordSchema = CollectionSchema(
  name: r'PostureSampleRecord',
  id: -6185813175339113817,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'continuousHoldSeconds': PropertySchema(
      id: 1,
      name: r'continuousHoldSeconds',
      type: IsarType.long,
    ),
    r'durationSeconds': PropertySchema(
      id: 2,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'postureKey': PropertySchema(
      id: 3,
      name: r'postureKey',
      type: IsarType.string,
    ),
    r'riskLevelKey': PropertySchema(
      id: 4,
      name: r'riskLevelKey',
      type: IsarType.string,
    )
  },
  estimateSize: _postureSampleRecordEstimateSize,
  serialize: _postureSampleRecordSerialize,
  deserialize: _postureSampleRecordDeserialize,
  deserializeProp: _postureSampleRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _postureSampleRecordGetId,
  getLinks: _postureSampleRecordGetLinks,
  attach: _postureSampleRecordAttach,
  version: '3.1.0+1',
);

int _postureSampleRecordEstimateSize(
  PostureSampleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.postureKey.length * 3;
  bytesCount += 3 + object.riskLevelKey.length * 3;
  return bytesCount;
}

void _postureSampleRecordSerialize(
  PostureSampleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeLong(offsets[1], object.continuousHoldSeconds);
  writer.writeLong(offsets[2], object.durationSeconds);
  writer.writeString(offsets[3], object.postureKey);
  writer.writeString(offsets[4], object.riskLevelKey);
}

PostureSampleRecord _postureSampleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PostureSampleRecord();
  object.capturedAt = reader.readDateTime(offsets[0]);
  object.continuousHoldSeconds = reader.readLong(offsets[1]);
  object.durationSeconds = reader.readLong(offsets[2]);
  object.id = id;
  object.postureKey = reader.readString(offsets[3]);
  object.riskLevelKey = reader.readString(offsets[4]);
  return object;
}

P _postureSampleRecordDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _postureSampleRecordGetId(PostureSampleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _postureSampleRecordGetLinks(
    PostureSampleRecord object) {
  return [];
}

void _postureSampleRecordAttach(
    IsarCollection<dynamic> col, Id id, PostureSampleRecord object) {
  object.id = id;
}

extension PostureSampleRecordQueryWhereSort
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QWhere> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PostureSampleRecordQueryWhere
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QWhereClause> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhereClause>
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterWhereClause>
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

extension PostureSampleRecordQueryFilter on QueryBuilder<PostureSampleRecord,
    PostureSampleRecord, QFilterCondition> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      capturedAtGreaterThan(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      capturedAtLessThan(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      capturedAtBetween(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      continuousHoldSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'continuousHoldSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      continuousHoldSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'continuousHoldSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      continuousHoldSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'continuousHoldSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      continuousHoldSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'continuousHoldSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      durationSecondsGreaterThan(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      durationSecondsLessThan(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      durationSecondsBetween(
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postureKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'postureKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'postureKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postureKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      postureKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'postureKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'riskLevelKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'riskLevelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'riskLevelKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riskLevelKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterFilterCondition>
      riskLevelKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'riskLevelKey',
        value: '',
      ));
    });
  }
}

extension PostureSampleRecordQueryObject on QueryBuilder<PostureSampleRecord,
    PostureSampleRecord, QFilterCondition> {}

extension PostureSampleRecordQueryLinks on QueryBuilder<PostureSampleRecord,
    PostureSampleRecord, QFilterCondition> {}

extension PostureSampleRecordQuerySortBy
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QSortBy> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByContinuousHoldSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousHoldSeconds', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByContinuousHoldSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousHoldSeconds', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByPostureKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureKey', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByPostureKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureKey', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByRiskLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevelKey', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      sortByRiskLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevelKey', Sort.desc);
    });
  }
}

extension PostureSampleRecordQuerySortThenBy
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QSortThenBy> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByContinuousHoldSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousHoldSeconds', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByContinuousHoldSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'continuousHoldSeconds', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByPostureKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureKey', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByPostureKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureKey', Sort.desc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByRiskLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevelKey', Sort.asc);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QAfterSortBy>
      thenByRiskLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riskLevelKey', Sort.desc);
    });
  }
}

extension PostureSampleRecordQueryWhereDistinct
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct> {
  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct>
      distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct>
      distinctByContinuousHoldSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'continuousHoldSeconds');
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct>
      distinctByPostureKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postureKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PostureSampleRecord, PostureSampleRecord, QDistinct>
      distinctByRiskLevelKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'riskLevelKey', caseSensitive: caseSensitive);
    });
  }
}

extension PostureSampleRecordQueryProperty
    on QueryBuilder<PostureSampleRecord, PostureSampleRecord, QQueryProperty> {
  QueryBuilder<PostureSampleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PostureSampleRecord, DateTime, QQueryOperations>
      capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<PostureSampleRecord, int, QQueryOperations>
      continuousHoldSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'continuousHoldSeconds');
    });
  }

  QueryBuilder<PostureSampleRecord, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<PostureSampleRecord, String, QQueryOperations>
      postureKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postureKey');
    });
  }

  QueryBuilder<PostureSampleRecord, String, QQueryOperations>
      riskLevelKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'riskLevelKey');
    });
  }
}
