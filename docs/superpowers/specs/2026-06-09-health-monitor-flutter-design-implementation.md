# 健康监测 App Flutter 设计落地文档

日期：2026-06-09  
状态：待评审

## 1. 文档目标

本文档用于把当前已经确认的高保真设计稿、UI/UX 方向与 Flutter 技术路线连接起来，形成一份可直接指导页面开发的落地文档。

本文档重点回答四个问题：

- 设计稿里的视觉语言如何抽成 Flutter 可复用的 design tokens
- 当前 9 个页面 / 状态应如何拆成 Flutter 页面与组件
- 哪些内容应沉到共享主题层，哪些内容应留在 feature 内部
- 页面层、状态层、领域层之间的边界应如何保持清晰

后续 Flutter 页面实现、组件命名、主题抽象、页面目录组织，默认优先遵循本文档。

## 2. 设计来源

当前 Flutter 落地以以下材料为准：

- 产品设计文档：`docs/superpowers/specs/2026-06-07-health-monitor-design.md`
- UI / UX 文档：`docs/superpowers/specs/2026-06-07-health-monitor-ui-ux-design.md`
- 技术选型文档：`docs/superpowers/specs/2026-06-07-health-monitor-technical-selection.md`
- MVP 实现计划：`docs/superpowers/plans/2026-06-07-health-monitor-mvp-implementation-plan.md`
- OpenDesign 原型：`docs/prototypes/health-monitor-mobile-opendesign/`
- Pencil 设计稿：`docs/designs/ui.pen`

当前设计稿已经确认的页面范围为：

- 组件板
- 首页默认态
- 首页半屏展开态
- 单张日报
- 最近 7 天简报
- 我页主页
- 提醒原因解释页
- 权限未开启页
- 数据不足空态页
- 提醒记录补充页

## 3. 设计落地总原则

### 3.1 产品气质

Flutter 实现时必须始终保持以下气质：

- 温和陪伴型，而不是监控型
- 可解释，而不是神秘打分型
- 低打扰，而不是高频规则提醒型
- 偏生活化语言，而不是医学诊断型

### 3.2 视觉原则

- 以暖白、雾白、鼠尾草绿、淡雾蓝、暖沙色为主
- 卡片层级依赖背景明度、边框、留白建立，不依赖厚重阴影
- 文本层级应清晰，但不能全页都在抢注意力
- 首页主卡和简报主卡必须保留“结论先看”的节奏

### 3.3 Flutter 实现原则

- 优先使用 Material 3，但不能直接套默认视觉
- 通过 ThemeExtension 承载产品自定义 token
- 页面层不直接拼装原始传感器语义
- 页面只消费 ViewModel 或 UI Model，不直接消费原始领域事件

## 4. 页面映射

建议将设计稿页面映射为以下 Flutter 页面或状态：

| 设计稿页面 | Flutter 页面 / 状态 | 建议 feature |
| --- | --- | --- |
| 首页默认态 | `OverviewPage` 默认态 | `features/overview/` |
| 首页半屏展开态 | `OverviewInsightSheet` | `features/overview/` |
| 单张日报 | `DailyBriefPage` 今日态 | `features/daily_brief/` |
| 最近 7 天简报 | `DailyBriefHistoryPage` | `features/daily_brief/` |
| 我页主页 | `ProfilePage` | `features/settings/` |
| 提醒原因解释页 | `ReminderReasonPage` | `features/reminders/` |
| 权限未开启页 | `PermissionOffPage` | `features/permissions/` |
| 数据不足空态页 | `OverviewEmptyStatePage` 或首页空态分支 | `features/overview/` |
| 提醒记录补充页 | `ReminderLogPage` | `features/reminders/` |

说明：

- “首页半屏展开态”不建议作为独立路由页面实现，优先用 `showModalBottomSheet` 或 `DraggableScrollableSheet`
- “数据不足空态页”在产品层更像首页状态分支，不一定需要独立导航入口
- “提醒记录补充页”是“我”页进入的二级详情页

## 5. Design Tokens

## 5.1 颜色 Token

建议基于当前设计稿整理为以下命名：

