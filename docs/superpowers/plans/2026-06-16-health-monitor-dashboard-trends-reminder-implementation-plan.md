# 健康监测首页仪表盘、趋势页与提醒链路实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 在现有 Flutter 健康监测应用上完成新版首页仪表盘、趋势分析页、真 LLM 每日建议气泡，以及带勿扰控制的本地提醒投递链路。

**架构：** 保留 `HealthInsightService` 作为规则输入与结论来源，在其上新增面向产品展示的聚合层，分别产出 `DashboardSnapshot`、`TrendSnapshot`、AI 建议结果和提醒投递决策。勿扰设置、AI 建议缓存和提醒投递状态落到 Isar，分数计算与投递规则保持纯 Dart，页面层只通过 Riverpod 消费 ViewModel。

**技术栈：** Flutter、Dart、Riverpod、GoRouter、Isar、Dio、flutter_local_notifications、CustomPaint、flutter_test

---

## 文件结构

### 新增文件

- `lib/domain/scoring/health_score_calculator.dart`
- `lib/domain/dashboard/dashboard_snapshot.dart`
- `lib/domain/trends/trend_snapshot.dart`
- `lib/domain/notification/notification_preference.dart`
- `lib/domain/notification/reminder_delivery_plan.dart`
- `lib/storage/isar/collections/notification_preference_record.dart`
- `lib/storage/isar/collections/ai_suggestion_cache_record.dart`
- `lib/storage/repositories/notification_preference_repository.dart`
- `lib/storage/repositories/ai_suggestion_cache_repository.dart`
- `lib/services/dashboard_service.dart`
- `lib/services/trend_analysis_service.dart`
- `lib/services/ai_suggestion_service.dart`
- `lib/services/local_notification_service.dart`
- `lib/services/reminder_delivery_service.dart`
- `lib/features/overview/widgets/health_score_hero.dart`
- `lib/features/overview/widgets/metric_cards.dart`
- `lib/features/overview/widgets/environment_snapshot_bar.dart`
- `lib/features/overview/widgets/ai_suggestion_bubble.dart`
- `lib/features/overview/widgets/metric_detail_sheets.dart`
- `lib/features/trends/pages/trend_analysis_page.dart`
- `lib/features/trends/providers/trend_analysis_provider.dart`
- `lib/features/trends/widgets/trend_tab_bar.dart`
- `lib/features/trends/widgets/trend_chart_panel.dart`
- `lib/features/trends/widgets/trend_insight_panel.dart`
- `lib/features/profile/providers/notification_preference_provider.dart`
- `lib/features/profile/widgets/do_not_disturb_section.dart`
- `test/domain/scoring/health_score_calculator_test.dart`
- `test/domain/notification/notification_preference_test.dart`
- `test/domain/notification/reminder_delivery_plan_test.dart`
- `test/storage/repositories/notification_preference_repository_test.dart`
- `test/storage/repositories/ai_suggestion_cache_repository_test.dart`
- `test/services/dashboard_service_test.dart`
- `test/services/trend_analysis_service_test.dart`
- `test/services/ai_suggestion_service_test.dart`
- `test/services/local_notification_service_test.dart`
- `test/services/reminder_delivery_service_test.dart`
- `test/features/overview/overview_dashboard_page_test.dart`
- `test/features/trends/trend_analysis_page_test.dart`
- `test/features/profile/do_not_disturb_section_test.dart`

### 修改文件

- `pubspec.yaml`
- `lib/storage/isar/app_isar.dart`
- `lib/domain/reminder/reminder_record.dart`
- `lib/storage/isar/collections/reminder_record_entity.dart`
- `lib/storage/repositories/reminder_repository.dart`
- `lib/features/overview/providers/overview_providers.dart`
- `lib/features/overview/pages/overview_page.dart`
- `lib/app/router.dart`
- `lib/features/profile/pages/profile_page.dart`
- `lib/services/data_collector.dart`
- `test/storage/isar/collection_mapping_test.dart`
- `test/storage/repositories/reminder_repository_test.dart`
- `test/features/overview/overview_page_test.dart`
- `test/features/profile/profile_page_test.dart`
- `test/features/app_shell_test.dart`

---

## Task 1：建立纯 Dart 领域模型与评分基础

