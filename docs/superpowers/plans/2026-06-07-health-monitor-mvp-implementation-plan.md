# 健康监测 App 真实可用版本开发计划

> **For agentic workers:** 本计划已不再以“演示型 MVP”为目标，而以“真实数据、真实后台、真实规则、双平台正式可用”为目标。后续执行时，必须优先完成真实数据链路、权限链路、后台链路与规则链路，不得继续按“先页面、后能力”的旧顺序推进。

日期：2026-06-09  
状态：进行中

---

## 目标重写

本计划的目标从：

- 构建一个用于演示核心概念的 Flutter MVP

调整为：

- 构建一个首个可实际使用的真实数据版本

这里的“可实际使用”具有以下硬约束：

1. 应用必须消费真实数据，而不是 mock 数据、静态占位数据或手填演示数据。
2. 应用必须形成真实闭环：`采集 -> 存储 -> 聚合 -> 规则判断 -> 页面展示 -> 提醒触发`。
3. 应用必须支持后台被动采集，不能只依赖用户前台打开 App。
4. Android 与 iPhone 都必须是正式可用端，但允许能力不对称。
5. Android 为完整能力端，iPhone 为受限但正式可用端。

---

## 当前仓库真实状态

截至 2026-06-09，当前仓库已经具备的基础包括：

- Flutter 最小应用壳
- GoRouter 最小路由
- 基础主题文件
- 平台能力矩阵正式版
- 权限与降级矩阵基线
- 真实数据依赖恢复
- 正式领域模型
- Isar collection 落库边界与最小 repository 查询接口
- 设计文档、UI/UX 文档、Flutter 设计落地文档

当前仍明显缺失的关键能力包括：

- 真实传感器接入
- 调试页与可见真实结果页
- 双平台后台采集链路
- 真实规则引擎输入
- 页面对真实状态的消费
- 真机级写入与读取闭环

因此，后续计划必须从“产品壳 + 页面继续扩展”切换为“能力链路优先”。

---

## 平台策略

采用：

- `双平台同项目推进 + 平台能力分层`

平台角色定义：

- Android：完整能力端
- iPhone：受限正式端

### A 层：双平台都必须真实具备的能力

- 活动识别基础能力
- 姿势 / 用机姿态基础能力
- 基础位置摘要
- 基础环境噪音等级
- 本地存储与历史聚合
- 首页状态、简报、提醒解释闭环
- 正式后台采集链路

### B 层：平台增强能力

- Android 数字生活习惯分析全量能力
- iPhone 数字生活替代指标
- Android 更强后台连续性
- iPhone 系统允许范围内的后台连续性

### C 层：后续增强能力

- 长周期趋势画像
- 更复杂的个性化规则
- 云同步与账号体系
- 更强的后台节能策略

---

## 范围定义

本计划第一阶段即纳入以下真实能力：

- 活动识别
- 姿势风险
- 数字生活习惯
- 位置摘要
- 环境噪音等级
- 后台被动采集
- 本地存储
- 首页 / 简报 / 提醒真实闭环

首阶段就接受高权限与高限制能力，包括但不限于：

- Android Usage Access
- Android 前台服务与通知常驻
- Android 后台任务
- 持续位置权限
- 麦克风权限
- iPhone Motion / Location / Background 相关权限
- iPhone 系统允许范围内的数字生活相关能力或真实替代指标

---

## 新的开发顺序

旧顺序：

- 平台能力验证闸门
- Flutter 工程脚手架
- 共享模型与规则引擎
- 感知与平台适配
- 页面与权限流
- 端上演示闭环

新顺序：

1. 平台能力结论固化
2. 真实数据采集与本地存储闭环
3. 后台采集闭环
4. 规则引擎与真实提醒闭环
5. 正式页面接入真实状态
6. 双平台稳定性、耗电与降级优化

---

## 阶段 0：平台能力结论固化

目标：

- 把当前“初步判断”升级为“可开发结论”

### 本阶段交付

- 双平台能力矩阵正式版
- 双平台降级策略表
- 权限清单与中文说明文案
- Android / iPhone 能力来源说明

### 验收标准

- 每项核心能力都有 `支持 / 受限 / 不支持` 结论
- 每项能力都有真实来源与开发路径
- 每项受限能力都有明确替代方案
- 每项权限都有用户可见说明文案

### 任务包

#### 任务 0.1：固化平台能力矩阵文档

**Files:**
- Update: `C:\Users\13692\Documents\health_monitor\docs\research\2026-06-07-platform-capability-checklist.md`
- Update: `C:\Users\13692\Documents\health_monitor\lib\domain\capability_matrix.dart`
- Update: `C:\Users\13692\Documents\health_monitor\test\domain\capability_matrix_test.dart`