| Token | 色值 | 用途 |
| --- | --- | --- |
| `canvas` | `#F5F3EE` | 应用大背景 |
| `surfacePrimary` | `#FFFDF8` | 主卡片背景 |
| `surfaceSecondary` | `#F0ECE4` | 次级卡片背景 |
| `surfaceGlass` | `#FFFDF0CC` | 底部浮动导航 / 毛玻璃感背景 |
| `borderSubtle` | `#DDD8CF` | 卡片描边、分隔边界 |
| `textPrimary` | `#1F2320` | 一级正文、标题 |
| `textSecondary` | `#505750` | 二级说明文案 |
| `textMuted` | `#7A8179` | 辅助说明、标签文字 |
| `sagePrimary` | `#7B9786` | 主品牌辅助色 |
| `sageDeep` | `#5C7768` | 深层强调文字 / 图标 |
| `sageSoft` | `#E6EEE8` | 正向状态背景、标签背景 |
| `mistBlue` | `#E0EBEE` | 冷静信息背景、看屏类指标背景 |
| `warmSand` | `#F4E8DA` | 温和提示、久坐类背景 |
| `amberSoft` | `#D8A56E` | 温和提醒色 |
| `peachSoft` | `#E8C3A8` | 暖色辅助块 |
| `dangerSoft` | `#C88976` | 权限缺失、风险提示文字 |

颜色落地要求：

- 不使用高饱和纯色作为大面积底色
- 不使用紫色科技感主色
- 不使用大面积医疗蓝作为品牌底色
- 所有提醒类颜色都应“能提示，但不惊吓”

## 5.2 字体 Token

首版建议继续使用系统友好的无衬线路线，便于双平台一致性控制：

| Token | 建议值 | 用途 |
| --- | --- | --- |
| `fontHeading` | `Inter` 或系统 San Francisco 等效 | 页面标题、核心结论 |
| `fontBody` | `Inter` 或系统中文无衬线 | 常规正文、卡片说明 |
| `fontData` | `IBM Plex Mono` | 指标数字、时间、对齐型数值 |

建议字号层级：

| Token | 建议值 | 用途 |
| --- | --- | --- |
| `displayLg` | `30` | 页面主标题 |
| `displayMd` | `24` | 主卡结论 |
| `titleLg` | `22` | 卡片主标题 |
| `titleMd` | `20` | 区块标题 |
| `bodyMd` | `14` | 正常正文 |
| `bodySm` | `13` | 次级说明 |
| `labelMd` | `12` | 标签、状态胶囊 |
| `labelSm` | `11` | 极轻辅助信息 |

文本实现要求：

- 标题与总结句优先采用较大的字重和紧凑行高
- 说明文案使用更松的行高，避免技术说明感
- 数字信息要规整，但不需要做强 dashboard 感

## 5.3 间距 Token

建议统一为 4 的倍数体系，并保留业务语义名称：

| Token | 建议值 |
| --- | --- |
| `spaceXs` | `4` |
| `spaceSm` | `8` |
| `spaceMd` | `12` |
| `spaceLg` | `16` |
| `spaceXl` | `24` |
| `space2xl` | `32` |

推荐使用规则：

- 页面左右安全内边距：`18` 到 `20`
- 页面主区块间距：`20` 到 `24`
- 卡片内部纵向间距：`10` 到 `16`
- 胶囊 / 标签内边距：`8` 到 `10`

## 5.4 圆角 Token

| Token | 建议值 | 用途 |
| --- | --- | --- |
| `radiusScreen` | `36` | 高保真设备画板 / 大容器预览 |
| `radiusCard` | `28` | 主卡片、列表卡片 |
| `radiusItem` | `22` | 小卡、列表项 |
| `radiusChip` | `18` | 标签、状态丸子、时间胶囊 |
| `radiusCircle` | `999` | 圆形按钮 / 圆形徽标 |

## 5.5 阴影与描边 Token

首版建议弱化阴影，强调轻描边：

- 卡片默认优先使用 `1px` 柔和描边
- 毛玻璃导航条可使用一层轻阴影
- 不建议在每个列表项上都堆叠阴影

建议统一一个轻阴影 token：

- `shadowSoft = Color(0x1420231F), blur 24, offsetY 10`

## 5.6 动效 Token

建议保留轻量动效，不做炫技：

| Token | 建议值 |
| --- | --- |
| `durationFast` | `150ms` |
| `durationBase` | `220ms` |
| `curveStandard` | `easeOutCubic` 或接近曲线 |

动效优先使用场景：

- 首页洞察卡展开 / 收起
- 简报时间切换
- 页面状态切换
- 提醒原因解释页进入

## 6. Flutter 主题层落地建议

建议在 `lib/app/` 和 `lib/core/` 中建立统一主题入口。

推荐文件结构：

- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_color_tokens.dart`
- `lib/app/theme/app_text_tokens.dart`
- `lib/app/theme/app_spacing_tokens.dart`
- `lib/app/theme/app_radius_tokens.dart`
- `lib/app/theme/theme_extensions.dart`

推荐 ThemeExtension 拆分：

- `HealthColorTokens`
- `HealthSpacingTokens`
- `HealthRadiusTokens`
- `HealthMotionTokens`

建议职责：

- `ColorScheme` 保留 Material 3 基础兼容能力
- 产品自定义色、间距、圆角走 ThemeExtension
- 页面组件内部禁止硬编码核心品牌色

推荐主题读取方式：

```dart
final colors = Theme.of(context).extension<HealthColorTokens>()!;
final spacing = Theme.of(context).extension<HealthSpacingTokens>()!;
final radius = Theme.of(context).extension<HealthRadiusTokens>()!;
```

## 7. 共享组件拆分建议

## 7.1 App Shell 级组件

建议沉到 `lib/widgets/` 或 `lib/app/widgets/`：

- `HealthAppScaffold`
- `HealthBottomNavBar`
- `HealthPageHeader`
- `HealthSectionCard`

用途：

- 提供统一背景、SafeArea、底部导航占位
- 统一页面标题与右上角轻入口样式
- 统一卡片描边、圆角、背景层级

## 7.2 首页组件

建议放在 `lib/features/overview/widgets/`：

- `TodayInsightHeroCard`
- `TodayMetricRow`
- `HealthMetricCard`
- `InsightListCard`
- `InsightListItem`
- `TodayActionCard`
- `OverviewInsightSheet`

组件职责：

- `TodayInsightHeroCard` 负责“结论先看”
- `TodayMetricRow` 负责三大指标容器
- `HealthMetricCard` 负责单指标展示
- `OverviewInsightSheet` 负责展开态解释

## 7.3 简报组件

建议放在 `lib/features/daily_brief/widgets/`：

- `BriefRangeSegment`
- `DailyBriefCard`
- `BriefSummaryPillRow`
- `BriefSectionBlock`
- `BriefHistoryListItem`

实现要求：

- 单张日报与最近 7 天页面应复用尽可能多的块级组件
- “今天 / 昨天 / 最近 7 天”切换建议复用同一套 segment UI

## 7.4 我页与设置组件

建议放在 `lib/features/settings/widgets/`：

- `ProfileReminderSummaryCard`
- `PreferenceItemRow`
- `CapabilityStatusRow`
- `PrivacyExplanationCard`

实现要求：

- “我”页是信任与控制中心，不要做成通用设置列表页面
- 每一项状态都要给出“能力是否参与分析”的解释空间

## 7.5 提醒相关组件

建议放在 `lib/features/reminders/widgets/`：

- `ReminderLogItemCard`
- `ReminderReasonBlock`
- `ReminderReasonSummaryCard`

实现要求：

- 每条提醒都必须可解释
- 记录页与原因详情页可以共享“触发原因说明块”

## 7.6 权限与空态组件

建议放在对应 feature 内部：

- `PermissionCapabilityCard`
- `PermissionImpactBlock`
- `OverviewEmptyStateHero`
- `DataAccumulatingHintCard`

## 8. 页面拆分建议

## 8.1 首页 `OverviewPage`

建议页面结构：

1. `HealthPageHeader`
2. `TodayInsightHeroCard`
3. `TodayMetricRow`
4. `InsightListCard`
5. `TodayActionCard`
6. `HealthBottomNavBar`

状态分支：

- 正常态
- 数据不足空态
- 权限缺失态的轻提示入口

## 8.2 首页展开态 `OverviewInsightSheet`

建议结构：

1. 状态标签与标题
2. 为什么这样判断
3. 今日最主要问题
4. 次级观察列表
5. 当前最值得做的动作

实现建议：

- 使用 `showModalBottomSheet`
- 内容区可滚动
- 文案语气必须像解释，不像警报

## 8.3 简报页 `DailyBriefPage`

建议结构：

1. 页面头部
2. 时间切换 Segment
3. 单张日报主卡
4. 底部导航

建议通过 ViewModel 提供：

- `selectedRange`
- `headline`
- `metricSummaries`
- `activitySummary`
- `digitalLifeSummary`
- `postureOrEnvironmentSummary`
- `nextSuggestion`

## 8.4 最近 7 天页 `DailyBriefHistoryPage`

建议结构：

1. 页面头部
2. 最近 7 天摘要卡
3. 日报列表
4. 一条周建议

实现重点：

- 不做复杂图表优先
- 先把周摘要语言和列表信息密度打磨好

## 8.5 我页 `ProfilePage`

建议结构：

1. 页面头部
2. 我的提醒摘要卡
3. 提醒与显示偏好卡
4. 权限与感知状态卡
5. 隐私与数据说明卡
6. 底部导航

实现重点：

- 不要用大量系统设置样式直接堆砌
- 关键是“我知道你看到了什么，也知道我能关掉什么”

## 8.6 提醒记录页 `ReminderLogPage`

建议结构：

1. 页面头部
2. 今日提醒摘要
3. 提醒记录列表
4. 底部信任说明

每条记录至少包含：

- 提醒时间
- 提醒文案
- 触发原因摘要
- 进入详情页的能力

## 8.7 提醒原因页 `ReminderReasonPage`

建议结构：

1. 提醒时间与主句
2. 触发依据
3. 为什么是现在
4. 为什么推荐这个动作
5. 可选的提醒调节建议

## 8.8 权限未开启页 `PermissionOffPage`

建议结构：

1. 权限未开启说明卡
2. 开启后可获得能力
3. 不开启时仍可使用能力
4. 继续基础模式的动作

要求：

- 明确告诉用户不开启会失去什么
- 允许用户降级使用，而不是强拦截

## 8.9 数据不足空态 `OverviewEmptyStatePage`

建议结构：

1. 空态图形或空态信息块
2. 为什么今天不下结论
3. 用户现在可以做什么
4. 晚些时候再看的建议

## 9. 路由建议

基于 GoRouter，建议保留“三个一级 tab + 若干二级详情”的结构。

建议路由：

- `/overview`
- `/brief`
- `/profile`
- `/brief/history`
- `/reminders/log`
- `/reminders/reason`
- `/permissions/off`

说明：

- `OverviewInsightSheet` 不一定走路由
- `OverviewEmptyStatePage` 更推荐作为首页状态分支

## 10. 状态与数据边界

页面层建议只消费 UI Model，不直接消费底层模型。

推荐分层：

- `domain/`：原始业务模型、规则结果、建议结果
- `services/`：能力服务接口、聚合接口
- `features/.../providers/`：页面状态与 ViewModel 组装
- `features/.../widgets/`：纯展示组件

示例边界：

- 页面不直接显示“加速度计判断为 xxx”
- 页面只显示“下午久坐明显”“低头用机时间偏长”
- 页面不直接处理权限插件返回值
- 页面只消费 `CapabilityUiState`

## 11. 推荐目录落点

结合当前技术基线，建议目录继续演进为：

- `lib/app/`
  - `app.dart`
  - `router/`
  - `theme/`
- `lib/core/`
  - `extensions/`
  - `utils/`
  - `constants/`
- `lib/domain/`
  - `models/`
  - `capability/`
  - `brief/`
  - `reminder/`
- `lib/features/`
  - `overview/`
    - `pages/`
    - `providers/`
    - `widgets/`
  - `daily_brief/`
    - `pages/`
    - `providers/`
    - `widgets/`
  - `reminders/`
    - `pages/`
    - `providers/`
    - `widgets/`
  - `permissions/`
    - `pages/`
    - `providers/`
    - `widgets/`
  - `settings/`
    - `pages/`
    - `providers/`
    - `widgets/`
- `lib/widgets/`
  - `cards/`
  - `navigation/`
  - `states/`

## 12. 实现顺序建议

建议按以下顺序推进页面开发：

1. 先建立 ThemeExtension 与 design tokens
2. 再建立共享壳组件：页面头、导航、基础卡片
3. 先做首页默认态
4. 再做首页展开态
5. 再做简报页与最近 7 天页
6. 再做“我”页
7. 最后补权限页、空态页、提醒记录与原因页

原因：

- 首页是产品气质最集中的地方
- 首页组件一旦稳定，很多样式可以向简报页和我页复用
- 异常态和详情页更适合在共享组件稳定后补齐

## 13. 不建议做法

- 不要直接套默认 `Card` 样式后微调
- 不要让每个 feature 都私自维护一套颜色常量
- 不要把页面结构过早抽成过多“万能组件”
- 不要让页面层直接决定权限文案和降级逻辑
- 不要把首页实现成数据 dashboard
- 不要把提醒解释实现成技术日志

## 14. 文档结论

当前这套设计稿适合按“共享主题层 + feature 页面组件层 + 领域状态映射层”的方式落地到 Flutter。

首版 Flutter 实现的重点不是炫技，也不是把所有页面做成高度抽象组件库，而是：

- 先稳定主题与视觉 token
- 先稳定首页与简报的核心体验
- 先稳定“可解释、可理解、可控制”的产品语气
- 再逐步补齐权限、提醒、空态和详情页

若后续设计稿继续迭代，应优先更新本文件中的：

- design tokens
- 页面映射
- 组件清单
- 路由结构

以保证设计语义和 Flutter 实现语义保持一致。
