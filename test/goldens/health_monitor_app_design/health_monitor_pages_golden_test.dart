import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/theme.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/briefing/pages/briefing_page.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/profile/pages/profile_page.dart';
import 'package:health_monitor/features/profile/providers/notification_preference_provider.dart';
import 'package:health_monitor/features/reminders/pages/reminder_pages.dart';
import 'package:health_monitor/features/trends/pages/trend_analysis_page.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fontFile = File(r'C:\Windows\Fonts\msyh.ttc');
    final boldFontFile = File(r'C:\Windows\Fonts\msyhbd.ttc');
    if (fontFile.existsSync() && boldFontFile.existsSync()) {
      final regular = Uint8List.fromList(await fontFile.readAsBytes());
      final bold = Uint8List.fromList(await boldFontFile.readAsBytes());
      await (FontLoader('HealthGoldenChinese')
            ..addFont(Future<ByteData>.value(ByteData.sublistView(regular)))
            ..addFont(Future<ByteData>.value(ByteData.sublistView(bold))))
          .load();
    }
  });

  testWidgets('首页 ready Golden', (tester) async {
    await _pumpPage(
      tester,
      const OverviewPage(),
      <Override>[
        overviewScreenStateProvider.overrideWith(
          (ref) => const AsyncData(OverviewScreenState.ready),
        ),
        overviewReadyDataStateProvider.overrideWith((ref) => _readyData()),
      ],
    );
    await expectLater(
      find.byType(OverviewPage),
      matchesGoldenFile('overview_ready.png'),
    );
  });

  testWidgets('趋势 ready Golden', (tester) async {
    await _pumpPage(
      tester,
      const TrendAnalysisPage(),
      <Override>[
        trendAnalysisViewModelProvider.overrideWith((ref) async {
          final tab = ref.watch(trendSelectedTabProvider);
          final range = ref.watch(trendRangeForTabProvider(tab));
          return _trendSnapshot(tab, range);
        }),
      ],
    );
    await expectLater(
      find.byType(TrendAnalysisPage),
      matchesGoldenFile('trends_ready.png'),
    );
  });

  testWidgets('简报 ready Golden', (tester) async {
    await _pumpPage(
      tester,
      const BriefingPage(),
      <Override>[
        briefingReferenceTimeProvider.overrideWith(
          (ref) => () => DateTime(2026, 6, 22, 10),
        ),
        briefingViewModelProvider.overrideWith((ref) async {
          final range = ref.watch(briefingTimeRangeProvider);
          return _briefingViewModel(range);
        }),
      ],
    );
    await expectLater(
      find.byType(BriefingPage),
      matchesGoldenFile('briefing_ready.png'),
    );
  });

  testWidgets('提醒 ready Golden', (tester) async {
    await _pumpPage(
      tester,
      const ReminderListPage(),
      <Override>[
        reminderListProvider.overrideWith(
          (ref) async => <ReminderRecord>[
            _reminder(DateTime(2026, 6, 22, 14, 30), '起身活动一下'),
            _reminder(
              DateTime(2026, 6, 22, 21),
              '今晚少看一会儿屏幕',
              type: ReminderType.nightUsage,
            ),
          ],
        ),
        walkingScreenRiskNoticeProvider.overrideWith((ref) async => null),
      ],
    );
    await expectLater(
      find.byType(ReminderListPage),
      matchesGoldenFile('reminders_ready.png'),
    );
  });

  testWidgets('我的 ready Golden', (tester) async {
    await _pumpPage(
      tester,
      const ProfilePage(),
      <Override>[
        profileNowProvider.overrideWithValue(DateTime(2026, 6, 22, 10)),
        overviewViewModelProvider.overrideWith(
          (ref) async => OverviewDashboardViewModel(
            screenState: OverviewScreenState.ready,
            dashboard: _dashboard(),
            permissionStatuses: _grantedPermissions,
          ),
        ),
        notificationPreferenceProvider.overrideWith(
          () => _GoldenNotificationPreferenceNotifier(),
        ),
      ],
    );
    await expectLater(
      find.byType(ProfilePage),
      matchesGoldenFile('profile_ready.png'),
    );
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page,
  List<Override> overrides,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final theme = buildAppTheme(fontFamily: 'HealthGoldenChinese');
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'HealthGoldenChinese'),
          primaryTextTheme:
              theme.primaryTextTheme.apply(fontFamily: 'HealthGoldenChinese'),
        ),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: page,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

OverviewReadyData _readyData() => OverviewReadyData(
      dashboard: _dashboard(),
      permissionStatuses: _grantedPermissions,
      missingDimensions: const <String>[],
      reminders: const <ReminderRecord>[],
      preciseDetectionNotice: null,
    );

