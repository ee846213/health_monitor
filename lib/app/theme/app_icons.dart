import 'package:flutter/material.dart';

/// Pencil 设计文件图标 → Flutter IconData 映射。
///
/// 设计来源: docs/designs/health-monitor-mobile-pencil.pen.pen
/// 所有图标在 Flutter 中均有对应 Material Icons，无需额外资源文件。
class AppIcons {
  const AppIcons._();

  // --- 导航图标 ---

  /// 首页 - 今日 (Pencil: 文字图标 "今日")
  static const IconData overview = Icons.home_outlined;

  /// 简报 - 回顾 (Pencil: 文字图标 "回顾")
  static const IconData briefing = Icons.article_outlined;

  /// 我的 - 设置 (Pencil: 文字图标 "设置")
  static const IconData profile = Icons.person_outlined;

  // --- 功能图标 ---

  /// 提醒铃铛 (Pencil: lucide bell-ring, 7 处使用)
  static const IconData bellRing = Icons.notifications_active_rounded;

  /// 通知 (Pencil: Material Symbols notifications, 3 处使用)
  static const IconData notifications = Icons.notifications_outlined;

  /// 活动 (Pencil: 首页维度图标 activity)
  static const IconData activity = Icons.directions_walk_rounded;

  /// 姿势 (Pencil: 首页维度图标 posture)
  static const IconData posture = Icons.accessibility_new_rounded;

  /// 数字生活 (Pencil: 首页维度图标 usage)
  static const IconData digitalUsage = Icons.mouse_rounded;

  /// 环境噪音 (Pencil: 首页维度图标 environment)
  static const IconData environment = Icons.volume_up_rounded;

  /// 太阳/今日概览 (Pencil: 首页核心结论区)
  static const IconData sunny = Icons.sunny;

  /// 警告 (Pencil: 缺失维度横幅)
  static const IconData info = Icons.info_outline;

  /// 箭头/展开 (Pencil: 卡片右侧操作)
  static const IconData chevronRight = Icons.chevron_right;
}