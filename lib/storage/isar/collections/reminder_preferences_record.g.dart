// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_preferences_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReminderPreferencesRecordCollection on Isar {
  IsarCollection<ReminderPreferencesRecord> get reminderPreferencesRecords =>
      this.collection();
}

const ReminderPreferencesRecordSchema = CollectionSchema(
  name: r'ReminderPreferencesRecord',
  id: 1771903679576750069,
  properties: {
    r'masterEnabled': PropertySchema(
      id: 0,
      name: r'masterEnabled',
      type: IsarType.bool,
    ),
    r'nightUsageEnabled': PropertySchema(
      id: 1,
      name: r'nightUsageEnabled',
      type: IsarType.bool,
    ),
    r'noisyEnvironmentEnabled': PropertySchema(
      id: 2,
      name: r'noisyEnvironmentEnabled',
      type: IsarType.bool,
    ),
    r'postureRiskEnabled': PropertySchema(
      id: 3,
      name: r'postureRiskEnabled',
      type: IsarType.bool,
    ),
    r'sedentaryEnabled': PropertySchema(
      id: 4,
      name: r'sedentaryEnabled',
      type: IsarType.bool,
    ),
    r'walkingScreenEnabled': PropertySchema(
      id: 5,
      name: r'walkingScreenEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _reminderPreferencesRecordEstimateSize,
  serialize: _reminderPreferencesRecordSerialize,
  deserialize: _reminderPreferencesRecordDeserialize,
  deserializeProp: _reminderPreferencesRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _reminderPreferencesRecordGetId,
  getLinks: _reminderPreferencesRecordGetLinks,
  attach: _reminderPreferencesRecordAttach,
  version: '3.1.0+1',
);

int _reminderPreferencesRecordEstimateSize(
  ReminderPreferencesRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _reminderPreferencesRecordSerialize(
  ReminderPreferencesRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.masterEnabled);
  writer.writeBool(offsets[1], object.nightUsageEnabled);
  writer.writeBool(offsets[2], object.noisyEnvironmentEnabled);
  writer.writeBool(offsets[3], object.postureRiskEnabled);
  writer.writeBool(offsets[4], object.sedentaryEnabled);
  writer.writeBool(offsets[5], object.walkingScreenEnabled);
}

ReminderPreferencesRecord _reminderPreferencesRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReminderPreferencesRecord();
  object.id = id;
  object.masterEnabled = reader.readBool(offsets[0]);
  object.nightUsageEnabled = reader.readBool(offsets[1]);
  object.noisyEnvironmentEnabled = reader.readBool(offsets[2]);
  object.postureRiskEnabled = reader.readBool(offsets[3]);
  object.sedentaryEnabled = reader.readBool(offsets[4]);
  object.walkingScreenEnabled = reader.readBool(offsets[5]);
  return object;
}

P _reminderPreferencesRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reminderPreferencesRecordGetId(ReminderPreferencesRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reminderPreferencesRecordGetLinks(
    ReminderPreferencesRecord object) {
  return [];
}

void _reminderPreferencesRecordAttach(
    IsarCollection<dynamic> col, Id id, ReminderPreferencesRecord object) {
  object.id = id;
}

extension ReminderPreferencesRecordQueryWhereSort on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QWhere> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ReminderPreferencesRecordQueryWhere on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QWhereClause> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
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

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
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

extension ReminderPreferencesRecordQueryFilter on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QFilterCondition> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
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

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
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

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
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

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> masterEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'masterEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> nightUsageEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nightUsageEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> noisyEnvironmentEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noisyEnvironmentEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> postureRiskEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postureRiskEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> sedentaryEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sedentaryEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterFilterCondition> walkingScreenEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walkingScreenEnabled',
        value: value,
      ));
    });
  }
}

extension ReminderPreferencesRecordQueryObject on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QFilterCondition> {}

extension ReminderPreferencesRecordQueryLinks on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QFilterCondition> {}

extension ReminderPreferencesRecordQuerySortBy on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QSortBy> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByMasterEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masterEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByMasterEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masterEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByNightUsageEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nightUsageEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByNightUsageEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nightUsageEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByNoisyEnvironmentEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noisyEnvironmentEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByNoisyEnvironmentEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noisyEnvironmentEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByPostureRiskEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByPostureRiskEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortBySedentaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentaryEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortBySedentaryEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentaryEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByWalkingScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkingScreenEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> sortByWalkingScreenEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkingScreenEnabled', Sort.desc);
    });
  }
}

extension ReminderPreferencesRecordQuerySortThenBy on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QSortThenBy> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByMasterEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masterEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByMasterEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masterEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByNightUsageEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nightUsageEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByNightUsageEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nightUsageEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByNoisyEnvironmentEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noisyEnvironmentEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByNoisyEnvironmentEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noisyEnvironmentEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByPostureRiskEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByPostureRiskEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postureRiskEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenBySedentaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentaryEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenBySedentaryEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sedentaryEnabled', Sort.desc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByWalkingScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkingScreenEnabled', Sort.asc);
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord,
      QAfterSortBy> thenByWalkingScreenEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walkingScreenEnabled', Sort.desc);
    });
  }
}

extension ReminderPreferencesRecordQueryWhereDistinct on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct> {
  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctByMasterEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'masterEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctByNightUsageEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nightUsageEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctByNoisyEnvironmentEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noisyEnvironmentEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctByPostureRiskEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postureRiskEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctBySedentaryEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sedentaryEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, ReminderPreferencesRecord, QDistinct>
      distinctByWalkingScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walkingScreenEnabled');
    });
  }
}

extension ReminderPreferencesRecordQueryProperty on QueryBuilder<
    ReminderPreferencesRecord, ReminderPreferencesRecord, QQueryProperty> {
  QueryBuilder<ReminderPreferencesRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      masterEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'masterEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      nightUsageEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nightUsageEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      noisyEnvironmentEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noisyEnvironmentEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      postureRiskEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postureRiskEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      sedentaryEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sedentaryEnabled');
    });
  }

  QueryBuilder<ReminderPreferencesRecord, bool, QQueryOperations>
      walkingScreenEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walkingScreenEnabled');
    });
  }
}
