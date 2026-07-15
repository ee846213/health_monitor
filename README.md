（ios端暂不可用）

# Health Monitor 

健康监测 App 是一款基于手机内置传感器的被动感知型健康洞察应用。项目目标是在不依赖额外硬件、尽量减少用户手动记录的前提下，将活动、姿势、数字生活、位置环境和噪音等信号转化为可解释、低打扰的日常健康建议。

> 本项目不提供医学诊断，不保存原始音频，不上传可回放的原始传感器历史。首版重点是本地优先、可解释、可降级的真实数据闭环。

## 产品定位

首版 MVP 面向日常健康管理场景，重点验证：

- 仅依赖手机本身的被动数据，也能生成持续有价值的健康洞察。
- 用户看到的是自然语言总结、每日简报和低打扰提醒，而不是原始传感器看板。
- Android 与 iPhone 都有正式可用路径，但允许底层能力不对称。

核心闭环：

```text
被动采集 -> 本地存储 -> 日指标聚合 -> 规则判断 -> 页面展示 -> 提醒触发
```

## 当前能力范围

仓库当前已包含以下主要模块：

- Flutter 应用壳、主题系统、GoRouter 路由和四栏主导航。
- 首页、趋势、每日简报、提醒记录、“我的”、调试与状态页面。
- 活动、姿势、位置、环境噪音、数字生活、每日指标、提醒、后台采集等领域模型。
- Riverpod 状态编排、规则输入层、提醒规则、环境规则和健康洞察服务。
- Isar 本地存储 collection、repository 与查询窗口。
- Android / iOS 后台采集状态模型与平台桥接骨架。
- 权限与降级矩阵、平台能力矩阵、设计稿和 Flutter UI/UX 落地规范。
- 单元测试、页面测试、平台边界测试和 Golden 视觉回归测试。

仍在推进中的重点包括：

- 双平台真机级后台采集稳定性验证。
- 真实规则输入到提醒送达的完整链路收口。
- Android Usage Access 数字生活增强能力。
- iPhone 受限能力下的替代指标与系统级验证。

## 技术栈

- 客户端框架：Flutter / Dart
- 状态管理：Riverpod
- 路由：GoRouter
- 本地存储：Isar
- 网络层：Dio
- 权限：permission_handler
- 传感器与位置：sensors_plus、geolocator
- 噪音等级：noise_meter
- 后台任务与通知：workmanager、flutter_local_notifications
- 平台桥接：MethodChannel / EventChannel

项目要求 Dart SDK：

```text
>=3.4.0 <4.0.0
```

## 目录结构

```text
lib/
  app/          应用壳、路由、主题、共享 UI 组件
  core/         日志等基础设施
  domain/       领域模型、能力矩阵、权限语义、健康指标
  features/     首页、趋势、简报、提醒、我的、诊断等页面模块
  platform/     Android / iOS 平台能力协调与桥接边界
  rules/        规则引擎、规则输入和规则结论
  services/     采集、聚合、洞察、提醒、权限等应用服务
  storage/      Isar collection、repository 和本地数据库入口

test/
  app/          应用壳、主题与组件测试
  domain/       纯领域模型测试
  features/     页面与交互测试
  services/     服务与采集链路测试
  storage/      Isar 映射与 repository 测试
  platform/     平台协调器测试
  goldens/      UI Golden 视觉回归测试

docs/
  research/     平台能力、权限和降级策略
  designs/      Pencil 设计稿与视觉参考
  superpowers/  产品设计、技术选型、实现计划和 UI 落地规范
```

## 本地开发

### 1. 准备环境

安装 Flutter，并确认本机 Flutter / Dart 版本满足 `pubspec.yaml` 中的 SDK 约束。

```bash
flutter doctor
flutter pub get
```

### 2. 生成 Isar 代码

当修改 `storage/isar/collections` 下的 Isar collection 时，运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用

```bash
flutter run
```

如需在指定设备运行：

```bash
flutter devices
flutter run -d <device-id>
```

## 测试

运行全部测试：

```bash
flutter test
```

运行首页趋势与 Golden 相关测试示例：

```bash
flutter test test/features/overview/daily_rhythm_timeline_test.dart test/features/overview/overview_metric_trend_provider_test.dart test/goldens/health_monitor_app_design/health_monitor_pages_golden_test.dart
```

更新 Golden 图时请确认视觉变更符合 `docs/designs/` 和 Flutter UI/UX 落地规范，再运行：

```bash
flutter test --update-goldens test/goldens/health_monitor_app_design/health_monitor_pages_golden_test.dart
```

## 平台策略

项目采用“Flutter 产品层 + 原生桥接补强平台能力”的路线：

- Flutter 负责页面、导航、状态编排、领域模型、规则引擎、简报生成和本地聚合。
- Android / iOS 原生层负责高权限能力、后台任务、系统 API 差异和必要的传感器接入补强。
- 页面层只消费统一后的能力语义，不直接处理平台权限枚举或原始传感器结构。

平台角色：

- Android：完整能力端，承载更完整的数字生活分析与后台连续性。
- iPhone：受限正式端，在系统限制内提供替代指标和可解释降级。

## 隐私与安全边界

- 默认本地优先处理原始感知数据。
- 不保存、不上传、不回放原始音频。
- 不上传可重建的原始传感器流或精细轨迹历史。
- 权限申请必须说明“为什么要开、不开会失去什么能力”。
- 用户拒绝非核心权限后，应用应继续降级运行。
- 页面和提醒文案不得输出医学诊断结论。

## 关键文档

- 产品设计：`docs/superpowers/specs/2026-06-07-health-monitor-design.md`
- 技术选型：`docs/superpowers/specs/2026-06-07-health-monitor-technical-selection.md`
- 实现计划：`docs/superpowers/plans/2026-06-07-health-monitor-mvp-implementation-plan.md`
- Flutter UI/UX 落地规范：`docs/superpowers/specs/2026-06-09-health-monitor-flutter-design-implementation.md`
- 平台能力矩阵：`docs/research/2026-06-07-platform-capability-checklist.md`
- 权限与降级矩阵：`docs/research/2026-06-09-permission-and-degrade-matrix.md`

## 开发约定

- 默认使用中文编写产品文档、技术文档、实现计划、注释说明和提交说明。
- 页面层不得直接消费原始传感器数据。
- 业务模型优先放在 `lib/domain/`。
- 平台适配与桥接优先放在 `lib/platform/`。
- 规则引擎尽量保持纯 Dart，并优先覆盖单元测试。
- 权限、后台采集和数字生活能力必须同时考虑 Android 完整能力与 iPhone 受限正式路径。