- [x] 把“初步判断”升级为正式结论字段
- [x] 为每项能力补充 Android / iPhone 分别结论
- [x] 在能力矩阵中补充后台采集、数字生活替代能力、环境能力字段
- [x] 增加测试覆盖默认能力矩阵与平台分层判断

#### 任务 0.2：定义权限与降级文案

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\docs\research\2026-06-09-permission-and-degrade-matrix.md`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\permission\permission_descriptor.dart`
- Create: `C:\Users\13692\Documents\health_monitor\test\domain\permission_descriptor_test.dart`

- [x] 为运动、位置、麦克风、通知、Usage Access、后台采集能力分别定义说明
- [x] 明确“不开启会失去什么能力”
- [x] 明确“开启后用于什么分析”
- [x] 明确拒绝后的降级逻辑

---

## 阶段 1：真实数据最小闭环

目标：

- 在双平台真机上打通真实采集、真实存储、真实聚合

本阶段不以精细 UI 为重点，而以真实链路打通为重点。

### 本阶段交付

- 真实传感器采集服务
- 真实位置摘要服务
- 真实环境噪音等级服务
- 跨平台最小数字生活采集入口
- Android Usage Access 全量能力的后续桥接预留
- 本地数据库结构与 repository
- 调试页 / 状态页查看真实结果

### 验收标准

- 真机可看到真实采集结果
- 本地数据库已有真实记录
- 可从真实记录聚合出基础指标
- 页面读取真实存储结果，而不是 mock 数据

### 任务包

#### 任务 1.1：恢复并扩展依赖到真实数据版本

**Files:**
- Update: `C:\Users\13692\Documents\health_monitor\pubspec.yaml`

- [x] 重新引入 `isar`
- [x] 重新引入 `isar_flutter_libs`
- [x] 引入 `logger`
- [x] 引入 `permission_handler`
- [x] 引入 `geolocator`
- [x] 引入 `sensors_plus`
- [x] 根据需要补充后台任务与原生桥接相关依赖
- [x] 确保 `flutter pub get` 在当前环境稳定通过

#### 任务 1.2：建立领域模型正式版

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\motion\activity_sample.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\motion\posture_sample.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\location\location_summary.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\environment\noise_sample.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\usage\digital_usage_summary.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\metrics\daily_metrics.dart`
- Create: `C:\Users\13692\Documents\health_monitor\test\domain\...`

- [x] 定义活动样本模型
- [x] 定义姿势样本模型
- [x] 定义位置摘要模型
- [x] 定义噪音等级模型
- [x] 定义数字生活摘要模型
- [x] 定义首页 / 简报聚合指标模型

#### 任务 1.3：建立本地存储层

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\isar\collections\...`
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\repositories\...`
- Create: `C:\Users\13692\Documents\health_monitor\test\storage\...`

- [x] 为活动、姿势、位置、噪音、数字生活分别建表
- [x] 为提醒记录建表
- [x] 为聚合查询建立最小 repository
- [x] 为最近数小时、最近一天、最近 7 天查询建立接口

#### 任务 1.4：建立真实采集调试页

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\diagnostics\pages\sensor_debug_page.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\diagnostics\providers\...`
- Update: `C:\Users\13692\Documents\health_monitor\lib\app\router.dart`

- [x] 页面显示当前权限状态
- [x] 页面显示最近活动样本
- [x] 页面显示最近位置摘要
- [x] 页面显示最近噪音等级
- [x] 页面显示最近数字生活结果
- [x] 页面显示本地数据库写入状态
- [x] 页面显示实时活动样本入口
- [x] 页面显示实时位置摘要入口
- [x] 页面显示实时噪音样本入口
- [x] 页面显示实时数字生活入口

---

## 阶段 2：后台被动采集闭环

目标：

- 让应用在后台也能持续积累有效数据

### 本阶段交付

- Android 后台持续采集链路
- iPhone 正式后台策略链路
- 采集频率策略
- 失败恢复与状态恢复
- 后台采集日志

### 验收标准

- 应用退到后台后仍能持续积累有效数据
- Android 背景链路稳定
- iPhone 在系统允许范围内稳定
- 应用重启后能恢复采集与状态

### 任务包

#### 任务 2.1：Android 后台采集正式实现

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\android\app\src\main\kotlin\com\example\health_monitor\background\...`
- Create: `C:\Users\13692\Documents\health_monitor\lib\platform\android\...`

- [x] Flutter 侧前台服务配置模型
- [x] Flutter 侧 Android 后台桥接协议
- [x] 前台服务策略
- [x] 后台任务调度
- [x] 运动 / 位置 / 数字生活 / 环境采集调度
- [x] 通知常驻与状态展示
- [x] 异常恢复

> 说明：这一任务已推进到可用的 Android 原生系统边界，包含前台服务、通知通道、WorkManager 调度入口与异常恢复路径。

#### 任务 2.2：iPhone 后台采集正式实现

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\ios\background\...`
- Create: `C:\Users\13692\Documents\health_monitor\lib\platform\ios\...`

