// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noise_sample_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoiseSampleRecordCollection on Isar {
  IsarCollection<NoiseSampleRecord> get noiseSampleRecords => this.collection();
}

const NoiseSampleRecordSchema = CollectionSchema(
  name: r'NoiseSampleRecord',
  id: 6360152550448225305,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'decibel': PropertySchema(
      id: 1,
      name: r'decibel',
      type: IsarType.double,
    ),
    r'durationSeconds': PropertySchema(
      id: 2,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'levelKey': PropertySchema(
      id: 3,
      name: r'levelKey',
      type: IsarType.string,
    )
  },
  estimateSize: _noiseSampleRecordEstimateSize,
  serialize: _noiseSampleRecordSerialize,
  deserialize: _noiseSampleRecordDeserialize,
  deserializeProp: _noiseSampleRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'capturedAt': IndexSchema(
      id: 7947551681198035194,
      name: r'capturedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'capturedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _noiseSampleRecordGetId,
  getLinks: _noiseSampleRecordGetLinks,
  attach: _noiseSampleRecordAttach,
  version: '3.1.0+1',
);

int _noiseSampleRecordEstimateSize(
  NoiseSampleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.levelKey.length * 3;
  return bytesCount;
}

void _noiseSampleRecordSerialize(
  NoiseSampleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeDouble(offsets[1], object.decibel);
  writer.writeLong(offsets[2], object.durationSeconds);
  writer.writeString(offsets[3], object.levelKey);
}

NoiseSampleRecord _noiseSampleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoiseSampleRecord();
  object.capturedAt = reader.readDateTime(offsets[0]);
  object.decibel = reader.readDouble(offsets[1]);
  object.durationSeconds = reader.readLong(offsets[2]);
  object.id = id;
  object.levelKey = reader.readString(offsets[3]);
  return object;
}

P _noiseSampleRecordDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _noiseSampleRecordGetId(NoiseSampleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noiseSampleRecordGetLinks(
    NoiseSampleRecord object) {
  return [];
}

void _noiseSampleRecordAttach(
    IsarCollection<dynamic> col, Id id, NoiseSampleRecord object) {
  object.id = id;
}

extension NoiseSampleRecordQueryWhereSort
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QWhere> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhere>
      anyCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'capturedAt'),
      );
    });
  }
}

extension NoiseSampleRecordQueryWhere
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QWhereClause> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      capturedAtEqualTo(DateTime capturedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'capturedAt',
        value: [capturedAt],
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      capturedAtNotEqualTo(DateTime capturedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [],
              upper: [capturedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [capturedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [capturedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'capturedAt',
              lower: [],
              upper: [capturedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      capturedAtGreaterThan(
    DateTime capturedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [capturedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      capturedAtLessThan(
    DateTime capturedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [],
        upper: [capturedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterWhereClause>
      capturedAtBetween(
    DateTime lowerCapturedAt,
    DateTime upperCapturedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'capturedAt',
        lower: [lowerCapturedAt],
        includeLower: includeLower,
        upper: [upperCapturedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoiseSampleRecordQueryFilter
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QFilterCondition> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      decibelEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      decibelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      decibelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      decibelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decibel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
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

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'levelKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'levelKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelKey',
        value: '',
      ));
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterFilterCondition>
      levelKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'levelKey',
        value: '',
      ));
    });
  }
}

extension NoiseSampleRecordQueryObject
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QFilterCondition> {}

extension NoiseSampleRecordQueryLinks
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QFilterCondition> {}

extension NoiseSampleRecordQuerySortBy
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QSortBy> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByDecibelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      sortByLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.desc);
    });
  }
}

extension NoiseSampleRecordQuerySortThenBy
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QSortThenBy> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByDecibelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.asc);
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QAfterSortBy>
      thenByLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.desc);
    });
  }
}

extension NoiseSampleRecordQueryWhereDistinct
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QDistinct> {
  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QDistinct>
      distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QDistinct>
      distinctByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decibel');
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QDistinct>
      distinctByLevelKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'levelKey', caseSensitive: caseSensitive);
    });
  }
}

extension NoiseSampleRecordQueryProperty
    on QueryBuilder<NoiseSampleRecord, NoiseSampleRecord, QQueryProperty> {
  QueryBuilder<NoiseSampleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NoiseSampleRecord, DateTime, QQueryOperations>
      capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<NoiseSampleRecord, double, QQueryOperations> decibelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decibel');
    });
  }

  QueryBuilder<NoiseSampleRecord, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<NoiseSampleRecord, String, QQueryOperations> levelKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'levelKey');
    });
  }
}
