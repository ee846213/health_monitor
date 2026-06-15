// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_record_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderRecordEntityCollection on Isar {
  IsarCollection<ReminderRecordEntity> get reminderRecordEntitys =>
      this.collection();
}

const ReminderRecordEntitySchema = CollectionSchema(
  name: r'ReminderRecordEntity',
  id: 8815024082856110441,
  properties: {
    r'actionSuggestion': PropertySchema(
      id: 0,
      name: r'actionSuggestion',
      type: IsarType.string,
    ),
    r'dateKey': PropertySchema(
      id: 1,
      name: r'dateKey',
      type: IsarType.string,
    ),
    r'message': PropertySchema(
      id: 2,
      name: r'message',
      type: IsarType.string,
    ),
    r'reasonSummary': PropertySchema(
      id: 3,
      name: r'reasonSummary',
      type: IsarType.string,
    ),
    r'reminderTypeKey': PropertySchema(
      id: 4,
      name: r'reminderTypeKey',
      type: IsarType.string,
    ),
    r'responseKey': PropertySchema(
      id: 5,
      name: r'responseKey',
      type: IsarType.string,
    ),
    r'sourceDimension': PropertySchema(
      id: 6,
      name: r'sourceDimension',
      type: IsarType.string,
    ),
    r'sourceEventId': PropertySchema(
      id: 7,
      name: r'sourceEventId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 8,
      name: r'title',
      type: IsarType.string,
    ),
    r'triggeredAt': PropertySchema(
      id: 9,
      name: r'triggeredAt',
      type: IsarType.dateTime,
    ),
    r'typeKey': PropertySchema(
      id: 10,
      name: r'typeKey',
      type: IsarType.string,
    )
  },
  estimateSize: _reminderRecordEntityEstimateSize,
  serialize: _reminderRecordEntitySerialize,
  deserialize: _reminderRecordEntityDeserialize,
  deserializeProp: _reminderRecordEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _reminderRecordEntityGetId,
  getLinks: _reminderRecordEntityGetLinks,
  attach: _reminderRecordEntityAttach,
  version: '3.1.0+1',
);

int _reminderRecordEntityEstimateSize(
  ReminderRecordEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionSuggestion.length * 3;
  bytesCount += 3 + object.dateKey.length * 3;
  bytesCount += 3 + object.message.length * 3;
  bytesCount += 3 + object.reasonSummary.length * 3;
  {
    final value = object.reminderTypeKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.responseKey.length * 3;
  {
    final value = object.sourceDimension;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceEventId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.typeKey.length * 3;
  return bytesCount;
}

void _reminderRecordEntitySerialize(
  ReminderRecordEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionSuggestion);
  writer.writeString(offsets[1], object.dateKey);
  writer.writeString(offsets[2], object.message);
  writer.writeString(offsets[3], object.reasonSummary);
  writer.writeString(offsets[4], object.reminderTypeKey);
  writer.writeString(offsets[5], object.responseKey);
  writer.writeString(offsets[6], object.sourceDimension);
  writer.writeString(offsets[7], object.sourceEventId);
  writer.writeString(offsets[8], object.title);
  writer.writeDateTime(offsets[9], object.triggeredAt);
  writer.writeString(offsets[10], object.typeKey);
}

ReminderRecordEntity _reminderRecordEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReminderRecordEntity();
  object.actionSuggestion = reader.readString(offsets[0]);
  object.dateKey = reader.readString(offsets[1]);
  object.id = id;
  object.message = reader.readString(offsets[2]);
  object.reasonSummary = reader.readString(offsets[3]);
  object.reminderTypeKey = reader.readStringOrNull(offsets[4]);
  object.responseKey = reader.readString(offsets[5]);
  object.sourceDimension = reader.readStringOrNull(offsets[6]);
  object.sourceEventId = reader.readStringOrNull(offsets[7]);
  object.title = reader.readString(offsets[8]);
  object.triggeredAt = reader.readDateTime(offsets[9]);
  object.typeKey = reader.readString(offsets[10]);
  return object;
}

