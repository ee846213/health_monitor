# AGENTS.md

## 项目语境

- 本项目默认使用中文语境。
- 产品文档、技术文档、实现计划、注释说明、提交说明优先使用中文。
- 若涉及 Flutter、Dart、Android、iOS、系统 API、第三方库名称，可保留必要英文术语，但解释与结论应使用中文。

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
- 基础能力插件优先：permission_handler、geolocator、sensors_plus
- 平台桥接：MethodChannel / EventChannel

## 架构原则

- Flutter 负责产品层、页面层、共享业务逻辑、规则引擎、简报生成、本地数据聚合。
- Android / iOS 原生层负责高权限能力、后台任务、平台差异能力和必要的传感器接入补强。
- 不将架构建立在“所有能力都能由现成 Flutter 插件完全稳定解决”的假设上。
- 平台差异必须在 platform / services 层消化，不直接暴露给页面层。

## 实现边界

- 页面层不得直接消费原始传感器数据。
- 规则引擎尽量保持纯 Dart，可单独测试。
- 业务模型优先放在 `lib/domain/`。
- 平台适配与桥接优先放在 `lib/platform/`，原生实现按能力拆分在 `android/` 与 `ios/`。
- 页面按 feature 拆分，不要把所有逻辑堆进单文件。

## 隐私原则

- 默认本地优先处理原始感知数据。
- 不保存原始音频。
- 不上传可回放原始传感器历史。
- 权限申请必须配套中文说明，明确告诉用户“为什么要开、不开会失去什么能力”。
- 用户拒绝非核心权限后，应用应允许降级运行。

## 开发顺序

- 先验证平台能力，再推进正式实现。
- 先搭 Flutter 产品壳和共享模型，再接感知能力。
- 先做规则闭环，再做高级感知与后台任务。
- 若实现计划与最新技术选型文档冲突，以最新 Flutter 技术选型文档为准。

## 当前基线文档

- 产品设计：`docs/superpowers/specs/2026-06-07-health-monitor-design.md`
- 技术选型：`docs/superpowers/specs/2026-06-07-health-monitor-technical-selection.md`
- 实现计划：`docs/superpowers/plans/2026-06-07-health-monitor-mvp-implementation-plan.md`

## 提交与变更要求

- 每次改动优先保持范围小、边界清楚。
- 若执行实现计划，应按任务粒度推进并保留验证证据。
- 未经确认，不要擅自改回 React Native、Expo 或其他旧技术路线。