**文件：**
- 新建：`lib/domain/scoring/health_score_calculator.dart`
- 新建：`lib/domain/dashboard/dashboard_snapshot.dart`
- 新建：`lib/domain/trends/trend_snapshot.dart`
- 新建：`lib/domain/notification/notification_preference.dart`
- 新建：`lib/domain/notification/reminder_delivery_plan.dart`
- 测试：`test/domain/scoring/health_score_calculator_test.dart`
- 测试：`test/domain/notification/notification_preference_test.dart`
- 测试：`test/domain/notification/reminder_delivery_plan_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/notification/reminder_delivery_plan.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';

void main() {
  ReminderRecord fakeReminder(String title) {
    return ReminderRecord(
      triggeredAt: DateTime(2026, 6, 16, 10, 0),
      type: ReminderType.sedentaryBreak,
      title: title,
      message: '$title message',
      reasonSummary: '$title reason',
      actionSuggestion: '$title action',
      response: ReminderResponse.pending,
    );
  }

  test('健康分按 40 40 20 权重计算并对各维度封顶', () {
    final score = calculateHealthScore(
      stepCount: 4800,
      sedentaryMinutes: 96,
      screenMinutes: 148,
    );

    expect(score.stepScore, 80);
    expect(score.sedentaryScore, 100);
    expect(score.screenScore, 82);
    expect(score.totalScore, 88);
  });

  test('跨午夜勿扰时段能正确命中前后半段时间', () {
    const preference = NotificationPreference(
      enabled: true,
      startHour: 22,
      startMinute: 30,
      endHour: 7,
      endMinute: 0,
    );

    expect(preference.isWithinWindow(DateTime(2026, 6, 16, 23, 45)), isTrue);
    expect(preference.isWithinWindow(DateTime(2026, 6, 17, 6, 45)), isTrue);
    expect(preference.isWithinWindow(DateTime(2026, 6, 17, 9, 0)), isFalse);
  });

  test('提醒投递计划能区分可发送与被拦截记录', () {
    final ready = ReminderDeliveryEntry.ready(fakeReminder('walk'));
    final blocked = ReminderDeliveryEntry.blockedByDnd(fakeReminder('screen'));

    final plan = ReminderDeliveryPlan(entries: <ReminderDeliveryEntry>[ready, blocked]);

    expect(plan.readyRecords.map((item) => item.title), <String>['walk']);
    expect(plan.blockedRecords.single.reason, DeliveryBlockReason.doNotDisturb);
  });
}
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/domain/scoring/health_score_calculator_test.dart test/domain/notification/notification_preference_test.dart test/domain/notification/reminder_delivery_plan_test.dart`

预期：FAIL，报错缺少 `calculateHealthScore`、`NotificationPreference`、`ReminderDeliveryPlan` 等定义。

- [ ] **步骤 3：写最小实现**

```dart
class HealthScoreBreakdown {
  const HealthScoreBreakdown({
    required this.stepScore,
    required this.sedentaryScore,
    required this.screenScore,
    required this.totalScore,
  });

  final int stepScore;
  final int sedentaryScore;
  final int screenScore;
  final int totalScore;
}

HealthScoreBreakdown calculateHealthScore({
  required int stepCount,
  required int sedentaryMinutes,
  required int screenMinutes,
}) {
  final stepScore = ((stepCount / 6000).clamp(0, 1) * 100).round();
  final sedentaryScore = _linearScore(actual: sedentaryMinutes, idealUpperBound: 120, zeroAt: 360);
  final screenScore = _linearScore(actual: screenMinutes, idealUpperBound: 180, zeroAt: 540);
  final totalScore = (stepScore * 0.4 + sedentaryScore * 0.4 + screenScore * 0.2).round();

  return HealthScoreBreakdown(
    stepScore: stepScore,
    sedentaryScore: sedentaryScore,
    screenScore: screenScore,
    totalScore: totalScore,
  );
}
```

```dart
class NotificationPreference {
  const NotificationPreference({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  bool isWithinWindow(DateTime dateTime) {
    if (!enabled) return false;
    final current = dateTime.hour * 60 + dateTime.minute;
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    if (start < end) {
      return current >= start && current < end;
    }
    return current >= start || current < end;
  }

  NotificationPreference copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return NotificationPreference(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  String get startLabel =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endLabel =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}
```

- [ ] **步骤 4：再次运行测试，确认通过**

运行：`flutter test test/domain/scoring/health_score_calculator_test.dart test/domain/notification/notification_preference_test.dart test/domain/notification/reminder_delivery_plan_test.dart`

预期：PASS，三组领域测试全部通过。

- [ ] **步骤 5：提交**

```bash
git add lib/domain/scoring/health_score_calculator.dart lib/domain/dashboard/dashboard_snapshot.dart lib/domain/trends/trend_snapshot.dart lib/domain/notification/notification_preference.dart lib/domain/notification/reminder_delivery_plan.dart test/domain/scoring/health_score_calculator_test.dart test/domain/notification/notification_preference_test.dart test/domain/notification/reminder_delivery_plan_test.dart
git commit -m "feat: add dashboard scoring and notification domain models"
```

## Task 2：补齐 Isar 持久化与提醒投递状态

