// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationPreferenceRecordCollection on Isar {
  IsarCollection<NotificationPreferenceRecord>
      get notificationPreferenceRecords => this.collection();
}

const NotificationPreferenceRecordSchema = CollectionSchema(
  name: r'NotificationPreferenceRecord',
  id: -14003919946724848,
  properties: {
    r'enabled': PropertySchema(
      id: 0,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'endHour': PropertySchema(
      id: 1,
      name: r'endHour',
      type: IsarType.long,
    ),
    r'endMinute': PropertySchema(
      id: 2,
      name: r'endMinute',
      type: IsarType.long,
    ),
    r'startHour': PropertySchema(
      id: 3,
      name: r'startHour',
      type: IsarType.long,
    ),
    r'startMinute': PropertySchema(
      id: 4,
      name: r'startMinute',
      type: IsarType.long,
    )
  },
  estimateSize: _notificationPreferenceRecordEstimateSize,
  serialize: _notificationPreferenceRecordSerialize,
  deserialize: _notificationPreferenceRecordDeserialize,
  deserializeProp: _notificationPreferenceRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationPreferenceRecordGetId,
  getLinks: _notificationPreferenceRecordGetLinks,
  attach: _notificationPreferenceRecordAttach,
  version: '3.1.0+1',
);

int _notificationPreferenceRecordEstimateSize(
  NotificationPreferenceRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _notificationPreferenceRecordSerialize(
  NotificationPreferenceRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeLong(offsets[1], object.endHour);
  writer.writeLong(offsets[2], object.endMinute);
  writer.writeLong(offsets[3], object.startHour);
  writer.writeLong(offsets[4], object.startMinute);
}

NotificationPreferenceRecord _notificationPreferenceRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationPreferenceRecord();
  object.enabled = reader.readBool(offsets[0]);
  object.endHour = reader.readLong(offsets[1]);
  object.endMinute = reader.readLong(offsets[2]);
  object.id = id;
  object.startHour = reader.readLong(offsets[3]);
  object.startMinute = reader.readLong(offsets[4]);
  return object;
}

P _notificationPreferenceRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationPreferenceRecordGetId(NotificationPreferenceRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationPreferenceRecordGetLinks(
    NotificationPreferenceRecord object) {
  return [];
}

void _notificationPreferenceRecordAttach(
    IsarCollection<dynamic> col, Id id, NotificationPreferenceRecord object) {
  object.id = id;
}

extension NotificationPreferenceRecordQueryWhereSort on QueryBuilder<
    NotificationPreferenceRecord, NotificationPreferenceRecord, QWhere> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationPreferenceRecordQueryWhere on QueryBuilder<
    NotificationPreferenceRecord, NotificationPreferenceRecord, QWhereClause> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
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

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
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

extension NotificationPreferenceRecordQueryFilter on QueryBuilder<
    NotificationPreferenceRecord,
    NotificationPreferenceRecord,
    QFilterCondition> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> endMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
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

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
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

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
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

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startHour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterFilterCondition> startMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationPreferenceRecordQueryObject on QueryBuilder<
    NotificationPreferenceRecord,
    NotificationPreferenceRecord,
    QFilterCondition> {}

extension NotificationPreferenceRecordQueryLinks on QueryBuilder<
    NotificationPreferenceRecord,
    NotificationPreferenceRecord,
    QFilterCondition> {}

extension NotificationPreferenceRecordQuerySortBy on QueryBuilder<
    NotificationPreferenceRecord, NotificationPreferenceRecord, QSortBy> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> sortByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }
}

extension NotificationPreferenceRecordQuerySortThenBy on QueryBuilder<
    NotificationPreferenceRecord, NotificationPreferenceRecord, QSortThenBy> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByEndMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QAfterSortBy> thenByStartMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinute', Sort.desc);
    });
  }
}

extension NotificationPreferenceRecordQueryWhereDistinct on QueryBuilder<
    NotificationPreferenceRecord, NotificationPreferenceRecord, QDistinct> {
  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QDistinct> distinctByEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endHour');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QDistinct> distinctByEndMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMinute');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QDistinct> distinctByStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startHour');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, NotificationPreferenceRecord,
      QDistinct> distinctByStartMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMinute');
    });
  }
}

extension NotificationPreferenceRecordQueryProperty on QueryBuilder<
    NotificationPreferenceRecord,
    NotificationPreferenceRecord,
    QQueryProperty> {
  QueryBuilder<NotificationPreferenceRecord, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, bool, QQueryOperations>
      enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, int, QQueryOperations>
      endHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endHour');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, int, QQueryOperations>
      endMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMinute');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, int, QQueryOperations>
      startHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startHour');
    });
  }

  QueryBuilder<NotificationPreferenceRecord, int, QQueryOperations>
      startMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMinute');
    });
  }
}