DashboardSnapshot _dashboard() => DashboardSnapshot(
      generatedAt: DateTime(2026, 6, 22, 16, 42),
      healthScore: HealthScoreBreakdown(
        stepScore: 82,
        sedentaryScore: 74,
        screenScore: 78,
        totalScore: 80,
      ),
      stepCard: DashboardStepCard(
        currentSteps: 4860,
        goalSteps: 6000,
        achievementPercent: 81,
      ),
      sedentaryCard: DashboardSedentaryCard(
        totalMinutes: 96,
        longestSingleMinutes: 42,
      ),
      screenCard: DashboardScreenCard(
        totalMinutes: 148,
        yesterdayDeltaMinutes: -18,
        changeDirection: DashboardChangeDirection.down,
      ),
      environmentSnapshot: DashboardEnvironmentSnapshot(
        lightLabel: '舒适',
        noiseLabel: '正常',
      ),
      dailyAdviceBubble: DailyAdviceBubble(
        text: '晚饭后散步 15 分钟会更稳。',
        source: DailyAdviceSource.llm,
      ),
      hasRealData: true,
      hasReminderHistory: true,
    );

TrendSnapshot _trendSnapshot(TrendTab tab, TrendRange range) => TrendSnapshot(
      generatedAt: DateTime(2026, 6, 22, 10),
      selectedTab: tab,
      range: range,
      title: '${range.label}活动趋势',
      unitLabel: '步',
      points: const <TrendPoint>[
        TrendPoint(label: '6/16', value: 4200),
        TrendPoint(label: '6/17', value: 5100),
        TrendPoint(label: '6/18', value: 6100),
        TrendPoint(label: '6/19', value: 5900),
        TrendPoint(label: '6/20', value: 6400),
        TrendPoint(label: '6/21', value: 5600),
        TrendPoint(label: '6/22', value: 4860),
      ],
      insightText: '工作日午后活动偏少，晚饭后短暂散步能让节奏更稳定。',
      defaultSelectedIndex: 6,
    );

BriefingViewModel _briefingViewModel(BriefingTimeRange range) =>
    BriefingViewModel(
      selectedRange: range,
      windowLabel: range == BriefingTimeRange.recent7Days ? '最近 7 天' : '今日',
      screenState: OverviewScreenState.ready,
      briefSnapshot: const DailyBriefSnapshot(
        headline: '整体节奏平稳',
        supportingDetail: '上午活动较好，下午出现一次连续久坐，晚间屏幕使用仍在舒适范围内。',
        metrics: <DailyBriefMetric>[
          DailyBriefMetric(label: '活动', value: '4860', unit: '步'),
          DailyBriefMetric(label: '久坐', value: '96', unit: '分钟'),
          DailyBriefMetric(label: '屏幕使用', value: '148', unit: '分钟'),
        ],
        suggestions: <String>['晚饭后散步 15 分钟，给久坐后的身体一次温和切换。'],
      ),
      permissionStatuses: _grantedPermissions,
      hasRealData: true,
      isLoading: false,
    );

ReminderRecord _reminder(
  DateTime time,
  String title, {
  ReminderType type = ReminderType.sedentaryBreak,
}) =>
    ReminderRecord(
      triggeredAt: time,
      type: type,
      title: title,
      message: '身体没有催你，只是在提醒你换个姿势。',
      reasonSummary: '连续静坐时间超过当前建议阈值。',
      actionSuggestion: '起身走动两三分钟即可。',
      response: ReminderResponse.pending,
    );

const Map<PermissionType, PermissionGrantStatus> _grantedPermissions =
    <PermissionType, PermissionGrantStatus>{
  PermissionType.motion: PermissionGrantStatus.granted,
  PermissionType.location: PermissionGrantStatus.granted,
  PermissionType.microphone: PermissionGrantStatus.granted,
  PermissionType.notification: PermissionGrantStatus.granted,
  PermissionType.usageAccess: PermissionGrantStatus.granted,
  PermissionType.backgroundCapture: PermissionGrantStatus.granted,
};

class _GoldenNotificationPreferenceNotifier
    extends NotificationPreferenceNotifier {
  @override
  Future<NotificationPreference> build() async {
    return const NotificationPreference(
      enabled: true,
      startHour: 22,
      startMinute: 30,
      endHour: 7,
      endMinute: 0,
    );
  }

  @override
  Future<void> save(NotificationPreference preference) async {
    state = AsyncData(preference);
  }
}