**文件：**
- 新建：`lib/storage/isar/collections/notification_preference_record.dart`
- 新建：`lib/storage/isar/collections/ai_suggestion_cache_record.dart`
- 新建：`lib/storage/repositories/notification_preference_repository.dart`
- 新建：`lib/storage/repositories/ai_suggestion_cache_repository.dart`
- 修改：`lib/domain/reminder/reminder_record.dart`
- 修改：`lib/storage/isar/collections/reminder_record_entity.dart`
- 修改：`lib/storage/repositories/reminder_repository.dart`
- 修改：`lib/storage/isar/app_isar.dart`
- 测试：`test/storage/repositories/notification_preference_repository_test.dart`
- 测试：`test/storage/repositories/ai_suggestion_cache_repository_test.dart`
- 测试：`test/storage/repositories/reminder_repository_test.dart`
- 测试：`test/storage/isar/collection_mapping_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
test('勿扰设置仓储能写入并恢复时间窗口', () async {
  final dir = await Directory.systemTemp.createTemp('pref-repo-test');
  final isar = await Isar.open(
    <CollectionSchema>[NotificationPreferenceRecordSchema],
    directory: dir.path,
    name: 'pref_repo_test',
  );
  final repository = IsarNotificationPreferenceRepository(isar);

  await repository.save(
    const NotificationPreference(
      enabled: true,
      startHour: 22,
      startMinute: 30,
      endHour: 7,
      endMinute: 0,
    ),
  );

  final restored = await repository.read();
  expect(restored.enabled, isTrue);
  expect(restored.startHour, 22);
  expect(restored.endMinute, 0);
});

test('AI 建议缓存只会命中同一天的 dateKey', () async {
  final dir = await Directory.systemTemp.createTemp('ai-cache-test');
  final isar = await Isar.open(
    <CollectionSchema>[AiSuggestionCacheRecordSchema],
    directory: dir.path,
    name: 'ai_cache_repo_test',
  );
  final repository = IsarAiSuggestionCacheRepository(isar);

  await repository.save(
    date: DateTime(2026, 6, 16, 9, 0),
    text: '晚饭后散步 15 分钟会更稳。',
  );

  expect(await repository.readForDate(DateTime(2026, 6, 16, 21, 0)), '晚饭后散步 15 分钟会更稳。');
  expect(await repository.readForDate(DateTime(2026, 6, 17, 8, 0)), isNull);
});

test('提醒仓储能查询未投递记录并标记为已投递', () async {
  final repository = InMemoryReminderRepository(
    records: <ReminderRecord>[
      ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'activity',
          level: 'warning',
          summary: '起身活动一下',
          detail: '已经久坐一段时间',
          shouldRemind: true,
          reminderType: 'sedentaryBreak',
        ),
        now: DateTime(2026, 6, 16, 10, 0),
      ),
    ],
  );

  final pending = await repository.listUndeliveredSince(DateTime(2026, 6, 16, 0, 0));
  await repository.markDelivered(pending, deliveredAt: DateTime(2026, 6, 16, 10, 1));
  final afterDelivery = await repository.listUndeliveredSince(DateTime(2026, 6, 16, 0, 0));

  expect(pending, hasLength(1));
  expect(afterDelivery, isEmpty);
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/storage/repositories/notification_preference_repository_test.dart test/storage/repositories/ai_suggestion_cache_repository_test.dart test/storage/repositories/reminder_repository_test.dart test/storage/isar/collection_mapping_test.dart`

预期：FAIL，报错缺少仓储实现、Schema 注册或 `deliveredAt` 投递状态支持。

- [ ] **步骤 3：写最小实现**

```dart
@collection
class NotificationPreferenceRecord {
  Id id = 1;
  late bool enabled;
  late int startHour;
  late int startMinute;
  late int endHour;
  late int endMinute;

  static NotificationPreferenceRecord fromDomain(NotificationPreference preference) {
    return NotificationPreferenceRecord()
      ..enabled = preference.enabled
      ..startHour = preference.startHour
      ..startMinute = preference.startMinute
      ..endHour = preference.endHour
      ..endMinute = preference.endMinute;
  }

  NotificationPreference toDomain() {
    return NotificationPreference(
      enabled: enabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );
  }
}
```

```dart
class ReminderRecord {
  const ReminderRecord({
    required this.triggeredAt,
    required this.type,
    required this.title,
    required this.message,
    required this.reasonSummary,
    required this.actionSuggestion,
    required this.response,
    this.deliveredAt,
    this.reminderTypeKey,
    this.sourceDimension,
    this.sourceEventId,
  });

  final DateTime? deliveredAt;

  ReminderRecord copyWith({DateTime? deliveredAt}) {
    return ReminderRecord(
      triggeredAt: triggeredAt,
      type: type,
      title: title,
      message: message,
      reasonSummary: reasonSummary,
      actionSuggestion: actionSuggestion,
      response: response,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      reminderTypeKey: reminderTypeKey,
      sourceDimension: sourceDimension,
      sourceEventId: sourceEventId,
    );
  }
}
```

```dart
abstract class ReminderRepository {
  Future<void> saveAll(Iterable<ReminderRecord> records);
  Future<List<ReminderRecord>> listRecentDays(int days, {required DateTime referenceDate});
  Future<ReminderRecord?> getLatest();
  Future<List<ReminderRecord>> listUndeliveredSince(DateTime since);
  Future<void> markDelivered(Iterable<ReminderRecord> records, {required DateTime deliveredAt});
}
```

- [ ] **步骤 4：生成 Isar 代码**

运行：`dart run build_runner build --delete-conflicting-outputs`

预期：PASS，生成新的 `.g.dart` 文件。

- [ ] **步骤 5：再次运行测试，确认通过**

运行：`flutter test test/storage/repositories/notification_preference_repository_test.dart test/storage/repositories/ai_suggestion_cache_repository_test.dart test/storage/repositories/reminder_repository_test.dart test/storage/isar/collection_mapping_test.dart`

预期：PASS，持久化、映射与提醒投递状态测试全部通过。

