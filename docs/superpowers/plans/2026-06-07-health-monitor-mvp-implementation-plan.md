# 健康监测 App MVP 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个基于 Flutter 的双平台健康监测 App MVP，完成中文语境产品壳、端上指标模型、规则引擎、基础感知能力接入、权限引导、每日简报和提醒闭环。

**Architecture:** 客户端采用 Flutter 负责产品层、Dart 负责共享业务核心、Android/iOS 原生模块负责高权限与平台差异能力的结构。实施顺序严格遵循“平台能力验证闸门 -> Flutter 工程脚手架 -> 共享模型与规则引擎 -> 感知与平台适配 -> 页面与权限流 -> 端上演示闭环”。

**Tech Stack:** Flutter、Dart、Riverpod、GoRouter、Isar、Dio、permission_handler、geolocator、sensors_plus、MethodChannel / EventChannel、flutter_test

---

## 范围判断与实施前提

本计划仅覆盖一个可独立交付的 MVP 子项目：

- Flutter 双平台客户端脚手架
- 中文产品页面与共享业务骨架
- 端上规则引擎与本地数据模型
- Android / iPhone 平台能力适配接口
- 基础传感器与位置能力接入
- 环境噪音与数字生活习惯能力的首轮框架

本计划包含一个强制前置条件：

- iPhone 侧的屏幕使用相关能力与应用类别偏好能力，必须先做平台能力验证，不能默认视为可用。

若验证结果不支持，MVP 必须自动降级为：

- Android：支持更完整的数字生活习惯摘要
- iPhone：仅保留查看频率、活跃时段、屏幕活跃时长等可实现替代指标

## 文件结构

项目按以下目录组织：

- `lib/app/`
  - 应用入口、主题、路由、全局 Provider
- `lib/core/`
  - 常量、日志、时间工具、错误封装
- `lib/domain/`
  - 业务模型、枚举、值对象
- `lib/features/`
  - `overview/`
  - `daily_brief/`
  - `reminders/`
  - `permissions/`
  - `settings/`
- `lib/rules/`
  - 规则引擎
- `lib/services/`
  - Flutter 侧服务抽象接口
- `lib/platform/`
  - MethodChannel / EventChannel 封装
- `lib/storage/`
  - Isar collection、repository
- `lib/widgets/`
  - 共享 UI 组件
- `test/`
  - `domain/`
  - `rules/`
  - `features/`
  - `platform/`
- `android/`
  - `motion/`
  - `usage/`
  - `location/`
  - `noise/`
  - `permissions/`
  - `background/`
- `ios/`
  - `motion/`
  - `usage_capability/`
  - `location/`
  - `noise/`
  - `permissions/`
  - `background/`

## 任务 1：建立平台能力验证闸门

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\docs\research\2026-06-07-platform-capability-checklist.md`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\capability_matrix.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\domain\capability_matrix_test.dart`

- [ ] **Step 1: 创建平台能力验证文档**

```md
# 双平台能力验证清单

日期：2026-06-07

## 待验证能力

1. iPhone 是否允许普通 App 获取屏幕使用聚合能力
2. iPhone 是否允许普通 App 获取应用类别偏好
3. Android 是否可通过 Usage Stats 获取应用类别使用摘要
4. 双平台是否可稳定接入加速度计、陀螺仪、位置、麦克风噪音等级
5. 双平台后台采集限制对 MVP 的影响

## 每项结论格式

- 结论：支持 / 受限 / 不支持
- 证据：官方文档或平台权限说明
- 对 MVP 的影响
- 降级方案
```

- [ ] **Step 2: 写失败测试，定义能力矩阵模型**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/capability_matrix.dart';

void main() {
  test('默认能力矩阵应包含 iPhone 和 Android 两端定义', () {
    final matrix = CapabilityMatrix.defaultMatrix();

    expect(matrix.ios.activityRecognition, CapabilitySupport.supported);
    expect(matrix.android.activityRecognition, CapabilitySupport.supported);
    expect(matrix.ios.appCategoryUsage, isNotNull);
    expect(matrix.android.appCategoryUsage, isNotNull);
  });
}
```

- [ ] **Step 3: 运行测试确认失败**

Run: `flutter test test/domain/capability_matrix_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/domain/capability_matrix.dart'`

