import 'package:health_monitor/services/capture_health_service.dart';

/// 各采集流的缺口判定阈值。
///
/// 这里不再用统一阈值，而是尽量贴近真实采集频率：
/// - 高频传感器流用较短阈值，及时暴露采集中断
/// - 低频摘要流用较宽松阈值，避免生命周期型事件被误报为缺口
Duration captureGapThresholdFor(String streamKey) {
  switch (streamKey) {
    case streamMotion:
      return const Duration(minutes: 3);
    case streamSteps:
      return const Duration(minutes: 8);
    case streamNoise:
      return const Duration(minutes: 10);
    case streamLight:
      return const Duration(minutes: 10);
    case streamLocation:
      return const Duration(minutes: 45);
    case streamDigitalUsageAndroid:
      return const Duration(hours: 18);
    case streamDigitalUsageAlternative:
      return const Duration(hours: 24);
    case streamNativeRisk:
      return const Duration(hours: 24);
    default:
      return const Duration(minutes: 15);
  }
}