- [ ] **步骤 6：提交**

```bash
git add lib/storage/isar/collections/notification_preference_record.dart lib/storage/isar/collections/notification_preference_record.g.dart lib/storage/isar/collections/ai_suggestion_cache_record.dart lib/storage/isar/collections/ai_suggestion_cache_record.g.dart lib/storage/repositories/notification_preference_repository.dart lib/storage/repositories/ai_suggestion_cache_repository.dart lib/domain/reminder/reminder_record.dart lib/storage/isar/collections/reminder_record_entity.dart lib/storage/repositories/reminder_repository.dart lib/storage/isar/app_isar.dart test/storage/repositories/notification_preference_repository_test.dart test/storage/repositories/ai_suggestion_cache_repository_test.dart test/storage/repositories/reminder_repository_test.dart test/storage/isar/collection_mapping_test.dart
git commit -m "feat: persist dashboard settings cache and delivery state"
```

## Task 3：实现首页与趋势页聚合服务

**文件：**
- 新建：`lib/services/dashboard_service.dart`
- 新建：`lib/services/trend_analysis_service.dart`
- 修改：`lib/features/overview/providers/overview_providers.dart`
- 测试：`test/services/dashboard_service_test.dart`
- 测试：`test/services/trend_analysis_service_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
test('首页聚合服务能生成分数、环境快照与 AI 建议字段', () async {
  final insight = fakeInsightSnapshot(
    stepCount: 4860,
    sedentaryMinutes: 96,
    screenMinutes: 148,
    currentLightLabel: '舒适',
    currentNoiseLabel: '正常',
  );
  final service = DashboardService(
    insightService: FakeHealthInsightService(insight),
    aiSuggestionService: FakeAiSuggestionService('晚饭后散步 15 分钟会更稳。'),
  );

  final snapshot = await service.build(referenceTime: DateTime(2026, 6, 16, 9));

  expect(snapshot.healthScore.totalScore, 88);
  expect(snapshot.stepCard.goalSteps, 6000);
  expect(snapshot.environmentSnapshot.lightLabel, '舒适');
  expect(snapshot.dailyAdviceBubble.text, '晚饭后散步 15 分钟会更稳。');
});

test('趋势聚合服务能输出 7 个点并默认返回步数趋势', () async {
  final service = TrendAnalysisService(
    metricsRepository: FakeMetricsRepository(sevenDayMetrics()),
    usageRepository: InMemoryUsageSummaryRepository(summaries: sevenDayUsage()),
    ambientLightRepository: FakeAmbientLightRepository(sevenDayLight()),
    noiseRepository: FakeNoiseRepository(sevenDayNoise()),
  );

  final snapshot = await service.build(referenceTime: DateTime(2026, 6, 16, 9));

  expect(snapshot.selectedTab, TrendTab.steps);
  expect(snapshot.points.length, 7);
  expect(snapshot.insightText, contains('6000'));
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/services/dashboard_service_test.dart test/services/trend_analysis_service_test.dart`

预期：FAIL，因为聚合服务和新的 provider 输出还不存在。

- [ ] **步骤 3：写最小实现**

```dart
class DashboardService {
  DashboardService({
    required HealthInsightService insightService,
    required AiSuggestionService aiSuggestionService,
  })  : _insightService = insightService,
        _aiSuggestionService = aiSuggestionService;

  final HealthInsightService _insightService;
  final AiSuggestionService _aiSuggestionService;

  Future<DashboardSnapshot> build({
    required DateTime referenceTime,
  }) async {
    final insight = await _insightService.buildSnapshot(
      window: QueryWindow.recentDay(referenceTime: referenceTime),
      referenceTime: referenceTime,
    );
    final score = calculateHealthScore(
      stepCount: insight.metrics.stepCount,
      sedentaryMinutes: insight.metrics.sedentaryMinutes,
      screenMinutes: insight.metrics.screenMinutes,
    );
    final advice = await _aiSuggestionService.buildDailyAdvice(
      referenceTime: referenceTime,
      input: insight.input,
      metrics: insight.metrics,
      verdicts: insight.verdicts,
      environmentOverview: insight.environmentOverview,
    );

    return DashboardSnapshot.fromInsight(
      insight: insight,
      score: score,
      advice: advice,
    );
  }
}
```

```dart
class TrendAnalysisService {
  TrendAnalysisService({
    required MetricsRepository metricsRepository,
    required UsageSummaryRepository usageRepository,
    required AmbientLightSampleRepository ambientLightRepository,
    required NoiseSampleRepository noiseRepository,
  })  : _metricsRepository = metricsRepository,
        _usageRepository = usageRepository,
        _ambientLightRepository = ambientLightRepository,
        _noiseRepository = noiseRepository;

  Future<TrendSnapshot> build({
    required DateTime referenceTime,
    TrendTab selectedTab = TrendTab.steps,
  }) async {
    final series = await _loadSevenDaySeries(referenceTime);
    return TrendSnapshot.fromSeries(
      selectedTab: selectedTab,
      series: series,
    );
  }
}
```

- [ ] **步骤 4：再次运行测试，确认通过**

