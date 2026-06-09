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
    r'dateKey': PropertySchema(
      id: 0,
      name: r'dateKey',
      type: IsarType.string,
    ),
    r'focusSessionBreakCount': PropertySchema(
      id: 1,
      name: r'focusSessionBreakCount',
      type: IsarType.long,
    ),
    r'nighttimeUsageSeconds': PropertySchema(
      id: 2,
      name: r'nighttimeUsageSeconds',
      type: IsarType.long,
    ),
    r'screenOnSeconds': PropertySchema(
      id: 3,
      name: r'screenOnSeconds',
      type: IsarType.long,
    ),
    r'topCategoryKey': PropertySchema(
      id: 4,
      name: r'topCategoryKey',
      type: IsarType.string,
    ),
    r'unlockCount': PropertySchema(
      id: 5,
      name: r'unlockCount',
      type: IsarType.long,
    )
  },
  estimateSize: _usageSummaryRecordEstimateSize,
  serialize: _usageSummaryRecordSerialize,
  deserialize: _usageSummaryRecordDeserialize,
  deserializeProp: _usageSummaryRecordDeserializeProp,
  idName: r'id',
  indexes: {},
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
  bytesCount += 3 + object.dateKey.length * 3;
  bytesCount += 3 + object.topCategoryKey.length * 3;
  return bytesCount;
}

void _usageSummaryRecordSerialize(
  UsageSummaryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dateKey);
  writer.writeLong(offsets[1], object.focusSessionBreakCount);
  writer.writeLong(offsets[2], object.nighttimeUsageSeconds);
  writer.writeLong(offsets[3], object.screenOnSeconds);
  writer.writeString(offsets[4], object.topCategoryKey);
  writer.writeLong(offsets[5], object.unlockCount);
}

UsageSummaryRecord _usageSummaryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsageSummaryRecord();
  object.dateKey = reader.readString(offsets[0]);
  object.focusSessionBreakCount = reader.readLong(offsets[1]);
  object.id = id;
  object.nighttimeUsageSeconds = reader.readLong(offsets[2]);
  object.screenOnSeconds = reader.readLong(offsets[3]);
  object.topCategoryKey = reader.readString(offsets[4]);
  object.unlockCount = reader.readLong(offsets[5]);
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
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
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
}

extension UsageSummaryRecordQueryFilter
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {
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
}

extension UsageSummaryRecordQueryObject
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {}

extension UsageSummaryRecordQueryLinks
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QFilterCondition> {}

extension UsageSummaryRecordQuerySortBy
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QSortBy> {
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
}

extension UsageSummaryRecordQuerySortThenBy
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QSortThenBy> {
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
}

extension UsageSummaryRecordQueryWhereDistinct
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QDistinct> {
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
}

extension UsageSummaryRecordQueryProperty
    on QueryBuilder<UsageSummaryRecord, UsageSummaryRecord, QQueryProperty> {
  QueryBuilder<UsageSummaryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
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
}