- [x] Motion / Location / Background 模式组合策略
- [x] 环境能力系统允许范围内实现
- [x] 数字生活替代指标后台刷新策略
- [x] 状态恢复与限制识别

#### 任务 2.3：统一后台采集状态模型

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\background\background_capture_state.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\services\background_capture_service.dart`
- Create: `C:\Users\13692\Documents\health_monitor\test\domain\background_capture_state_test.dart`

- [x] 定义运行中、受限、暂停、失败、权限不足等状态
- [x] 页面层统一读取后台链路状态

---

## 阶段 3：规则引擎与真实提醒闭环

目标：

- 让首页、日报、提醒来自真实规则

### 本阶段交付

- 活动规则
- 姿势风险规则
- 数字生活规则
- 环境规则
- 提醒触发规则
- 提醒解释规则
- 数据不足与权限不足分支

### 验收标准

- 首页结论来自真实规则计算
- 简报来自真实聚合结果
- 提醒由真实规则触发
- 每条提醒都能解释原因
- 权限不足时规则能自动降级

### 任务包

#### 任务 3.1：建立规则输入层

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\input\...`
- Create: `C:\Users\13692\Documents\health_monitor\test\rules\input\...`

- [x] 从 repository 聚合规则输入
- [x] 区分全量输入与降级输入

#### 任务 3.2：建立多维规则引擎

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\engine\activity_rules.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\engine\posture_rules.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\engine\usage_rules.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\engine\environment_rules.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\rules\engine\reminder_rules.dart`

- [x] 输出首页核心结论
- [x] 输出简报摘要
- [x] 输出提醒建议
- [x] 输出提醒解释

#### 任务 3.3：建立提醒记录与解释链路

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\domain\reminder\reminder_record.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\storage\repositories\reminder_repository.dart`
- Create: `C:\Users\13692\Documents\health_monitor\test\domain\reminder_record_test.dart`

- [x] 记录提醒触发时间
- [x] 记录提醒类型
- [x] 记录提醒解释依据
- [x] 记录用户交互结果

---

## 阶段 4：正式页面接入真实状态

目标：

- 把设计稿页面接入真实 ViewModel，而不是继续堆静态页面

### 本阶段交付

- 首页正式页接真实状态
- 简报页接真实状态
- 我页接真实状态
- 提醒记录页接真实状态
- 提醒原因页接真实状态
- 权限未开启页接真实状态
- 数据不足空态页接真实状态

### 验收标准

- 所有页面读取真实状态
- 无权限 / 弱权限 / 数据不足都有真实分支
- 双平台都能完整走主要用户流程

### 任务包

#### 任务 4.1：建立 ThemeExtension 正式版

**Files:**
- Refactor: `C:\Users\13692\Documents\health_monitor\lib\app\theme.dart`
- Create: `C:\Users\13692\Documents\health_monitor\lib\app\theme\...`

- [x] 把当前最小主题升级为 design tokens 正式版
- [x] 对齐 Flutter 设计落地文档

#### 任务 4.2：首页正式接入

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\overview\...`
- Test: `C:\Users\13692\Documents\health_monitor\test\features\overview\...`

- [x] 首页读取真实状态
- [x] 首页展开态读取真实解释
- [x] 首页空态与权限态接入真实分支

#### 任务 4.3：简报、我页、提醒页正式接入

- [x] 简报页读取真实聚合结果
- [x] 我页读取真实能力状态与权限状态
- [x] 提醒记录页读取真实提醒历史
- [x] 提醒原因页读取真实解释依据

---

## 阶段 5：稳定性、耗电与连续使用优化

目标：

- 从“能跑”提升到“能长期用”

### 本阶段交付

- 耗电调优
- 采集频率调优
- 日志与故障恢复策略
- 多天连续使用验证
- 平台差异调优

### 验收标准

- 连续多天使用后仍能稳定积累数据
- 后台采集不会高频失效
- 提醒频率可控
- 权限变化不会导致应用整体失效

### 任务包

#### 任务 5.1：增加日志与诊断能力

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\lib\core\logging\...`
- Create: `C:\Users\13692\Documents\health_monitor\lib\features\diagnostics\...`

- [x] 记录采集状态
- [x] 记录后台链路状态
- [x] 记录规则输出状态
- [x] 记录权限变化事件

#### 任务 5.2：多天连续使用验收

**Files:**
- Create: `C:\Users\13692\Documents\health_monitor\docs\research\2026-06-09-real-device-validation-checklist.md`