运行：`flutter test test/services/dashboard_service_test.dart test/services/trend_analysis_service_test.dart`

预期：PASS，聚合后的首页快照和趋势快照测试通过。

- [ ] **步骤 5：提交**

```bash
git add lib/services/dashboard_service.dart lib/services/trend_analysis_service.dart lib/features/overview/providers/overview_providers.dart test/services/dashboard_service_test.dart test/services/trend_analysis_service_test.dart
git commit -m "feat: aggregate dashboard and trend snapshots"
```

## Task 4：接入真 LLM 建议服务与提醒投递服务

**文件：**
- 修改：`pubspec.yaml`
- 新建：`lib/services/ai_suggestion_service.dart`
- 新建：`lib/services/local_notification_service.dart`
- 新建：`lib/services/reminder_delivery_service.dart`
- 修改：`lib/services/data_collector.dart`
- 测试：`test/services/ai_suggestion_service_test.dart`
- 测试：`test/services/local_notification_service_test.dart`
- 测试：`test/services/reminder_delivery_service_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
test('AI 建议服务遇到同日缓存时不会再触发 Dio 请求', () async {
  final cache = InMemoryAiSuggestionCacheRepository(
    initial: <String, String>{'2026-06-16': '今天先把晚饭后的 15 分钟留给散步。'},
  );
  final dio = FakeDioClient.failure();
  final service = AiSuggestionService(
    cacheRepository: cache,
    dio: dio,
    apiKey: 'test-key',
    model: 'gpt-5.5',
    fallbackBuilder: (_, __, ___, ____) => '降级文案',
  );

  final result = await service.buildDailyAdvice(
    referenceTime: DateTime(2026, 6, 16, 9),
    input: RuleInput(
      window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 16, 9)),
      activitySamples: const <ActivitySample>[],
      locationSummaries: const <LocationSummary>[],
      noiseSamples: const <NoiseSample>[],
      ambientLightSamples: const <AmbientLightSample>[],
      usageSummaries: const <DigitalUsageSummary>[],
      dailyMetricsList: const <DailyMetrics>[],
      missingDimensions: const <String>[],
    ),
    metrics: const HealthInsightMetrics(
      stepCount: 4860,
      sedentaryMinutes: 96,
      screenMinutes: 148,
      outdoorMinutes: 18,
    ),
    verdicts: const <RuleVerdict>[],
    environmentOverview: null,
  );

  expect(result.text, '今天先把晚饭后的 15 分钟留给散步。');
});

test('提醒投递服务在勿扰期内拦截发送，在非勿扰期内放行', () async {
  final service = ReminderDeliveryService(
    notificationPreferenceRepository: FakeNotificationPreferenceRepository(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    ),
    notificationPermissionReader: () async => PermissionGrantStatus.granted,
  );

  final reminder = ReminderRecord.fromVerdict(
    verdict: const RuleVerdict(
      dimension: 'activity',
      level: 'warning',
      summary: '起身活动一下',
      detail: '已经久坐一段时间',
      shouldRemind: true,
      reminderType: 'sedentaryBreak',
    ),
    now: DateTime(2026, 6, 16, 23, 0),
  );

  final blocked = await service.buildPlan(
    records: <ReminderRecord>[reminder],
    referenceTime: DateTime(2026, 6, 16, 23, 0),
  );
  final ready = await service.buildPlan(
    records: <ReminderRecord>[reminder],
    referenceTime: DateTime(2026, 6, 16, 21, 0),
  );

  expect(blocked.entries.single.reason, DeliveryBlockReason.doNotDisturb);
  expect(ready.readyRecords, hasLength(1));
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/services/ai_suggestion_service_test.dart test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart`

预期：FAIL，因为 `dio` 还没接入，相关服务尚不存在。

- [ ] **步骤 3：写最小实现**

```yaml
dependencies:
  dio: ^5.7.0
```

```dart
class AiSuggestionService {
  AiSuggestionService({
    required AiSuggestionCacheRepository cacheRepository,
    required Dio dio,
    required String apiKey,
    required String model,
    required DailyAdviceFallbackBuilder fallbackBuilder,
  })  : _cacheRepository = cacheRepository,
        _dio = dio,
        _apiKey = apiKey,
        _model = model,
        _fallbackBuilder = fallbackBuilder;

  Future<DailyAdviceBubble> buildDailyAdvice({
    required DateTime referenceTime,
    required RuleInput input,
    required HealthInsightMetrics metrics,
    required List<RuleVerdict> verdicts,
    required EnvironmentOverview? environmentOverview,
  }) async {
    final cached = await _cacheRepository.readForDate(referenceTime);
    if (cached != null && cached.isNotEmpty) {
      return DailyAdviceBubble(text: cached, source: DailyAdviceSource.cache);
    }

    if (_apiKey.isEmpty) {
      return DailyAdviceBubble(
        text: _fallbackBuilder(input, metrics, verdicts, environmentOverview),
        source: DailyAdviceSource.fallback,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/responses',
        data: <String, dynamic>{
          'model': _model,
          'input': _buildPrompt(input, metrics, verdicts, environmentOverview),
        },
        options: Options(headers: <String, String>{
          'Authorization': 'Bearer $_apiKey',
        }),
      );
      final text = _extractOutputText(response.data);
      await _cacheRepository.save(date: referenceTime, text: text);
      return DailyAdviceBubble(text: text, source: DailyAdviceSource.llm);
    } catch (_) {
      return DailyAdviceBubble(
        text: _fallbackBuilder(input, metrics, verdicts, environmentOverview),
        source: DailyAdviceSource.fallback,
      );
    }
  }
}
```

