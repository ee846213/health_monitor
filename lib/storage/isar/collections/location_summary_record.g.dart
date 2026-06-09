// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_summary_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocationSummaryRecordCollection on Isar {
  IsarCollection<LocationSummaryRecord> get locationSummaryRecords =>
      this.collection();
}

const LocationSummaryRecordSchema = CollectionSchema(
  name: r'LocationSummaryRecord',
  id: -243165542391819769,
  properties: {
    r'commuteCount': PropertySchema(
      id: 0,
      name: r'commuteCount',
      type: IsarType.long,
    ),
    r'dateKey': PropertySchema(
      id: 1,
      name: r'dateKey',
      type: IsarType.string,
    ),
    r'distanceMeters': PropertySchema(
      id: 2,
      name: r'distanceMeters',
      type: IsarType.double,
    ),
    r'outdoorDurationSeconds': PropertySchema(
      id: 3,
      name: r'outdoorDurationSeconds',
      type: IsarType.long,
    ),
    r'visitCount': PropertySchema(
      id: 4,
      name: r'visitCount',
      type: IsarType.long,
    )
  },
  estimateSize: _locationSummaryRecordEstimateSize,
  serialize: _locationSummaryRecordSerialize,
  deserialize: _locationSummaryRecordDeserialize,
  deserializeProp: _locationSummaryRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _locationSummaryRecordGetId,
  getLinks: _locationSummaryRecordGetLinks,
  attach: _locationSummaryRecordAttach,
  version: '3.1.0+1',
);

int _locationSummaryRecordEstimateSize(
  LocationSummaryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateKey.length * 3;
  return bytesCount;
}

void _locationSummaryRecordSerialize(
  LocationSummaryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.commuteCount);
  writer.writeString(offsets[1], object.dateKey);
  writer.writeDouble(offsets[2], object.distanceMeters);
  writer.writeLong(offsets[3], object.outdoorDurationSeconds);
  writer.writeLong(offsets[4], object.visitCount);
}

LocationSummaryRecord _locationSummaryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocationSummaryRecord();
  object.commuteCount = reader.readLong(offsets[0]);
  object.dateKey = reader.readString(offsets[1]);
  object.distanceMeters = reader.readDouble(offsets[2]);
  object.id = id;
  object.outdoorDurationSeconds = reader.readLong(offsets[3]);
  object.visitCount = reader.readLong(offsets[4]);
  return object;
}

P _locationSummaryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _locationSummaryRecordGetId(LocationSummaryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _locationSummaryRecordGetLinks(
    LocationSummaryRecord object) {
  return [];
}

void _locationSummaryRecordAttach(
    IsarCollection<dynamic> col, Id id, LocationSummaryRecord object) {
  object.id = id;
}

extension LocationSummaryRecordQueryWhereSort
    on QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QWhere> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocationSummaryRecordQueryWhere on QueryBuilder<LocationSummaryRecord,
    LocationSummaryRecord, QWhereClause> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhereClause>
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterWhereClause>
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

extension LocationSummaryRecordQueryFilter on QueryBuilder<
    LocationSummaryRecord, LocationSummaryRecord, QFilterCondition> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> commuteCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commuteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> commuteCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commuteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> commuteCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commuteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> commuteCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commuteCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyEqualTo(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyGreaterThan(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyLessThan(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyBetween(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyStartsWith(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyEndsWith(
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
          QAfterFilterCondition>
      dateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
          QAfterFilterCondition>
      dateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> dateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> distanceMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> distanceMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> distanceMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> distanceMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distanceMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
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

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> outdoorDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outdoorDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> outdoorDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outdoorDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> outdoorDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outdoorDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> outdoorDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outdoorDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> visitCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> visitCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> visitCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord,
      QAfterFilterCondition> visitCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocationSummaryRecordQueryObject on QueryBuilder<
    LocationSummaryRecord, LocationSummaryRecord, QFilterCondition> {}

extension LocationSummaryRecordQueryLinks on QueryBuilder<LocationSummaryRecord,
    LocationSummaryRecord, QFilterCondition> {}

extension LocationSummaryRecordQuerySortBy
    on QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QSortBy> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByCommuteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commuteCount', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByCommuteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commuteCount', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByOutdoorDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByOutdoorDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      sortByVisitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.desc);
    });
  }
}

extension LocationSummaryRecordQuerySortThenBy
    on QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QSortThenBy> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByCommuteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commuteCount', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByCommuteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commuteCount', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByOutdoorDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByOutdoorDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outdoorDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.asc);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QAfterSortBy>
      thenByVisitCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitCount', Sort.desc);
    });
  }
}

extension LocationSummaryRecordQueryWhereDistinct
    on QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct> {
  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct>
      distinctByCommuteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commuteCount');
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct>
      distinctByDateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct>
      distinctByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceMeters');
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct>
      distinctByOutdoorDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outdoorDurationSeconds');
    });
  }

  QueryBuilder<LocationSummaryRecord, LocationSummaryRecord, QDistinct>
      distinctByVisitCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitCount');
    });
  }
}

extension LocationSummaryRecordQueryProperty on QueryBuilder<
    LocationSummaryRecord, LocationSummaryRecord, QQueryProperty> {
  QueryBuilder<LocationSummaryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocationSummaryRecord, int, QQueryOperations>
      commuteCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commuteCount');
    });
  }

  QueryBuilder<LocationSummaryRecord, String, QQueryOperations>
      dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<LocationSummaryRecord, double, QQueryOperations>
      distanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceMeters');
    });
  }

  QueryBuilder<LocationSummaryRecord, int, QQueryOperations>
      outdoorDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outdoorDurationSeconds');
    });
  }

  QueryBuilder<LocationSummaryRecord, int, QQueryOperations>
      visitCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitCount');
    });
  }
}
