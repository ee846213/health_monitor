// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_health_event_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCaptureHealthEventRecordCollection on Isar {
  IsarCollection<CaptureHealthEventRecord> get captureHealthEventRecords =>
      this.collection();
}

const CaptureHealthEventRecordSchema = CollectionSchema(
  name: r'CaptureHealthEventRecord',
  id: 2262803109716403061,
  properties: {
    r'detail': PropertySchema(
      id: 0,
      name: r'detail',
      type: IsarType.string,
    ),
    r'errorMessage': PropertySchema(
      id: 1,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'eventId': PropertySchema(
      id: 2,
      name: r'eventId',
      type: IsarType.string,
    ),
    r'eventTypeKey': PropertySchema(
      id: 3,
      name: r'eventTypeKey',
      type: IsarType.string,
    ),
    r'gapSeconds': PropertySchema(
      id: 4,
      name: r'gapSeconds',
      type: IsarType.long,
    ),
    r'occurredAt': PropertySchema(
      id: 5,
      name: r'occurredAt',
      type: IsarType.dateTime,
    ),
    r'sampleCount': PropertySchema(
      id: 6,
      name: r'sampleCount',
      type: IsarType.long,
    ),
    r'streamKey': PropertySchema(
      id: 7,
      name: r'streamKey',
      type: IsarType.string,
    )
  },
  estimateSize: _captureHealthEventRecordEstimateSize,
  serialize: _captureHealthEventRecordSerialize,
  deserialize: _captureHealthEventRecordDeserialize,
  deserializeProp: _captureHealthEventRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _captureHealthEventRecordGetId,
  getLinks: _captureHealthEventRecordGetLinks,
  attach: _captureHealthEventRecordAttach,
  version: '3.1.0+1',
);

int _captureHealthEventRecordEstimateSize(
  CaptureHealthEventRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.detail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.eventId.length * 3;
  bytesCount += 3 + object.eventTypeKey.length * 3;
  bytesCount += 3 + object.streamKey.length * 3;
  return bytesCount;
}

void _captureHealthEventRecordSerialize(
  CaptureHealthEventRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.detail);
  writer.writeString(offsets[1], object.errorMessage);
  writer.writeString(offsets[2], object.eventId);
  writer.writeString(offsets[3], object.eventTypeKey);
  writer.writeLong(offsets[4], object.gapSeconds);
  writer.writeDateTime(offsets[5], object.occurredAt);
  writer.writeLong(offsets[6], object.sampleCount);
  writer.writeString(offsets[7], object.streamKey);
}

CaptureHealthEventRecord _captureHealthEventRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CaptureHealthEventRecord();
  object.detail = reader.readStringOrNull(offsets[0]);
  object.errorMessage = reader.readStringOrNull(offsets[1]);
  object.eventId = reader.readString(offsets[2]);
  object.eventTypeKey = reader.readString(offsets[3]);
  object.gapSeconds = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.occurredAt = reader.readDateTime(offsets[5]);
  object.sampleCount = reader.readLongOrNull(offsets[6]);
  object.streamKey = reader.readString(offsets[7]);
  return object;
}

P _captureHealthEventRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _captureHealthEventRecordGetId(CaptureHealthEventRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _captureHealthEventRecordGetLinks(
    CaptureHealthEventRecord object) {
  return [];
}

void _captureHealthEventRecordAttach(
    IsarCollection<dynamic> col, Id id, CaptureHealthEventRecord object) {
  object.id = id;
}

extension CaptureHealthEventRecordQueryWhereSort on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QWhere> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CaptureHealthEventRecordQueryWhere on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QWhereClause> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
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

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
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

extension CaptureHealthEventRecordQueryFilter on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QFilterCondition> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'detail',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'detail',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      detailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      detailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> detailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detail',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventTypeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      eventTypeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      eventTypeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventTypeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> eventTypeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gapSeconds',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gapSeconds',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gapSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gapSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gapSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> gapSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gapSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
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

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
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

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
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

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> occurredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> occurredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> occurredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> occurredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sampleCount',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sampleCount',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> sampleCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      streamKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
          QAfterFilterCondition>
      streamKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord,
      QAfterFilterCondition> streamKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamKey',
        value: '',
      ));
    });
  }
}

extension CaptureHealthEventRecordQueryObject on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QFilterCondition> {}

extension CaptureHealthEventRecordQueryLinks on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QFilterCondition> {}

extension CaptureHealthEventRecordQuerySortBy on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QSortBy> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByEventTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByEventTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByGapSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapSeconds', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByGapSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapSeconds', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByStreamKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      sortByStreamKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.desc);
    });
  }
}

extension CaptureHealthEventRecordQuerySortThenBy on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QSortThenBy> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detail', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByEventTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByEventTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByGapSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapSeconds', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByGapSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapSeconds', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByOccurredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurredAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByStreamKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QAfterSortBy>
      thenByStreamKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.desc);
    });
  }
}

extension CaptureHealthEventRecordQueryWhereDistinct on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct> {
  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByDetail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByEventTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventTypeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByGapSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gapSeconds');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByOccurredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurredAt');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleCount');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, CaptureHealthEventRecord, QDistinct>
      distinctByStreamKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamKey', caseSensitive: caseSensitive);
    });
  }
}

extension CaptureHealthEventRecordQueryProperty on QueryBuilder<
    CaptureHealthEventRecord, CaptureHealthEventRecord, QQueryProperty> {
  QueryBuilder<CaptureHealthEventRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, String?, QQueryOperations>
      detailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detail');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, String?, QQueryOperations>
      errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, String, QQueryOperations>
      eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, String, QQueryOperations>
      eventTypeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventTypeKey');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, int?, QQueryOperations>
      gapSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gapSeconds');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, DateTime, QQueryOperations>
      occurredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurredAt');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, int?, QQueryOperations>
      sampleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleCount');
    });
  }

  QueryBuilder<CaptureHealthEventRecord, String, QQueryOperations>
      streamKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamKey');
    });
  }
}