```dart
Future<void> _deliverRuleReminders(DateTime referenceTime) async {
  final undelivered = await reminderRepository.listUndeliveredSince(
    DateTime(referenceTime.year, referenceTime.month, referenceTime.day),
  );
  final plan = await reminderDeliveryService.buildPlan(
    records: undelivered,
    referenceTime: referenceTime,
  );
  await localNotificationService.sendPlan(plan);
  await reminderRepository.markDelivered(
    plan.readyRecords,
    deliveredAt: referenceTime,
  );
}
```

- [ ] **步骤 4：再次运行测试，确认通过**

运行：`flutter test test/services/ai_suggestion_service_test.dart test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart`

预期：PASS，缓存命中、LLM 降级和勿扰拦截行为全部通过。

- [ ] **步骤 5：提交**

```bash
git add pubspec.yaml pubspec.lock lib/services/ai_suggestion_service.dart lib/services/local_notification_service.dart lib/services/reminder_delivery_service.dart lib/services/data_collector.dart test/services/ai_suggestion_service_test.dart test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart
git commit -m "feat: add ai advice and reminder delivery services"
```

## Task 5：重构首页为新版仪表盘 UI

**文件：**
- 修改：`lib/features/overview/providers/overview_providers.dart`
- 修改：`lib/features/overview/pages/overview_page.dart`
- 新建：`lib/features/overview/widgets/health_score_hero.dart`
- 新建：`lib/features/overview/widgets/metric_cards.dart`
- 新建：`lib/features/overview/widgets/environment_snapshot_bar.dart`
- 新建：`lib/features/overview/widgets/ai_suggestion_bubble.dart`
- 新建：`lib/features/overview/widgets/metric_detail_sheets.dart`
- 修改：`test/features/overview/overview_page_test.dart`
- 新建：`test/features/overview/overview_dashboard_page_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
testWidgets('首页展示综合健康分、三张卡片、环境快照和 AI 建议', (WidgetTester tester) async {
  final viewModel = OverviewDashboardViewModel(
    screenState: OverviewScreenState.ready,
    dashboard: fakeDashboardSnapshot(),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
      ],
      child: const MaterialApp(home: OverviewPage()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('综合健康分'), findsOneWidget);
  expect(find.text('步数'), findsOneWidget);
  expect(find.text('久坐'), findsOneWidget);
  expect(find.text('屏幕'), findsOneWidget);
  expect(find.textContaining('AI 建议'), findsOneWidget);
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/features/overview/overview_page_test.dart test/features/overview/overview_dashboard_page_test.dart`

预期：FAIL，因为当前首页还是旧版概览结构。

- [ ] **步骤 3：写最小实现**

```dart
class OverviewDashboardViewModel {
  const OverviewDashboardViewModel({
    required this.screenState,
    required this.dashboard,
    required this.permissionStatuses,
  });

  final OverviewScreenState screenState;
  final DashboardSnapshot dashboard;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
}

final overviewViewModelProvider =
    FutureProvider<OverviewDashboardViewModel>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final dashboard = await ref.watch(dashboardServiceProvider).build(
        referenceTime: DateTime.now(),
      );

  return OverviewDashboardViewModel(
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: dashboard.hasRealData,
      hasReminderHistory: dashboard.hasReminderHistory,
    ),
    dashboard: dashboard,
    permissionStatuses: permissionStatuses,
  );
});
```

```dart
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncViewModel = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: SafeArea(
        child: asyncViewModel.when(
          data: (viewModel) => _OverviewDashboardBody(viewModel: viewModel),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('加载首页失败')),
        ),
      ),
    );
  }
}
```

- [ ] **步骤 4：再次运行测试，确认通过**

运行：`flutter test test/features/overview/overview_page_test.dart test/features/overview/overview_dashboard_page_test.dart`

预期：PASS，首页仪表盘主结构渲染通过。

- [ ] **步骤 5：提交**

```bash
git add lib/features/overview/providers/overview_providers.dart lib/features/overview/pages/overview_page.dart lib/features/overview/widgets/health_score_hero.dart lib/features/overview/widgets/metric_cards.dart lib/features/overview/widgets/environment_snapshot_bar.dart lib/features/overview/widgets/ai_suggestion_bubble.dart lib/features/overview/widgets/metric_detail_sheets.dart test/features/overview/overview_page_test.dart test/features/overview/overview_dashboard_page_test.dart
git commit -m "feat: replace overview summary with dashboard ui"
```

## Task 6：接入趋势页、勿扰 UI 和路由

