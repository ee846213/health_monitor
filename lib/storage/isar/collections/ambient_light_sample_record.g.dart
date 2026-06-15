// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_light_sample_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAmbientLightSampleRecordCollection on Isar {
  IsarCollection<AmbientLightSampleRecord> get ambientLightSampleRecords =>
      this.collection();
}

const AmbientLightSampleRecordSchema = CollectionSchema(
  name: r'AmbientLightSampleRecord',
  id: 451624565993579936,
  properties: {
    r'capturedAt': PropertySchema(
      id: 0,
      name: r'capturedAt',
      type: IsarType.dateTime,
    ),
    r'durationSeconds': PropertySchema(
      id: 1,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'levelKey': PropertySchema(
      id: 2,
      name: r'levelKey',
      type: IsarType.string,
    ),
    r'lux': PropertySchema(
      id: 3,
      name: r'lux',
      type: IsarType.double,
    )
  },
  estimateSize: _ambientLightSampleRecordEstimateSize,
  serialize: _ambientLightSampleRecordSerialize,
  deserialize: _ambientLightSampleRecordDeserialize,
  deserializeProp: _ambientLightSampleRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _ambientLightSampleRecordGetId,
  getLinks: _ambientLightSampleRecordGetLinks,
  attach: _ambientLightSampleRecordAttach,
  version: '3.1.0+1',
);

int _ambientLightSampleRecordEstimateSize(
  AmbientLightSampleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.levelKey.length * 3;
  return bytesCount;
}

void _ambientLightSampleRecordSerialize(
  AmbientLightSampleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.capturedAt);
  writer.writeLong(offsets[1], object.durationSeconds);
  writer.writeString(offsets[2], object.levelKey);
  writer.writeDouble(offsets[3], object.lux);
}

AmbientLightSampleRecord _ambientLightSampleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AmbientLightSampleRecord();
  object.capturedAt = reader.readDateTime(offsets[0]);
  object.durationSeconds = reader.readLong(offsets[1]);
  object.id = id;
  object.levelKey = reader.readString(offsets[2]);
  object.lux = reader.readDouble(offsets[3]);
  return object;
}

P _ambientLightSampleRecordDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ambientLightSampleRecordGetId(AmbientLightSampleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ambientLightSampleRecordGetLinks(
    AmbientLightSampleRecord object) {
  return [];
}

void _ambientLightSampleRecordAttach(
    IsarCollection<dynamic> col, Id id, AmbientLightSampleRecord object) {
  object.id = id;
}

extension AmbientLightSampleRecordQueryWhereSort on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QWhere> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AmbientLightSampleRecordQueryWhere on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QWhereClause> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

extension AmbientLightSampleRecordQueryFilter on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QFilterCondition> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> capturedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capturedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> durationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyEqualTo(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyGreaterThan(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyLessThan(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyBetween(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyStartsWith(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyEndsWith(
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

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
          QAfterFilterCondition>
      levelKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'levelKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
          QAfterFilterCondition>
      levelKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'levelKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'levelKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> levelKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'levelKey',
        value: '',
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> luxEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lux',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> luxGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lux',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> luxLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lux',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord,
      QAfterFilterCondition> luxBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lux',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension AmbientLightSampleRecordQueryObject on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QFilterCondition> {}

extension AmbientLightSampleRecordQueryLinks on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QFilterCondition> {}

extension AmbientLightSampleRecordQuerySortBy on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QSortBy> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByLux() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lux', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      sortByLuxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lux', Sort.desc);
    });
  }
}

extension AmbientLightSampleRecordQuerySortThenBy on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QSortThenBy> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByCapturedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capturedAt', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByLevelKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByLevelKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'levelKey', Sort.desc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByLux() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lux', Sort.asc);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QAfterSortBy>
      thenByLuxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lux', Sort.desc);
    });
  }
}

extension AmbientLightSampleRecordQueryWhereDistinct on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QDistinct> {
  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QDistinct>
      distinctByCapturedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capturedAt');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QDistinct>
      distinctByLevelKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'levelKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AmbientLightSampleRecord, AmbientLightSampleRecord, QDistinct>
      distinctByLux() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lux');
    });
  }
}

extension AmbientLightSampleRecordQueryProperty on QueryBuilder<
    AmbientLightSampleRecord, AmbientLightSampleRecord, QQueryProperty> {
  QueryBuilder<AmbientLightSampleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, DateTime, QQueryOperations>
      capturedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capturedAt');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, int, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, String, QQueryOperations>
      levelKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'levelKey');
    });
  }

  QueryBuilder<AmbientLightSampleRecord, double, QQueryOperations>
      luxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lux');
    });
  }
}
