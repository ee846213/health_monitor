# 健康监测移动端高保真原型

本目录为从 OpenDesign 导出的移动端高保真交互原型文件，用于：

- 作为 Flutter 页面实现前的视觉与交互参考
- 对照 `docs/superpowers/specs/2026-06-07-health-monitor-ui-ux-design.md` 做界面还原
- 后续拆分组件、状态和页面流转时的原始依据

## 来源

- 原型来源：OpenDesign 本地项目导出
- 导出日期：2026-06-08
- 设计方向：Apple 风格、高保真、中文语境、温和陪伴型健康助手

## 文件结构

- `index.html`：原型总览入口页
- `shared.css`：共享样式
- `app.js`：原型交互脚本
- `frames/iphone-15-pro.html`：iPhone 15 Pro 设备外壳预览容器
- `screens/`：各页面与状态原型

## 页面映射

- `screens/home.html`：首页默认态
- `screens/home-sheet.html`：今日状态卡半屏展开
- `screens/report.html`：单张日报
- `screens/report-list.html`：最近 7 天简报列表
- `screens/profile.html`：我的页面主入口
- `screens/reason.html`：提醒原因解释态
- `screens/permission-off.html`：权限未开启态
- `screens/empty-data.html`：数据不足空态
- `screens/reminder-log.html`：提醒记录页补充态

## 使用说明

- 这是静态原型文件，不是 Flutter 生产代码
- 后续开发时建议优先提取：
  - 颜色、圆角、间距、层级风格
  - 首页卡片布局与半屏浮层关系
  - 简报页列表与单日报切换结构
  - “我”页的信息分组与权限说明方式

## 建议后续落地方式

- 将原型拆解为 Flutter 页面：
  - `home`
  - `report`
  - `profile`
  - `reason_detail`
  - `permission_state`
  - `empty_state`
- 将共享视觉规则沉淀为：
  - App 色板
  - 字体层级
  - 卡片组件
  - 底部导航
  - 半屏浮层组件