**文件：**
- 新建：`lib/features/trends/pages/trend_analysis_page.dart`
- 新建：`lib/features/trends/providers/trend_analysis_provider.dart`
- 新建：`lib/features/trends/widgets/trend_tab_bar.dart`
- 新建：`lib/features/trends/widgets/trend_chart_panel.dart`
- 新建：`lib/features/trends/widgets/trend_insight_panel.dart`
- 新建：`lib/features/profile/providers/notification_preference_provider.dart`
- 新建：`lib/features/profile/widgets/do_not_disturb_section.dart`
- 修改：`lib/features/profile/pages/profile_page.dart`
- 修改：`lib/app/router.dart`
- 测试：`test/features/trends/trend_analysis_page_test.dart`
- 测试：`test/features/profile/do_not_disturb_section_test.dart`
- 测试：`test/features/profile/profile_page_test.dart`
- 测试：`test/features/app_shell_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
testWidgets('趋势页默认展示步数并能切换到久坐', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        trendAnalysisViewModelProvider.overrideWith((Ref ref) async => fakeTrendSnapshot()),
      ],
      child: const MaterialApp(home: TrendAnalysisPage()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('近 7 天步数趋势'), findsOneWidget);
  await tester.tap(find.text('久坐'));
  await tester.pumpAndSettle();
  expect(find.text('近 7 天久坐趋势'), findsOneWidget);
});

testWidgets('我的页能展示勿扰设置区块', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: const MaterialApp(home: ProfilePage()),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('勿扰时段'), findsOneWidget);
  expect(find.text('启用勿扰'), findsOneWidget);
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/features/trends/trend_analysis_page_test.dart test/features/profile/do_not_disturb_section_test.dart test/features/profile/profile_page_test.dart test/features/app_shell_test.dart`

预期：FAIL，因为 `/trends` 还没注册，勿扰 UI 也尚未接入。

- [ ] **步骤 3：写最小实现**

```dart
final trendSelectedTabProvider = StateProvider<TrendTab>((Ref ref) => TrendTab.steps);

final trendAnalysisViewModelProvider = FutureProvider<TrendSnapshot>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  final selectedTab = ref.watch(trendSelectedTabProvider);
  return ref.watch(trendAnalysisServiceProvider).build(
        referenceTime: DateTime.now(),
        selectedTab: selectedTab,
      );
});
```

```dart
GoRoute(
  path: '/trends',
  builder: (_, __) => const TrendAnalysisPage(),
),
```

```dart
class DoNotDisturbSection extends ConsumerWidget {
  const DoNotDisturbSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPreference = ref.watch(notificationPreferenceProvider);
    return asyncPreference.when(
      data: (preference) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('勿扰时段'),
          SwitchListTile(
            title: const Text('启用勿扰'),
            value: preference.enabled,
            onChanged: (value) => ref
                .read(notificationPreferenceProvider.notifier)
                .save(preference.copyWith(enabled: value)),
          ),
          _TimeValueRow(label: '开始时间', value: preference.startLabel),
          _TimeValueRow(label: '结束时间', value: preference.endLabel),
          const Text('勿扰时段内不会主动推送提醒，但提醒记录仍会保留。'),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('加载勿扰设置失败'),
    );
  }
}
```

- [ ] **步骤 4：再次运行测试，确认通过**

运行：`flutter test test/features/trends/trend_analysis_page_test.dart test/features/profile/do_not_disturb_section_test.dart test/features/profile/profile_page_test.dart test/features/app_shell_test.dart`

预期：PASS，趋势页路由、Tab 切换、勿扰设置区块全部通过。

- [ ] **步骤 5：提交**

```bash
git add lib/features/trends/pages/trend_analysis_page.dart lib/features/trends/providers/trend_analysis_provider.dart lib/features/trends/widgets/trend_tab_bar.dart lib/features/trends/widgets/trend_chart_panel.dart lib/features/trends/widgets/trend_insight_panel.dart lib/features/profile/providers/notification_preference_provider.dart lib/features/profile/widgets/do_not_disturb_section.dart lib/features/profile/pages/profile_page.dart lib/app/router.dart test/features/trends/trend_analysis_page_test.dart test/features/profile/do_not_disturb_section_test.dart test/features/profile/profile_page_test.dart test/features/app_shell_test.dart
git commit -m "feat: add trends page and do not disturb ui"
```

## Task 7：补齐卡片浮层、提醒派发和回归验证

**文件：**
- 修改：`lib/features/overview/pages/overview_page.dart`
- 修改：`lib/features/overview/widgets/metric_detail_sheets.dart`
- 修改：`lib/services/data_collector.dart`
- 修改：`test/features/overview/overview_refresh_on_data_revision_test.dart`
- 修改：`test/features/overview/overview_refresh_preserves_content_test.dart`
- 修改：`test/services/data_collector_usage_sync_test.dart`

- [ ] **步骤 1：先写失败测试**

