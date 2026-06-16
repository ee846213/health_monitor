# 首页字段级刷新设计

日期：2026-06-17  
状态：待评审

## 1. 文档目标

本文档用于定义首页 `OverviewPage` 的刷新粒度收敛方案。

当前首页在 `ready` 态下由单个聚合 provider 输出整份 `OverviewDashboardViewModel`，任一相关数据变化都会带动整页 `ready` 内容重建。此次改动的目标是把刷新粒度收敛到“具体字段变化，只刷新对应 `Text` / 图标 / 图形参数`”，避免首页主卡、指标卡、环境条和建议气泡一起联动刷新。

本次设计只覆盖首页 `features/overview/`，不修改简报页、趋势页、我页和采集层事件模型。

## 2. 范围与非目标

### 2.1 本次范围

- 首页页面状态入口拆分
- 首页 `ready` 态数据提供方式拆分
- 首页文案、图标、图形参数的字段级 provider 拆分
- 首页相关 provider 测试与 widget 冒烟测试调整

### 2.2 非目标

- 不把 `DataCollector` 改造成 UI 事件总线
- 不移除 `dataCollectorRevisionProvider`
- 不重做首页视觉设计
- 不修改首页卡片点击后的底部浮层能力边界
- 不为本次需求引入新的状态管理库

## 3. 当前问题

当前首页由 `overviewViewModelProvider` 统一产出页面状态、快照、提示文案和提醒历史，`OverviewPage` 在 `ready` 态直接消费整份 view model。这样会带来两个问题：

1. 任一相关数据变化都会让 `ready` 态整块内容进入同一次 provider 更新链路。
2. 即使只有某一段文案、某一个图标或某一个图形参数变化，也会让不相关控件一起收到重建信号。

对用户的直接表现是：首页容易出现整块抖动式刷新，而不是“只有变了的内容更新”。

## 4. 设计原则

### 4.1 页面状态与字段刷新分层

- 页面级只保留一次粗粒度状态判断：`permissionDenied / dataInsufficient / ready`
- 进入 `ready` 后，页面布局壳、卡片壳、间距、边框、点击行为保持静态
- 具体动态内容拆成字段级 provider，最小到单段文案、单个图标、单个图形参数

### 4.2 文件统一，provider 粒度不统一

本次允许把首页字段级 provider 统一放在一个 provider 文件中，便于维护和检索；但不把所有字段收回成单个 Riverpod provider。  
原因是：如果只保留一个整页 provider，即使只变了一个字段，依赖整页数据的所有控件仍会一起收到更新，无法满足本次“字段级刷新”的目标。

### 4.3 仍以共享快照为上游

首页仍然保留一个共享的 `DashboardSnapshot` 作为 `ready` 态上游数据源，再通过字段级 provider 从这个上游快照派生具体显示内容。  
这样可以保持现有服务层与页面层边界清晰，避免把采集层侵入到 UI 层语义。

## 5. Provider 结构

## 5.1 页面状态入口

新增页面门禁 provider：

- `overviewScreenStateProvider`

职责：

- 只负责产出 `OverviewScreenState`
- 决定首页显示 `PermissionDeniedPage`、`DataInsufficientPage` 还是 `ready` 态页面壳

它不再携带整份首页快照，也不再承担字段展示职责。

## 5.2 ready 态上游快照

新增 ready 态快照 provider：

- `overviewDashboardSnapshotProvider`

职责：

- 继续监听首页所需的数据刷新信号
- 统一调用 `DashboardService` 生成 `DashboardSnapshot`
- 只负责首页 `ready` 态的完整快照，不混入页面状态文案

新增同步桥接 provider：

- `overviewDashboardDataProvider`

职责：

- 从 `overviewDashboardSnapshotProvider` 中取出当前可用快照
- 作为所有字段级 `select` 的统一上游

设计意图是让字段级 provider 可以共享同一份上游数据，而不是让每个小字段各自跑一遍异步计算。

## 5.3 字段级 provider

字段级 provider 统一放在同一个 provider 文件中，按语义分组命名。

### 5.3.1 健康分主卡

- `overviewHealthScoreValueProvider`
- `overviewHealthScoreProgressProvider`
- `overviewHealthScoreSummaryProvider`
- `overviewHealthScoreStepPillProvider`
- `overviewHealthScoreSedentaryPillProvider`
- `overviewHealthScoreScreenPillProvider`

### 5.3.2 三张指标卡

- `overviewStepValueTextProvider`
- `overviewStepCaptionTextProvider`
- `overviewSedentaryValueTextProvider`
- `overviewSedentaryCaptionTextProvider`
- `overviewScreenValueTextProvider`
- `overviewScreenCaptionTextProvider`

### 5.3.3 环境条

- `overviewEnvironmentLightTextProvider`
- `overviewEnvironmentLightIconProvider`
- `overviewEnvironmentNoiseTextProvider`
- `overviewEnvironmentNoiseIconProvider`

### 5.3.4 建议气泡

- `overviewAdviceSourceTextProvider`
- `overviewAdviceBodyTextProvider`

### 5.3.5 顶部提示

- `overviewPreciseDetectionNoticeTextProvider`
- `overviewMissingDimensionsTextProvider`

这些 provider 的共同要求是：

- 每个 provider 只返回一个控件直接需要的最终显示值
- 尽量返回字符串、枚举、数值或轻量 UI 参数
- 使用 `select` 只订阅与自己相关的快照字段

## 6. Widget 切分策略

## 6.1 页面壳

`OverviewPage` 只 watch `overviewScreenStateProvider`。

- 如果是 `permissionDenied`，显示权限页
- 如果是 `dataInsufficient`，显示空态页
- 如果是 `ready`，只渲染静态布局壳

`ready` 态布局壳不直接持有整份 `DashboardSnapshot`。

## 6.2 健康分主卡

`HealthScoreHero` 保留卡片壳、点击行为和静态说明文字，以下动态内容改为内部小 `Consumer`：

- 环形进度
- 健康分数字
- 健康分说明文案
- 三个分项 pill 文案

要求：

- 圆环只订阅 `progress`
- 数字只订阅健康分值
- 说明文案只订阅摘要文本
- 三个 pill 各自只订阅自己的文案

## 6.3 指标卡

`MetricCards` 保留 `Row`、卡片容器、点击行为和标题常量文案。

三张卡内部的动态内容改为字段级订阅：

- 步数卡：数值、目标文案
- 久坐卡：数值、最长久坐文案
- 屏幕卡：数值、较昨日文案

如果后续加入涨跌箭头、颜色状态或图形标记，也按与文案相同的字段粒度拆分，不与其他卡片共用刷新信号。

## 6.4 环境条

`EnvironmentSnapshotBar` 保留“环境快照”“光照”“噪音”等静态标题和容器结构。

动态内容拆为四项：

- 光照文案
- 光照图标
- 噪音文案
- 噪音图标

只要图标结果会随字段变化，就与文案一样按独立 provider 订阅。

## 6.5 建议气泡

`AiSuggestionBubble` 保留背景容器和静态尾注。

动态部分拆为：

- 来源标签文案
- 建议正文文案

如果未来来源图标可变，也按相同原则拆为独立 provider。

## 7. 刷新映射

### 7.1 步数变化

步数变化时，允许刷新的内容：

- 步数卡数值
- 步数卡 caption
- 健康分数字
- 健康分圆环进度
- 健康分中的步数 pill
- 受分数档位影响的健康分摘要
- 如果建议文本真实变化，建议正文与来源标签

不应刷新的内容：

- 噪音图标与噪音文案
- 光照图标与光照文案
- 久坐卡无关文案
- 屏幕卡无关文案
- 页面壳与卡片壳

### 7.2 久坐变化

久坐变化时，允许刷新的内容：

- 久坐卡数值
- 久坐卡 caption
- 健康分数字
- 健康分圆环进度
- 健康分中的久坐 pill
- 受分数档位影响的健康分摘要
- 如果建议文本真实变化，建议正文与来源标签

### 7.3 屏幕变化

屏幕变化时，允许刷新的内容：

- 屏幕卡数值
- 屏幕卡 caption
- 健康分数字
- 健康分圆环进度
- 健康分中的屏幕 pill
- 受影响的健康分摘要
- 受影响的建议文本与来源标签

### 7.4 光照或噪音变化

光照或噪音变化时，允许刷新的内容：

- 对应环境文案
- 对应环境图标
- 如果建议文本真实变化，建议正文与来源标签

不应直接带动步数、久坐、屏幕卡的文本刷新。

### 7.5 权限或缺失维度变化

权限或缺失维度变化时，只刷新：

- 精确识别提示文案
- 缺失维度提示文案

不直接刷新主卡与三张指标卡的文本或图形。

## 8. 文件落点

本次建议的主要文件调整如下：

- `lib/features/overview/providers/overview_providers.dart`
  保留共享依赖、页面状态解析与基础入口
- `lib/features/overview/providers/overview_ready_providers.dart`
  新增首页 `ready` 态上游快照与字段级 provider
- `lib/features/overview/pages/overview_page.dart`
  改为只处理页面状态和静态页面壳
- `lib/features/overview/widgets/health_score_hero.dart`
  改为内部字段级订阅
- `lib/features/overview/widgets/metric_cards.dart`
  改为卡内字段级订阅
- `lib/features/overview/widgets/environment_snapshot_bar.dart`
  改为文案与图标字段级订阅
- `lib/features/overview/widgets/ai_suggestion_bubble.dart`
  改为来源与正文字段级订阅

## 9. 测试方案

## 9.1 Provider 测试

优先补字段通知边界测试，不直接依赖 Flutter 内部 rebuild 次数。

至少覆盖：

1. 步数变化时：
   - `overviewStepValueTextProvider` 更新
   - `overviewStepCaptionTextProvider` 更新
   - `overviewHealthScoreValueProvider` 更新
   - `overviewEnvironmentNoiseIconProvider` 不更新
2. 环境变化时：
   - 对应环境文案 provider 更新
   - 对应环境图标 provider 更新
   - `overviewStepValueTextProvider` 不更新
3. 建议文本未变化时：
   - `overviewAdviceBodyTextProvider` 不重复通知

## 9.2 Widget 冒烟测试

保留首页 `ready` 态显示正确的基础 widget 测试，确保字段级拆分后：

- 页面仍能正常展示
- 卡片点击行为不丢失
- 静态标题与动态字段组合仍然正确

## 10. 风险与约束

### 10.1 provider 数量变多

这是本次方案的预期成本，但换来的是明确的刷新边界。由于这些 provider 统一落在一个文件中，可维护性仍可接受。

### 10.2 不能只靠单个 provider 达成目标

如果未来为了“看起来更简单”重新合并为单个整页 provider，会重新引入字段联动刷新问题。这个约束必须在实现时保留。

### 10.3 保持服务层与页面层边界

本次字段级刷新只发生在首页页面层，不把采集层、服务层改造成 UI 感知事件层。

## 11. 结论

本次首页刷新优化采用“一个 provider 文件统一管理 + 一个 ready 态共享快照上游 + 多个字段级派生 provider”的方案。

这样可以同时满足三件事：

- 首页状态判断仍然简单
- 代码入口仍然集中
- 动态内容刷新粒度可以细到具体 `Text`、图标和图形参数

这是在当前 `Flutter + Riverpod + DashboardSnapshot` 结构下，风险最小、边界最清晰、最符合本次需求的实现路径。
