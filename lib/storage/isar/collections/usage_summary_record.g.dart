// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_summary_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUsageSummaryRecordCollection on Isar {
  IsarCollection<UsageSummaryRecord> get usageSummaryRecords =>
      this.collection();
}

const UsageSummaryRecordSchema = CollectionSchema(
  name: r'UsageSummaryRecord',
  id: 166574982034450162,
  properties: {
    r'completenessKey': PropertySchema(
      id: 0,
      name: r'completenessKey',
      type: IsarType.string,
    ),
    r'dateKey': PropertySchema(
      id: 1,
      name: r'dateKey',
      type: IsarType.string,
    ),
    r'focusSessionBreakCount': PropertySchema(
      id: 2,
      name: r'focusSessionBreakCount',
      type: IsarType.long,
    ),
    r'longestContinuousUsageSeconds': PropertySchema(
      id: 3,
      name: r'longestContinuousUsageSeconds',
      type: IsarType.long,
    ),
    r'nighttimeUsageSeconds': PropertySchema(
      id: 4,
      name: r'nighttimeUsageSeconds',
      type: IsarType.long,
    ),
    r'screenOnSeconds': PropertySchema(
      id: 5,
      name: r'screenOnSeconds',
      type: IsarType.long,
    ),
    r'sourceKey': PropertySchema(
      id: 6,
      name: r'sourceKey',
      type: IsarType.string,
    ),
    r'topCategoryKey': PropertySchema(
      id: 7,
      name: r'topCategoryKey',
      type: IsarType.string,
    ),
    r'unlockCount': PropertySchema(
      id: 8,
      name: r'unlockCount',
      type: IsarType.long,
    ),
    r'viewCount': PropertySchema(
      id: 9,
      name: r'viewCount',
      type: IsarType.long,
    )
  },
  estimateSize: _usageSummaryRecordEstimateSize,
  serialize: _usageSummaryRecordSerialize,
  deserialize: _usageSummaryRecordDeserialize,
  deserializeProp: _usageSummaryRecordDeserializeProp,
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
  getId: _usageSummaryRecordGetId,
  getLinks: _usageSummaryRecordGetLinks,
  attach: _usageSummaryRecordAttach,
  version: '3.1.0+1',
);

int _usageSummaryRecordEstimateSize(
  UsageSummaryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completenessKey.length * 3;
  bytesCount += 3 + object.dateKey.length * 3;
  bytesCount += 3 + object.sourceKey.length * 3;
  bytesCount += 3 + object.topCategoryKey.length * 3;
  return bytesCount;
}

void _usageSummaryRecordSerialize(
  UsageSummaryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.completenessKey);
  writer.writeString(offsets[1], object.dateKey);
  writer.writeLong(offsets[2], object.focusSessionBreakCount);
  writer.writeLong(offsets[3], object.longestContinuousUsageSeconds);
  writer.writeLong(offsets[4], object.nighttimeUsageSeconds);
  writer.writeLong(offsets[5], object.screenOnSeconds);
  writer.writeString(offsets[6], object.sourceKey);
  writer.writeString(offsets[7], object.topCategoryKey);
  writer.writeLong(offsets[8], object.unlockCount);
  writer.writeLong(offsets[9], object.viewCount);
}

UsageSummaryRecord _usageSummaryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsageSummaryRecord();
  object.completenessKey = reader.readString(offsets[0]);
  object.dateKey = reader.readString(offsets[1]);
  object.focusSessionBreakCount = reader.readLong(offsets[2]);
  object.id = id;
  object.longestContinuousUsageSeconds = reader.readLong(offsets[3]);
  object.nighttimeUsageSeconds = reader.readLong(offsets[4]);
  object.screenOnSeconds = reader.readLong(offsets[5]);
  object.sourceKey = reader.readString(offsets[6]);
  object.topCategoryKey = reader.readString(offsets[7]);
  object.unlockCount = reader.readLong(offsets[8]);
  object.viewCount = reader.readLong(offsets[9]);
  return object;
}

