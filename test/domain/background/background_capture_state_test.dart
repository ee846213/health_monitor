import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';

void main() {
  test('运行中的后台采集状态应标记为健康可用', () {
    const state = BackgroundCaptureState(
      status: BackgroundCaptureStatus.running,
      label: '后台采集中',
      reason: 'Android 前台服务与后台任务都已就绪。',
    );

    expect(state.isOperational, isTrue);
    expect(state.requiresAttention, isFalse);
  });

  test('受限或失败状态应提示需要关注', () {
    const restricted = BackgroundCaptureState(
      status: BackgroundCaptureStatus.restricted,
      label: '后台能力受限',
      reason: '系统限制了当前平台的后台连续性。',
    );
    const failed = BackgroundCaptureState(
      status: BackgroundCaptureStatus.failed,
      label: '后台采集失败',
      reason: '最近一次调度没有成功启动。',
    );

    expect(restricted.requiresAttention, isTrue);
    expect(failed.requiresAttention, isTrue);
    expect(failed.isOperational, isFalse);
  });
}