```dart
testWidgets('点击屏幕卡片会打开分时段使用分布浮层', (WidgetTester tester) async {
  final viewModel = OverviewDashboardViewModel(
    screenState: OverviewScreenState.ready,
    dashboard: fakeDashboardSnapshot(),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        overviewViewModelProvider.overrideWith((Ref ref) async => viewModel),
      ],
      child: const MaterialApp(home: OverviewPage()),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('屏幕'));
  await tester.pumpAndSettle();

  expect(find.text('分时段使用分布'), findsOneWidget);
});

test('DataCollector 在 refreshDerivedData 后会派发未投递提醒', () async {
  final deliveryService = FakeReminderDeliveryService();
  final reminderRepository = InMemoryReminderRepository(
    records: <ReminderRecord>[
      ReminderRecord.fromVerdict(
        verdict: const RuleVerdict(
          dimension: 'activity',
          level: 'warning',
          summary: '起身活动一下',
          detail: '已经久坐一段时间',
          shouldRemind: true,
          reminderType: 'sedentaryBreak',
        ),
        now: DateTime(2026, 6, 16, 10, 0),
      ),
    ],
  );
  final collector = buildCollectorForReminderDelivery(
    reminderRepository: reminderRepository,
    reminderDeliveryService: deliveryService,
    localNotificationService: FakeLocalNotificationService(),
  );

  await collector.refreshDerivedData(referenceTime: DateTime(2026, 6, 16, 10, 5));

  expect(deliveryService.buildPlanCallCount, 1);
});
```

- [ ] **步骤 2：运行测试，确认失败**

运行：`flutter test test/features/overview/overview_refresh_on_data_revision_test.dart test/features/overview/overview_refresh_preserves_content_test.dart test/services/data_collector_usage_sync_test.dart`

预期：FAIL，因为卡片浮层和提醒派发钩子还没完全接通。

- [ ] **步骤 3：写最小实现**

```dart
void _showScreenDetailSheet(BuildContext context, DashboardScreenCard card) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFDF8),
    isScrollControlled: true,
    builder: (_) => ScreenUsageDetailSheet(card: card),
  );
}
```

```dart
Future<void> refreshDerivedData({
  required DateTime referenceTime,
}) async {
  await _syncUsage(referenceTime);
  await _persistMetrics(referenceTime);
  await _persistRuleReminders(referenceTime);
  await _deliverRuleReminders(referenceTime);
  _revision.value++;
}
```

- [ ] **步骤 4：运行聚焦回归测试**

运行：`flutter test test/features/overview/overview_refresh_on_data_revision_test.dart test/features/overview/overview_refresh_preserves_content_test.dart test/services/data_collector_usage_sync_test.dart`

预期：PASS，浮层交互与提醒派发钩子都通过。

- [ ] **步骤 5：运行直接相关的完整验证**

运行：`flutter test test/domain/scoring/health_score_calculator_test.dart test/domain/notification/notification_preference_test.dart test/domain/notification/reminder_delivery_plan_test.dart test/storage/repositories/notification_preference_repository_test.dart test/storage/repositories/ai_suggestion_cache_repository_test.dart test/storage/repositories/reminder_repository_test.dart test/services/dashboard_service_test.dart test/services/trend_analysis_service_test.dart test/services/ai_suggestion_service_test.dart test/services/local_notification_service_test.dart test/services/reminder_delivery_service_test.dart test/features/overview/overview_page_test.dart test/features/overview/overview_dashboard_page_test.dart test/features/trends/trend_analysis_page_test.dart test/features/profile/profile_page_test.dart test/features/profile/do_not_disturb_section_test.dart`

预期：PASS，首页、趋势、AI 建议、提醒投递和勿扰设置相关链路全部通过。

- [ ] **步骤 6：提交**

```bash
git add lib/features/overview/pages/overview_page.dart lib/features/overview/widgets/metric_detail_sheets.dart lib/services/data_collector.dart test/features/overview/overview_refresh_on_data_revision_test.dart test/features/overview/overview_refresh_preserves_content_test.dart test/services/data_collector_usage_sync_test.dart
git commit -m "feat: wire dashboard detail sheets and reminder delivery"
```

---

## 自检

### Spec 覆盖检查

- 首页仪表盘结构：Task 3、Task 5、Task 7
- 健康分计算：Task 1、Task 3
- 步数 / 久坐 / 屏幕卡片与浮层：Task 5、Task 7
- 环境快照：Task 3、Task 5
- 真 LLM 每日建议：Task 2、Task 4、Task 5
- 趋势分析页：Task 3、Task 6
- 本地提醒通知：Task 2、Task 4、Task 7
- 勿扰设置：Task 1、Task 2、Task 6
- 提醒去重与投递状态：Task 2、Task 4、Task 7

### 占位词扫描

- 无 `TODO`
- 无 `TBD`
- 无 “implement later”
- 无 “similar to Task N”

### 类型一致性检查

- `DashboardSnapshot` 统一作为首页展示模型
- `TrendSnapshot` 统一作为趋势页展示模型
- `NotificationPreference` 在领域、存储、服务、UI 中命名一致
- `ReminderDeliveryPlan` 统一作为投递决策与通知执行之间的契约

---

## 执行交接

计划已保存到 `docs/superpowers/plans/2026-06-16-health-monitor-dashboard-trends-reminder-implementation-plan.md`。

你刚才已经选择了：

**1. Subagent-Driven（推荐）**

下一步我会按这个计划开始执行，并先按 `using-git-worktrees` 检查是否需要隔离工作区，再逐任务派发实现与评审子代理。  
