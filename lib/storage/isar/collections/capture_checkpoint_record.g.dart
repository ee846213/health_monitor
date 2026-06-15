// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_checkpoint_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCaptureCheckpointRecordCollection on Isar {
  IsarCollection<CaptureCheckpointRecord> get captureCheckpointRecords =>
      this.collection();
}

const CaptureCheckpointRecordSchema = CollectionSchema(
  name: r'CaptureCheckpointRecord',
  id: -3213988144291686195,
  properties: {
    r'gapCount': PropertySchema(
      id: 0,
      name: r'gapCount',
      type: IsarType.long,
    ),
    r'lastErrorAt': PropertySchema(
      id: 1,
      name: r'lastErrorAt',
      type: IsarType.dateTime,
    ),
    r'lastErrorMessage': PropertySchema(
      id: 2,
      name: r'lastErrorMessage',
      type: IsarType.string,
    ),
    r'lastEventAt': PropertySchema(
      id: 3,
      name: r'lastEventAt',
      type: IsarType.dateTime,
    ),
    r'lastEventTypeKey': PropertySchema(
      id: 4,
      name: r'lastEventTypeKey',
      type: IsarType.string,
    ),
    r'lastMessage': PropertySchema(
      id: 5,
      name: r'lastMessage',
      type: IsarType.string,
    ),
    r'lastNativeSummaryDrainedAt': PropertySchema(
      id: 6,
      name: r'lastNativeSummaryDrainedAt',
      type: IsarType.dateTime,
    ),
    r'lastRecoveredAt': PropertySchema(
      id: 7,
      name: r'lastRecoveredAt',
      type: IsarType.dateTime,
    ),
    r'lastSampleAt': PropertySchema(
      id: 8,
      name: r'lastSampleAt',
      type: IsarType.dateTime,
    ),
    r'lastStateRebuiltAt': PropertySchema(
      id: 9,
      name: r'lastStateRebuiltAt',
      type: IsarType.dateTime,
    ),
    r'recoveryCount': PropertySchema(
      id: 10,
      name: r'recoveryCount',
      type: IsarType.long,
    ),
    r'sampleCount': PropertySchema(
      id: 11,
      name: r'sampleCount',
      type: IsarType.long,
    ),
    r'stateKey': PropertySchema(
      id: 12,
      name: r'stateKey',
      type: IsarType.string,
    ),
    r'streamKey': PropertySchema(
      id: 13,
      name: r'streamKey',
      type: IsarType.string,
    )
  },
  estimateSize: _captureCheckpointRecordEstimateSize,
  serialize: _captureCheckpointRecordSerialize,
  deserialize: _captureCheckpointRecordDeserialize,
  deserializeProp: _captureCheckpointRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _captureCheckpointRecordGetId,
  getLinks: _captureCheckpointRecordGetLinks,
  attach: _captureCheckpointRecordAttach,
  version: '3.1.0+1',
);

int _captureCheckpointRecordEstimateSize(
  CaptureCheckpointRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lastErrorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastEventTypeKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.stateKey.length * 3;
  bytesCount += 3 + object.streamKey.length * 3;
  return bytesCount;
}

void _captureCheckpointRecordSerialize(
  CaptureCheckpointRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.gapCount);
  writer.writeDateTime(offsets[1], object.lastErrorAt);
  writer.writeString(offsets[2], object.lastErrorMessage);
  writer.writeDateTime(offsets[3], object.lastEventAt);
  writer.writeString(offsets[4], object.lastEventTypeKey);
  writer.writeString(offsets[5], object.lastMessage);
  writer.writeDateTime(offsets[6], object.lastNativeSummaryDrainedAt);
  writer.writeDateTime(offsets[7], object.lastRecoveredAt);
  writer.writeDateTime(offsets[8], object.lastSampleAt);
  writer.writeDateTime(offsets[9], object.lastStateRebuiltAt);
  writer.writeLong(offsets[10], object.recoveryCount);
  writer.writeLong(offsets[11], object.sampleCount);
  writer.writeString(offsets[12], object.stateKey);
  writer.writeString(offsets[13], object.streamKey);
}

CaptureCheckpointRecord _captureCheckpointRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CaptureCheckpointRecord();
  object.gapCount = reader.readLong(offsets[0]);
  object.id = id;
  object.lastErrorAt = reader.readDateTimeOrNull(offsets[1]);
  object.lastErrorMessage = reader.readStringOrNull(offsets[2]);
  object.lastEventAt = reader.readDateTimeOrNull(offsets[3]);
  object.lastEventTypeKey = reader.readStringOrNull(offsets[4]);
  object.lastMessage = reader.readStringOrNull(offsets[5]);
  object.lastNativeSummaryDrainedAt = reader.readDateTimeOrNull(offsets[6]);
  object.lastRecoveredAt = reader.readDateTimeOrNull(offsets[7]);
  object.lastSampleAt = reader.readDateTimeOrNull(offsets[8]);
  object.lastStateRebuiltAt = reader.readDateTimeOrNull(offsets[9]);
  object.recoveryCount = reader.readLong(offsets[10]);
  object.sampleCount = reader.readLong(offsets[11]);
  object.stateKey = reader.readString(offsets[12]);
  object.streamKey = reader.readString(offsets[13]);
  return object;
}