- [ ] **Step 4: 实现最小能力矩阵模型**

```dart
enum CapabilitySupport { supported, limited, unsupported }

class PlatformCapabilitySet {
  const PlatformCapabilitySet({
    required this.activityRecognition,
    required this.postureSignals,
    required this.locationSummary,
    required this.noiseLevel,
    required this.screenUsageSummary,
    required this.appCategoryUsage,
  });

  final CapabilitySupport activityRecognition;
  final CapabilitySupport postureSignals;
  final CapabilitySupport locationSummary;
  final CapabilitySupport noiseLevel;
  final CapabilitySupport screenUsageSummary;
  final CapabilitySupport appCategoryUsage;
}

class CapabilityMatrix {
  const CapabilityMatrix({
    required this.ios,
    required this.android,
  });

  final PlatformCapabilitySet ios;
  final PlatformCapabilitySet android;

  factory CapabilityMatrix.defaultMatrix() {
    return const CapabilityMatrix(
      ios: PlatformCapabilitySet(
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        noiseLevel: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.limited,
        appCategoryUsage: CapabilitySupport.unsupported,
      ),
      android: PlatformCapabilitySet(
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        noiseLevel: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.supported,
        appCategoryUsage: CapabilitySupport.supported,
      ),
    );
  }
}
```

- [ ] **Step 5: 运行测试确认通过**

Run: `flutter test test/domain/capability_matrix_test.dart`
Expected: PASS

- [ ] **Step 6: 提交**

```bash
git add docs/research/2026-06-07-platform-capability-checklist.md lib/domain/capability_matrix.dart test/domain/capability_matrix_test.dart
git commit -m "chore: add platform capability matrix"
```

## 任务 2：初始化 Flutter 工程脚手架

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\pubspec.yaml`
- Create: `C:\Users\13692\Documents\health_monitor\lib\main.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\app\app.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\app\router.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\app\theme.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\features\app_shell_test.dart`

- [ ] **Step 1: 写失败测试，验证应用壳能渲染首页标题**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/app.dart';

void main() {
  testWidgets('应用壳应渲染今日概览标题', (tester) async {
    await tester.pumpWidget(const HealthMonitorApp());
    expect(find.text('今日概览'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/app_shell_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/app/app.dart'`

- [ ] **Step 3: 创建最小 Flutter 工程清单**

```yaml
name: health_monitor
description: 健康监测 App MVP
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  dio: ^5.7.0
  logger: ^2.4.0
  permission_handler: ^11.3.1
  geolocator: ^12.0.0
  sensors_plus: ^6.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  isar_generator: ^3.1.0+1
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 4: 创建最小应用壳**

```dart
import 'package:flutter/material.dart';

