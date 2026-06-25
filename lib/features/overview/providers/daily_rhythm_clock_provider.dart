import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 节奏轴可见窗口右边界（当前时刻）的时钟。
///
/// 每小时触发一次重建，使节点过滤与弧线终点随「现在」推进。
final dailyRhythmClockProvider = Provider<DateTime>((Ref ref) {
  final timer = Timer.periodic(const Duration(hours: 1), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);
  return DateTime.now();
});