P _captureCheckpointRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _captureCheckpointRecordGetId(CaptureCheckpointRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _captureCheckpointRecordGetLinks(
    CaptureCheckpointRecord object) {
  return [];
}

void _captureCheckpointRecordAttach(
    IsarCollection<dynamic> col, Id id, CaptureCheckpointRecord object) {
  object.id = id;
}

extension CaptureCheckpointRecordQueryWhereSort
    on QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QWhere> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CaptureCheckpointRecordQueryWhere on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QWhereClause> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

extension CaptureCheckpointRecordQueryFilter on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QFilterCondition> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> gapCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gapCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> gapCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gapCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> gapCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gapCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> gapCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gapCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastErrorAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastErrorAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastErrorAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastErrorAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastErrorAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastErrorAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastErrorMessage',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastErrorMessage',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastErrorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastErrorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastErrorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastErrorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastErrorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastErrorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastErrorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastErrorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEventAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEventAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEventAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEventAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEventAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEventAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastEventTypeKey',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastEventTypeKey',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEventTypeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastEventTypeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastEventTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastEventTypeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastEventTypeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEventTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastEventTypeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastEventTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastNativeSummaryDrainedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastNativeSummaryDrainedAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastNativeSummaryDrainedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastNativeSummaryDrainedAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      lastNativeSummaryDrainedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastNativeSummaryDrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastNativeSummaryDrainedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastNativeSummaryDrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastNativeSummaryDrainedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastNativeSummaryDrainedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastNativeSummaryDrainedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastNativeSummaryDrainedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastRecoveredAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastRecoveredAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRecoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastRecoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastRecoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastRecoveredAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastRecoveredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSampleAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSampleAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSampleAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSampleAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSampleAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastSampleAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSampleAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastStateRebuiltAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastStateRebuiltAt',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastStateRebuiltAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastStateRebuiltAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastStateRebuiltAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> lastStateRebuiltAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastStateRebuiltAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> recoveryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recoveryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> recoveryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recoveryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> recoveryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recoveryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> recoveryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recoveryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> sampleCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> sampleCountGreaterThan(
    int value, {
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> sampleCountLessThan(
    int value, {
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> sampleCountBetween(
    int lower,
    int upper, {
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      stateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
          QAfterFilterCondition>
      stateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> stateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
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

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> streamKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord,
      QAfterFilterCondition> streamKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamKey',
        value: '',
      ));
    });
  }
}

extension CaptureCheckpointRecordQueryObject on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QFilterCondition> {}

extension CaptureCheckpointRecordQueryLinks on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QFilterCondition> {}

extension CaptureCheckpointRecordQuerySortBy
    on QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QSortBy> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByGapCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByGapCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastErrorAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastErrorAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastEventAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastEventAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastEventTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventTypeKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastEventTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventTypeKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastNativeSummaryDrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNativeSummaryDrainedAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastNativeSummaryDrainedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNativeSummaryDrainedAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRecoveredAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastRecoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRecoveredAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastSampleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSampleAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastSampleAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSampleAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastStateRebuiltAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStateRebuiltAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByLastStateRebuiltAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStateRebuiltAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByRecoveryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByRecoveryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByStateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByStateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByStreamKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      sortByStreamKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.desc);
    });
  }
}

extension CaptureCheckpointRecordQuerySortThenBy on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QSortThenBy> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByGapCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByGapCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gapCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastErrorAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastErrorAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastEventAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastEventAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastEventTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventTypeKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastEventTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastEventTypeKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastNativeSummaryDrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNativeSummaryDrainedAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastNativeSummaryDrainedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNativeSummaryDrainedAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRecoveredAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastRecoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRecoveredAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastSampleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSampleAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastSampleAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSampleAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastStateRebuiltAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStateRebuiltAt', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByLastStateRebuiltAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStateRebuiltAt', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByRecoveryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByRecoveryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recoveryCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByStateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByStateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateKey', Sort.desc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByStreamKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.asc);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QAfterSortBy>
      thenByStreamKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamKey', Sort.desc);
    });
  }
}

extension CaptureCheckpointRecordQueryWhereDistinct on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct> {
  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByGapCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gapCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastErrorAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastErrorAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastErrorMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastErrorMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastEventAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEventAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastEventTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastEventTypeKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastNativeSummaryDrainedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastNativeSummaryDrainedAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRecoveredAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastSampleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSampleAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByLastStateRebuiltAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastStateRebuiltAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByRecoveryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recoveryCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByStateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CaptureCheckpointRecord, CaptureCheckpointRecord, QDistinct>
      distinctByStreamKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamKey', caseSensitive: caseSensitive);
    });
  }
}

extension CaptureCheckpointRecordQueryProperty on QueryBuilder<
    CaptureCheckpointRecord, CaptureCheckpointRecord, QQueryProperty> {
  QueryBuilder<CaptureCheckpointRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, int, QQueryOperations>
      gapCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gapCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastErrorAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastErrorAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, String?, QQueryOperations>
      lastErrorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastErrorMessage');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastEventAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEventAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, String?, QQueryOperations>
      lastEventTypeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastEventTypeKey');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, String?, QQueryOperations>
      lastMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessage');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastNativeSummaryDrainedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastNativeSummaryDrainedAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastRecoveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRecoveredAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastSampleAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSampleAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, DateTime?, QQueryOperations>
      lastStateRebuiltAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastStateRebuiltAt');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, int, QQueryOperations>
      recoveryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recoveryCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, int, QQueryOperations>
      sampleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleCount');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, String, QQueryOperations>
      stateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateKey');
    });
  }

  QueryBuilder<CaptureCheckpointRecord, String, QQueryOperations>
      streamKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamKey');
    });
  }
}