P _usageSummaryRecordDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _usageSummaryRecordGetId(UsageSummaryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _usageSummaryRecordGetLinks(
    UsageSummaryRecord object) {
  return [];
}

void _usageSummaryRecordAttach(
    IsarCollection<dynamic> col, Id id, UsageSummaryRecord object) {
  object.id = id;
}

extension UsageSummaryRecordQueryWhereSort
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QWhere> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UsageSummaryRecordQueryWhere
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QWhereClause> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
      dateKeyEqualTo(String dateKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateKey',
        value: [dateKey],
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterWhereClause>
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

extension UsageSummaryRecordQueryFilter
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completenessKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completenessKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completenessKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completenessKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      completenessKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completenessKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      dateKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      dateKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      dateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      dateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      focusSessionBreakCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusSessionBreakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      focusSessionBreakCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusSessionBreakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      focusSessionBreakCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusSessionBreakCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      focusSessionBreakCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusSessionBreakCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      longestContinuousUsageSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestContinuousUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      longestContinuousUsageSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestContinuousUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      longestContinuousUsageSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestContinuousUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      longestContinuousUsageSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestContinuousUsageSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      nighttimeUsageSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nighttimeUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      nighttimeUsageSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nighttimeUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      nighttimeUsageSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nighttimeUsageSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      nighttimeUsageSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nighttimeUsageSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      screenOnSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'screenOnSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyEqualTo(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyGreaterThan(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyLessThan(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyBetween(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyStartsWith(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyEndsWith(
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

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      sourceKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topCategoryKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topCategoryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topCategoryKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topCategoryKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      topCategoryKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topCategoryKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      unlockCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      unlockCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      unlockCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      unlockCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      viewCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'viewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      viewCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'viewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      viewCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'viewCount',
        value: value,
      ));
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterFilterCondition>
      viewCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'viewCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UsageSummaryRecordQueryObject
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {}

extension UsageSummaryRecordQueryLinks
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {}

extension UsageSummaryRecordQuerySortBy
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QSortBy> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByCompletenessKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByCompletenessKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByFocusSessionBreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusSessionBreakCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByFocusSessionBreakCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusSessionBreakCount', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByLongestContinuousUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestContinuousUsageSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByLongestContinuousUsageSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestContinuousUsageSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByNighttimeUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nighttimeUsageSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByNighttimeUsageSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nighttimeUsageSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByScreenOnSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortBySourceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortBySourceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByTopCategoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByTopCategoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByUnlockCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByViewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      sortByViewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewCount', Sort.desc);
    });
  }
}

extension UsageSummaryRecordQuerySortThenBy
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QSortThenBy> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByCompletenessKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByCompletenessKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completenessKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByFocusSessionBreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusSessionBreakCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByFocusSessionBreakCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusSessionBreakCount', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByLongestContinuousUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestContinuousUsageSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByLongestContinuousUsageSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestContinuousUsageSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByNighttimeUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nighttimeUsageSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByNighttimeUsageSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nighttimeUsageSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByScreenOnSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenOnSeconds', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenBySourceKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenBySourceKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByTopCategoryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryKey', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByTopCategoryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryKey', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByUnlockCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockCount', Sort.desc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByViewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewCount', Sort.asc);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QAfterSortBy>
      thenByViewCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'viewCount', Sort.desc);
    });
  }
}

extension UsageSummaryRecordQueryWhereDistinct
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct> {
  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByCompletenessKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completenessKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByDateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByFocusSessionBreakCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusSessionBreakCount');
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByLongestContinuousUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestContinuousUsageSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByNighttimeUsageSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nighttimeUsageSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByScreenOnSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'screenOnSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctBySourceKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByTopCategoryKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topCategoryKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByUnlockCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockCount');
    });
  }

  QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct>
      distinctByViewCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'viewCount');
    });
  }
}

extension UsageSummaryRecordQueryProperty
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QQueryProperty> {
  QueryBuilder<UsageSummaryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UsageSummaryRecord, String, QQueryOperations>
      completenessKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completenessKey');
    });
  }

  QueryBuilder<UsageSummaryRecord, String, QQueryOperations> dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations>
      focusSessionBreakCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusSessionBreakCount');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations>
      longestContinuousUsageSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestContinuousUsageSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations>
      nighttimeUsageSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nighttimeUsageSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations>
      screenOnSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'screenOnSeconds');
    });
  }

  QueryBuilder<UsageSummaryRecord, String, QQueryOperations>
      sourceKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceKey');
    });
  }

  QueryBuilder<UsageSummaryRecord, String, QQueryOperations>
      topCategoryKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topCategoryKey');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations>
      unlockCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockCount');
    });
  }

  QueryBuilder<UsageSummaryRecord, int, QQueryOperations> viewCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'viewCount');
    });
  }
}
