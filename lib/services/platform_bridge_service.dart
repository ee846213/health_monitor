import 'package:flutter/services.dart';

class PlatformBridgeService {
  PlatformBridgeService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : methodChannel =
           methodChannel ?? const MethodChannel('health_monitor/platform_bridge'),
       eventChannel =
           eventChannel ?? const EventChannel('health_monitor/platform_events');

  // 阶段 1 先把统一桥接入口固定下来，
  // 后续 Android / iOS 能力扩展时可以沿用同一协议名，避免页面层感知底层重构。
  final MethodChannel methodChannel;
  final EventChannel eventChannel;
}