P _reminderRecordEntityDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderRecordEntityGetId(ReminderRecordEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderRecordEntityGetLinks(
    ReminderRecordEntity object) {
  return [];
}

void _reminderRecordEntityAttach(
    IsarCollection<dynamic> col, Id id, ReminderRecordEntity object) {
  object.id = id;
}

extension ReminderRecordEntityQueryWhereSort
    on QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QWhere> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReminderRecordEntityQueryWhere
    on QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QWhereClause> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhereClause>
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterWhereClause>
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

extension ReminderRecordEntityQueryFilter on QueryBuilder<ReminderRecordEntity,
    ReminderRecordEntity, QFilterCondition> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionSuggestion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      actionSuggestionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionSuggestion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      actionSuggestionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionSuggestion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionSuggestion',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> actionSuggestionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionSuggestion',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> dateKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> dateKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'message',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'message',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'message',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'message',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reasonSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      reasonSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reasonSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      reasonSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reasonSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reasonSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reasonSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reasonSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reminderTypeKey',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reminderTypeKey',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderTypeKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      reminderTypeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reminderTypeKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      reminderTypeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reminderTypeKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> reminderTypeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reminderTypeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'responseKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      responseKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'responseKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      responseKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'responseKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> responseKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'responseKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceDimension',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceDimension',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceDimension',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      sourceDimensionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceDimension',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      sourceDimensionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceDimension',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceDimension',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceDimensionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceDimension',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceEventId',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceEventId',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceEventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      sourceEventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      sourceEventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceEventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> sourceEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> triggeredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> triggeredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> triggeredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> triggeredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggeredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
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

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> typeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity,
      QAfterFilterCondition> typeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'typeKey',
        value: '',
      ));
    });
  }
}

extension ReminderRecordEntityQueryObject on QueryBuilder<ReminderRecordEntity,
    ReminderRecordEntity, QFilterCondition> {}

extension ReminderRecordEntityQueryLinks on QueryBuilder<ReminderRecordEntity,
    ReminderRecordEntity, QFilterCondition> {}

extension ReminderRecordEntityQuerySortBy
    on QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QSortBy> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByActionSuggestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionSuggestion', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByActionSuggestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionSuggestion', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByReasonSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonSummary', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByReasonSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonSummary', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByReminderTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTypeKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByReminderTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTypeKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByResponseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByResponseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortBySourceDimension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDimension', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortBySourceDimensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDimension', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortBySourceEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEventId', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortBySourceEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEventId', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredAt', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTriggeredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredAt', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      sortByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ReminderRecordEntityQuerySortThenBy
    on QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QSortThenBy> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByActionSuggestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionSuggestion', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByActionSuggestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionSuggestion', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByDateKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByDateKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'message', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByReasonSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonSummary', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByReasonSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonSummary', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByReminderTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTypeKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByReminderTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderTypeKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByResponseKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByResponseKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseKey', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenBySourceDimension() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDimension', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenBySourceDimensionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceDimension', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenBySourceEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEventId', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenBySourceEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEventId', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredAt', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTriggeredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggeredAt', Sort.desc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTypeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.asc);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QAfterSortBy>
      thenByTypeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typeKey', Sort.desc);
    });
  }
}

extension ReminderRecordEntityQueryWhereDistinct
    on QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct> {
  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByActionSuggestion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionSuggestion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByDateKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'message', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByReasonSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reasonSummary',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByReminderTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderTypeKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByResponseKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctBySourceDimension({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceDimension',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctBySourceEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceEventId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByTriggeredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggeredAt');
    });
  }

  QueryBuilder<ReminderRecordEntity, ReminderRecordEntity, QDistinct>
      distinctByTypeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typeKey', caseSensitive: caseSensitive);
    });
  }
}

extension ReminderRecordEntityQueryProperty on QueryBuilder<
    ReminderRecordEntity, ReminderRecordEntity, QQueryProperty> {
  QueryBuilder<ReminderRecordEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      actionSuggestionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionSuggestion');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      dateKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateKey');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'message');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      reasonSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reasonSummary');
    });
  }

  QueryBuilder<ReminderRecordEntity, String?, QQueryOperations>
      reminderTypeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderTypeKey');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      responseKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseKey');
    });
  }

  QueryBuilder<ReminderRecordEntity, String?, QQueryOperations>
      sourceDimensionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceDimension');
    });
  }

  QueryBuilder<ReminderRecordEntity, String?, QQueryOperations>
      sourceEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceEventId');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ReminderRecordEntity, DateTime, QQueryOperations>
      triggeredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggeredAt');
    });
  }

  QueryBuilder<ReminderRecordEntity, String, QQueryOperations>
      typeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typeKey');
    });
  }
}
