# AGENTS.md

## 项目语境

- 本项目默认使用中文语境。
- 产品文档、技术文档、实现计划、注释说明、提交说明优先使用中文。
- 涉及 Flutter、Dart、Android、iOS、系统 API、第三方库名称时，可以保留必要英文术语，但解释和结论应使用中文。
- 新增或修改代码中的注释统一使用中文。
- 注释优先解释复杂逻辑、边界条件、设计原因与降级策略，避免“变量赋值”“调用函数”这类无意义注释。

## 产品目标

- 本项目是一个基于手机内置传感器的健康监测 App。
- 首版目标是用被动感知生成可解释、低打扰的健康洞察。
- 首版重点覆盖：活动识别、姿势风险、数字生活习惯、环境噪音、每日简报、规则提醒。
- 首版不做医学诊断，不保存原始音频，不依赖额外硬件。

## 技术路线

- 客户端主框架：Flutter
- 开发语言：Dart
- 状态管理：Riverpod
- 路由：GoRouter
- 本地存储：Isar
- 网络层：Dio
- 基础能力插件优先：`permission_handler`、`geolocator`、`sensors_plus`
- 平台桥接：`MethodChannel` / `EventChannel`

## 当前仓库状态

截至 2026-06-09，仓库当前已完成的真实基线包括：

- Flutter 最小应用壳、基础主题与 GoRouter 最小路由
- 阶段 0 平台能力矩阵正式版
- 阶段 0 权限与降级矩阵文档、权限说明领域模型
- 阶段 1 真实数据依赖恢复：Isar、logger、permission_handler、geolocator、sensors_plus
- 阶段 1 正式领域模型：活动、姿势、位置、环境噪音、数字生活、每日指标
- 阶段 1 Isar collection 落库边界与映射测试
- 阶段 1 真实采集调试页与真实状态读取链路
- 阶段 2 Android 后台采集正式实现的原生系统边界与单测验证
- 阶段 2 iPhone 后台刷新策略、宿主状态模型与桥接骨架

当前仍在推进中的重点包括：

- Android 后台采集正式实现的原生验证收口
- iPhone 后台采集正式实现与系统级验证
- 规则引擎输入层与多维规则输出
- 提醒记录链路
- 正式页面接入真实状态

## 架构原则

- Flutter 负责产品层、页面层、共享业务逻辑、规则引擎、简报生成、本地数据聚合。
- Android / iOS 原生层负责高权限能力、后台任务、平台差异能力和必要的传感器接入补强。
- 不将架构建立在“所有能力都能由现成 Flutter 插件完全稳定解决”的假设上。
- 平台差异必须在 `platform` / `services` 层消化，不直接暴露给页面层。

## 实现边界

- 页面层不得直接消费原始传感器数据。
- 规则引擎尽量保持纯 Dart，可单独测试。
- 业务模型优先放在 `lib/domain/`。
- 平台适配与桥接优先放在 `lib/platform/`，原生实现按能力拆分在 `android/` 与 `ios/`。
- 页面按 feature 拆分，不要把所有逻辑堆进单文件。
- Isar collection 负责落库结构，领域模型负责业务语义，不要把页面语义直接塞进存储层。
- 数字生活能力必须同时考虑 Android 全量能力与 iPhone 替代指标，不能只围绕 Android 建模。

## 隐私原则

- 默认本地优先处理原始感知数据。
- 不保存原始音频。
- 不上传可回放原始传感器历史。
- 权限申请必须配套中文说明，明确告诉用户“为什么要开、不开会失去什么能力”。
- 用户拒绝非核心权限后，应用应允许降级运行。

## 开发顺序

- 以 `docs/superpowers/plans/2026-06-07-health-monitor-mvp-implementation-plan.md` 的新顺序为准，优先推进“能力链路”，不回退到“先页面后能力”。
- 阶段 0 已完成后，优先推进阶段 1 与阶段 2：真实数据、正式领域模型、本地存储、调试页、后台采集。
- 阶段 1 和阶段 2 未完成前，不要把重心切回静态页面扩展。
- 规则、聚合、提醒等共享业务逻辑优先形成可测试闭环，再接 UI 消费。
- 若实现计划与最新技术选型文档冲突，以最新 Flutter 技术选型文档为准。

## 当前基线文档

- 产品设计：`docs/superpowers/specs/2026-06-07-health-monitor-design.md`
- 技术选型：`docs/superpowers/specs/2026-06-07-health-monitor-technical-selection.md`
- 实现计划：`docs/superpowers/plans/2026-06-07-health-monitor-mvp-implementation-plan.md`
- Flutter 设计落地：`docs/superpowers/specs/2026-06-09-health-monitor-flutter-design-implementation.md`
- 平台能力矩阵：`docs/research/2026-06-07-platform-capability-checklist.md`
- 权限与降级矩阵：`docs/research/2026-06-09-permission-and-degrade-matrix.md`

## 提交与变更要求

- 每次改动优先保持范围小、边界清楚。
- 若执行实现计划，应按任务粒度推进并保留验证证据。
- 每完成一个“阶段”后必须进行一次提交，提交说明优先使用中文，并明确阶段编号与完成范围。
- 阶段未完成时，可以按任务粒度保留本地改动，但不要把多个已完成阶段混在一次提交里。
- 提交前至少运行与本次改动直接相关的测试；若声明阶段完成，还应补充全量验证证据。
- 未经确认，不要擅自改回 React Native、Expo 或其他旧技术路线。