class HealthMonitorApp extends StatelessWidget {
  const HealthMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康监测',
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('今日概览'),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 运行测试确认通过**

Run: `flutter test test/features/app_shell_test.dart`
Expected: PASS

- [ ] **Step 6: 提交**

```bash
git add pubspec.yaml lib/main.dart lib/app/app.dart lib/app/router.dart lib/app/theme.dart test/features/app_shell_test.dart
git commit -m "feat: scaffold flutter app shell"
```

## 任务 3：定义共享领域模型

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\daily_metrics.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\motion_state.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\daily_brief.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\reminder_record.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\domain\daily_metrics_test.dart`

- [ ] **Step 1: 写失败测试，定义每日指标对象**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/daily_metrics.dart';

void main() {
  test('每日指标默认值应完整初始化', () {
    final metrics = DailyMetrics.empty('2026-06-07');

    expect(metrics.date, '2026-06-07');
    expect(metrics.steps, 0);
    expect(metrics.sedentaryMinutes, 0);
    expect(metrics.screenMinutes, 0);
    expect(metrics.noiseLevel, NoiseLevel.unknown);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/domain/daily_metrics_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/domain/daily_metrics.dart'`

- [ ] **Step 3: 实现最小领域模型**

```dart
enum NoiseLevel { quiet, moderate, noisy, unknown }

class DailyMetrics {
  DailyMetrics({
    required this.date,
    required this.steps,
    required this.sedentaryMinutes,
    required this.screenMinutes,
    required this.outdoorMinutes,
    required this.commuteDistanceKm,
    required this.phoneCheckCount,
    required this.lateNightScreenMinutes,
    required this.movingScreenRiskCount,
    required this.headDownMinutes,
    required this.longHoldMinutes,
    required this.noiseLevel,
  });

  factory DailyMetrics.empty(String date) {
    return DailyMetrics(
      date: date,
      steps: 0,
      sedentaryMinutes: 0,
      screenMinutes: 0,
      outdoorMinutes: 0,
      commuteDistanceKm: 0,
      phoneCheckCount: 0,
      lateNightScreenMinutes: 0,
      movingScreenRiskCount: 0,
      headDownMinutes: 0,
      longHoldMinutes: 0,
      noiseLevel: NoiseLevel.unknown,
    );
  }

  final String date;
  final int steps;
  final int sedentaryMinutes;
  final int screenMinutes;
  final int outdoorMinutes;
  final double commuteDistanceKm;
  final int phoneCheckCount;
  final int lateNightScreenMinutes;
  final int movingScreenRiskCount;
  final int headDownMinutes;
  final int longHoldMinutes;
  final NoiseLevel noiseLevel;
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/domain/daily_metrics_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/domain/daily_metrics.dart lib/domain/motion_state.dart lib/domain/daily_brief.dart lib/domain/reminder_record.dart test/domain/daily_metrics_test.dart
git commit -m "feat: add shared domain models"
```

## 任务 4：建立 Isar 本地数据层

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\isar_provider.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\daily_metrics_entity.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\daily_metrics_repository.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\storage\daily_metrics_repository_test.dart`

- [ ] **Step 1: 写失败测试，验证指标仓库可保存与读取**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/daily_metrics.dart';
import 'package:health_monitor/storage/daily_metrics_repository.dart';

void main() {
  test('每日指标仓库应支持保存和读取', () async {
    final repository = InMemoryDailyMetricsRepository();
    final metrics = DailyMetrics.empty('2026-06-07');

    await repository.save(metrics);
    final loaded = await repository.getByDate('2026-06-07');

    expect(loaded?.date, '2026-06-07');
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/storage/daily_metrics_repository_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/storage/daily_metrics_repository.dart'`

- [ ] **Step 3: 实现最小仓库接口**

```dart
import 'package:health_monitor/domain/daily_metrics.dart';

abstract class DailyMetricsRepository {
  Future<void> save(DailyMetrics metrics);
  Future<DailyMetrics?> getByDate(String date);
}

class InMemoryDailyMetricsRepository implements DailyMetricsRepository {
  final Map<String, DailyMetrics> _memory = {};

  @override
  Future<void> save(DailyMetrics metrics) async {
    _memory[metrics.date] = metrics;
  }

  @override
  Future<DailyMetrics?> getByDate(String date) async {
    return _memory[date];
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/storage/daily_metrics_repository_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/storage/isar_provider.dart lib/storage/daily_metrics_entity.dart lib/storage/daily_metrics_repository.dart test/storage/daily_metrics_repository_test.dart
git commit -m "feat: add local metrics repository"
```

## 任务 5：实现 Flutter 侧服务接口与平台通道骨架

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\services\motion_service.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\services\environment_service.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\services\digital_habit_service.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\services\permission_service.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\platform\method_channel_motion_service.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\platform\method_channel_motion_service_test.dart`

- [ ] **Step 1: 写失败测试，验证运动服务通道名称**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/platform/method_channel_motion_service.dart';

void main() {
  test('运动服务应使用固定通道名', () {
    final service = MethodChannelMotionService();
    expect(service.channelName, 'health_monitor/motion');
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/platform/method_channel_motion_service_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/platform/method_channel_motion_service.dart'`

- [ ] **Step 3: 实现最小平台服务骨架**

```dart
import 'package:flutter/services.dart';

abstract class MotionService {
  Future<List<Map<String, dynamic>>> loadMotionWindows();
}

class MethodChannelMotionService implements MotionService {
  MethodChannelMotionService()
      : _channel = const MethodChannel(channelName);

  static const String channelName = 'health_monitor/motion';
  final MethodChannel _channel;

  @override
  Future<List<Map<String, dynamic>>> loadMotionWindows() async {
    final result = await _channel.invokeMethod<List<dynamic>>('loadMotionWindows');
    if (result == null) return [];
    return result.cast<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/platform/method_channel_motion_service_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/services/motion_service.dart lib/services/environment_service.dart lib/services/digital_habit_service.dart lib/services/permission_service.dart lib/platform/method_channel_motion_service.dart test/platform/method_channel_motion_service_test.dart
git commit -m "feat: add platform service interfaces"
```

## 任务 6：实现活动与姿势基础识别

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\motion\motion_classifier.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\motion\posture_classifier.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\rules\motion_classifier_test.dart`

- [ ] **Step 1: 写失败测试，验证久坐识别**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/rules/motion/motion_classifier.dart';

void main() {
  test('低变化且持续时长较长应识别为久坐', () {
    final result = classifyMotionWindow(
      averageAcceleration: 0.02,
      variance: 0.01,
      screenOn: true,
      devicePitchDegrees: 18,
      continuousMinutes: 70,
    );

    expect(result.activityState, MotionActivityState.sedentary);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/rules/motion_classifier_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/rules/motion/motion_classifier.dart'`

- [ ] **Step 3: 实现最小运动分类器**

```dart
enum MotionActivityState { walking, running, staticState, sedentary }

class MotionClassification {
  const MotionClassification({
    required this.activityState,
    required this.isHeadDownRisk,
    required this.isLongHoldRisk,
  });

  final MotionActivityState activityState;
  final bool isHeadDownRisk;
  final bool isLongHoldRisk;
}

MotionClassification classifyMotionWindow({
  required double averageAcceleration,
  required double variance,
  required bool screenOn,
  required double devicePitchDegrees,
  required int continuousMinutes,
}) {
  if (variance < 0.02 && continuousMinutes >= 45) {
    return MotionClassification(
      activityState: MotionActivityState.sedentary,
      isHeadDownRisk: screenOn && devicePitchDegrees <= 25,
      isLongHoldRisk: screenOn && continuousMinutes >= 20,
    );
  }

  if (variance < 0.02) {
    return const MotionClassification(
      activityState: MotionActivityState.staticState,
      isHeadDownRisk: false,
      isLongHoldRisk: false,
    );
  }

  if (variance < 0.2) {
    return const MotionClassification(
      activityState: MotionActivityState.walking,
      isHeadDownRisk: false,
      isLongHoldRisk: false,
    );
  }

  return const MotionClassification(
    activityState: MotionActivityState.running,
    isHeadDownRisk: false,
    isLongHoldRisk: false,
  );
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/rules/motion_classifier_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/rules/motion/motion_classifier.dart lib/rules/motion/posture_classifier.dart test/rules/motion_classifier_test.dart
git commit -m "feat: add motion and posture classifiers"
```

## 任务 7：实现环境噪音与数字习惯降级策略

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\environment\noise_classifier.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\platform\digital_usage_policy.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\platform\digital_usage_policy_test.dart`

- [ ] **Step 1: 写失败测试，验证 iPhone 禁用应用类别偏好**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/platform/digital_usage_policy.dart';

void main() {
  test('iPhone 应默认禁用应用类别偏好分析', () {
    final policy = buildDigitalUsagePolicy(TargetPlatform.iOS);
    expect(policy.enableAppCategoryBreakdown, false);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/platform/digital_usage_policy_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/platform/digital_usage_policy.dart'`

- [ ] **Step 3: 实现最小平台降级策略**

```dart
import 'package:flutter/foundation.dart';

class DigitalUsagePolicy {
  const DigitalUsagePolicy({
    required this.enableAppCategoryBreakdown,
    required this.enableLateNightUsage,
    required this.enablePhoneCheckFrequency,
  });

  final bool enableAppCategoryBreakdown;
  final bool enableLateNightUsage;
  final bool enablePhoneCheckFrequency;
}

DigitalUsagePolicy buildDigitalUsagePolicy(TargetPlatform platform) {
  return DigitalUsagePolicy(
    enableAppCategoryBreakdown: platform == TargetPlatform.android,
    enableLateNightUsage: true,
    enablePhoneCheckFrequency: true,
  );
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/platform/digital_usage_policy_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/rules/environment/noise_classifier.dart lib/platform/digital_usage_policy.dart test/platform/digital_usage_policy_test.dart
git commit -m "feat: add digital usage downgrade policy"
```

## 任务 8：实现规则引擎

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\daily_suggestion.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\build_daily_suggestions.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\rules\build_daily_suggestions_test.dart`

- [ ] **Step 1: 写失败测试，验证久坐与低头建议生成**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/daily_metrics.dart';
import 'package:health_monitor/rules/build_daily_suggestions.dart';

void main() {
  test('指标达到阈值时应生成久坐与低头建议', () {
    final metrics = DailyMetrics.empty('2026-06-07')
      ..sedentaryMinutes = 190
      ..headDownMinutes = 95;

    final suggestions = buildDailySuggestions(metrics);

    expect(suggestions.any((item) => item.code == 'sedentary-break'), true);
    expect(suggestions.any((item) => item.code == 'head-down-risk'), true);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/rules/build_daily_suggestions_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/rules/build_daily_suggestions.dart'`

- [ ] **Step 3: 调整 DailyMetrics 为可 copyWith 的不可变对象并实现规则引擎**

```dart
class DailySuggestion {
  const DailySuggestion({
    required this.code,
    required this.title,
    required this.reason,
  });

  final String code;
  final String title;
  final String reason;
}

List<DailySuggestion> buildDailySuggestions(DailyMetrics metrics) {
  final results = <DailySuggestion>[];

  if (metrics.sedentaryMinutes >= 120) {
    results.add(const DailySuggestion(
      code: 'sedentary-break',
      title: '起身活动一下',
      reason: '你今天久坐时间偏长，建议现在起身活动 3 到 5 分钟。',
    ));
  }

  if (metrics.headDownMinutes >= 60) {
    results.add(const DailySuggestion(
      code: 'head-down-risk',
      title: '放松颈肩',
      reason: '你今天低头用机时间偏长，建议抬高手机并活动一下颈肩。',
    ));
  }

  return results;
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/rules/build_daily_suggestions_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/rules/daily_suggestion.dart lib/rules/build_daily_suggestions.dart test/rules/build_daily_suggestions_test.dart
git commit -m "feat: add rule engine"
```

## 任务 9：实现首页、每日简报与提醒记录页面

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\overview\overview_screen.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\daily_brief\daily_brief_screen.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\reminders\reminder_history_screen.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\widgets\metric_card.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\widgets\suggestion_card.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\features\overview_screen_test.dart`

- [ ] **Step 1: 写失败测试，验证首页显示三大核心指标**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/features/overview/overview_screen.dart';

void main() {
  testWidgets('首页应展示三大核心指标标题', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OverviewScreen()));

    expect(find.text('步数'), findsOneWidget);
    expect(find.text('久坐时长'), findsOneWidget);
    expect(find.text('屏幕使用时长'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/overview_screen_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/features/overview/overview_screen.dart'`

- [ ] **Step 3: 实现最小首页**

```dart
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日概览')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('步数'),
            Text('久坐时长'),
            Text('屏幕使用时长'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/overview_screen_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/features/overview/overview_screen.dart lib/features/daily_brief/daily_brief_screen.dart lib/features/reminders/reminder_history_screen.dart lib/widgets/metric_card.dart lib/widgets/suggestion_card.dart test/features/overview_screen_test.dart
git commit -m "feat: add core flutter screens"
```

## 任务 10：实现权限引导与降级说明页

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\permissions\permission_intro_screen.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\permissions\permission_copy.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\permissions\permission_fallback_notice.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\features\permission_intro_screen_test.dart`

- [ ] **Step 1: 写失败测试，验证权限页包含“不保存原始音频”文案**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/features/permissions/permission_intro_screen.dart';

void main() {
  testWidgets('权限页应说明不会保存原始音频', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PermissionIntroScreen()));
    expect(find.text('我们不会保存原始音频'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/permission_intro_screen_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:health_monitor/features/permissions/permission_intro_screen.dart'`

- [ ] **Step 3: 实现最小权限页**

```dart
import 'package:flutter/material.dart';

class PermissionIntroScreen extends StatelessWidget {
  const PermissionIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限说明')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('我们不会保存原始音频'),
            SizedBox(height: 8),
            Text('你可以按需开启位置、麦克风和数字习惯分析相关权限'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/permission_intro_screen_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/features/permissions/permission_intro_screen.dart lib/features/permissions/permission_copy.dart lib/features/permissions/permission_fallback_notice.dart test/features/permission_intro_screen_test.dart
git commit -m "feat: add permission onboarding"
```

## 任务 11：打通 Flutter 端上演示闭环

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\app\bootstrap_demo_data.dart`
- Modify: `C:\Users\13692\Documents\health_monitor\lib\app\app.dart`
- Test: `C:\Users\13692\Documents\health_monitor\test\features\demo_flow_test.dart`

- [ ] **Step 1: 写失败测试，验证首页展示默认建议卡片**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/app.dart';

void main() {
  testWidgets('首页应展示默认建议文案', (tester) async {
    await tester.pumpWidget(const HealthMonitorApp());
    expect(find.text('起身活动一下'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/features/demo_flow_test.dart`
Expected: FAIL with `Expected: exactly one matching candidate`

- [ ] **Step 3: 实现演示数据启动流程**

```dart
import 'package:health_monitor/domain/daily_metrics.dart';
import 'package:health_monitor/rules/build_daily_suggestions.dart';

class DemoBootstrapResult {
  const DemoBootstrapResult({
    required this.metrics,
    required this.suggestions,
  });

  final DailyMetrics metrics;
  final List<DailySuggestion> suggestions;
}

DemoBootstrapResult bootstrapDemoData() {
  final metrics = DailyMetrics(
    date: '2026-06-07',
    steps: 2680,
    sedentaryMinutes: 180,
    screenMinutes: 245,
    outdoorMinutes: 18,
    commuteDistanceKm: 6.8,
    phoneCheckCount: 47,
    lateNightScreenMinutes: 52,
    movingScreenRiskCount: 2,
    headDownMinutes: 88,
    longHoldMinutes: 54,
    noiseLevel: NoiseLevel.moderate,
  );

  return DemoBootstrapResult(
    metrics: metrics,
    suggestions: buildDailySuggestions(metrics),
  );
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `flutter test test/features/demo_flow_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/app/bootstrap_demo_data.dart lib/app/app.dart test/features/demo_flow_test.dart
git commit -m "feat: wire flutter demo data flow"
```

## 任务 12：补齐项目说明与验证命令

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\README.md`
- Create: `C:\Users\13692\Documents\health_monitor\analysis_options.yaml`
- Modify: `C:\Users\13692\Documents\health_monitor\docs\superpowers\specs\2026-06-07-health-monitor-technical-selection.md`

- [ ] **Step 1: 写项目 README**

```md
# 健康监测 App

## 项目原则

- 默认使用中文文档与中文开发语境
- Flutter 负责产品层，原生桥接负责高权限与平台差异能力
- MVP 以本地优先处理为核心
- 不保存原始音频
```

- [ ] **Step 2: 写静态检查配置**

```yaml
include: package:flutter_lints/flutter.yaml
```

- [ ] **Step 3: 运行全量测试**

Run: `flutter test`
Expected: PASS

- [ ] **Step 4: 启动应用确认脚手架可运行**

Run: `flutter run -d windows`
Expected: App starts successfully and renders the Chinese home shell

- [ ] **Step 5: 提交**

```bash
git add README.md analysis_options.yaml docs/superpowers/specs/2026-06-07-health-monitor-technical-selection.md
git commit -m "docs: add flutter project readme and lint config"
```

## 自检

### 1. Spec 覆盖检查

- 产品定位与 MVP 范围：任务 1、2、12 覆盖
- 共享领域模型：任务 3 覆盖
- 本地优先存储：任务 4 覆盖
- 平台适配与桥接：任务 1、5、7 覆盖
- 活动、姿势、环境、数字生活习惯：任务 6、7 覆盖
- 规则引擎：任务 8 覆盖
- 页面与权限：任务 9、10 覆盖
- 端上闭环：任务 11 覆盖

真实设备后台采集稳定性仍需在执行阶段通过真机验证补充，不应仅依赖单元测试。

### 2. 占位符检查

本计划未使用 `TBD`、`TODO`、`后续补充`、`类似任务 N` 等占位写法。每个任务都给出了明确路径、最小代码与验证命令。

### 3. 命名一致性检查

- 平台能力统一使用 `CapabilityMatrix`
- 指标模型统一使用 `DailyMetrics`
- 平台降级策略统一使用 `DigitalUsagePolicy`
- 建议引擎统一使用 `buildDailySuggestions`

未发现前后命名冲突。