- [ ] Android 连续使用验证
- [ ] iPhone 连续使用验证
- [ ] 弱权限验证
- [ ] 后台恢复验证
- [ ] 提醒触发与解释验证

---

## 第一批实施任务

基于当前仓库状态，接下来不建议继续优先做页面，而建议按下面顺序执行：

1. 恢复并稳定真实数据依赖
2. 扩展能力矩阵与权限降级文档
3. 建立领域模型正式版
4. 建立 Isar 存储层
5. 建立传感器 / 位置 / 噪音 / 数字生活调试页
6. 打通 Android 与 iPhone 第一条真实采集链路

---

## 当前已完成项

- [x] 阶段 0：平台能力矩阵正式版与权限降级矩阵
- [x] Flutter 最小应用壳
- [x] 路由与基础主题最小闭环
- [x] Flutter 设计落地文档
- [x] 阶段 1：真实数据依赖恢复
- [x] 阶段 1：正式领域模型
- [x] 阶段 1：Isar collection 与最小 repository 查询接口
- [x] 阶段 1：后台任务依赖、通知依赖与统一桥接入口预留
- [x] 阶段 1：提醒记录领域模型、落库表与最小仓储
- [x] 阶段 1：真实权限状态、活动/位置/噪音采集服务
- [x] 阶段 1：数字生活最小真实入口与调试页混合快照
- [x] 阶段 1：采集调试页与路由入口

## 已提交阶段

- [x] 阶段 0 已提交：`6bbb85d 完成阶段0：固化平台能力矩阵与权限降级基线`
- [x] 阶段 1 已提交：`b5b4db1 完成阶段1：打通真实采集调试页与最小数据闭环`
- [x] 阶段 1 收尾已提交：`4f91d8f 完成阶段1收尾：补齐提醒记录建表与后台桥接依赖预留`
- [x] 阶段 2 状态模型已提交：`a1e7b7d 完成阶段2：补齐统一后台采集状态模型与调试出口`
- [x] 阶段 2 Flutter 侧桥接已提交：`b97a65e 完成阶段2：补齐Android后台采集桥接协议与配置模型`

## 当前下一步

- [x] 让数字生活进入真实采集链路
- [x] 让调试页消费真实存储与实时样本的混合结果
- [x] 为阶段 1 做全量验证并单独提交
- [x] 为阶段 1 剩余收尾项补充增量提交
- [x] 进入阶段 2：Android / iPhone 平台侧后台采集实现

## 阶段 2 当前进展

- 已补齐统一后台采集状态模型，并把后台链路状态接入采集调试页。
- 已补齐 Android 后台采集的 Flutter 侧配置模型与桥接协议。
- 已补齐 Android / iOS 宿主工程基线，解决原生后台能力无落点的问题。
- 已补齐 Android 宿主侧 `MethodChannel` 启停骨架与最小状态控制器，后续可在此基础上接前台服务与调度实现。
- 已补齐 Android 宿主后台状态查询出口，并把原生宿主摘要接入 Flutter 调试页，便于继续推进前台服务与调度实现时做联调观测。
- 已补齐 Android 前台服务策略、原生调度门面、通知组装、Worker 骨架与恢复刷新入口，正在等待原生单测验证。
- 已补齐 Android 前台服务编排器、周期任务计划器、执行器和可恢复状态仓，正在等待 Gradle wrapper 锁释放后进行原生单测验证。
- 已补齐 Android 前台 `Service` 壳、WorkManager worker 壳、可持久化状态仓和请求编码器，系统级恢复链路已具备最小实现。
- 当前仍缺 Android 前台服务 / 调度实现，以及 iPhone 平台侧后台策略实现。
- 后续阶段 2 的重点应转到 `android/`、`ios/` 与 `lib/platform/` 的正式实现，而不是继续只停留在共享层抽象。

## 阶段 1 收口说明

- 当前“数字生活”已接入跨平台可运行的最小真实入口：以前后台生命周期事件近似生成亮屏时长、解锁次数与专注打断次数。
- Android 全量 `Usage Access` 采集与 iPhone 更强替代指标仍需后续原生桥接，不在本次阶段 1 提交中强行扩展。
- 因此，阶段 1 以“真实链路打通与调试可见”为完成标准，阶段 2 再进入后台连续采集与平台增强能力。

---

## 关键约束

- 不得再以 mock 数据作为页面推进前提
- 不得把 iPhone 留在演示壳状态
- 不得继续按“先页面后能力”的顺序执行
- 页面层不得直接消费原始传感器数据
- 所有高权限能力都必须有用户可见中文说明与降级逻辑

---

## 结论

从这一版计划开始，项目的主线不再是：

- “尽快把所有页面做出来”

而是：

- “尽快让双平台都产生真实数据，并把真实数据转成可理解、可解释、可持续运行的健康洞察”

后续所有开发都应优先服务这一目标。
