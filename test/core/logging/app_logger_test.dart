import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/core/logging/app_logger.dart';
import 'package:health_monitor/core/logging/diagnostics_logger.dart';
import 'package:health_monitor/domain/background/background_capture_state.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

void main() {
  setUp(() => AppLogger.instance.clear());

  group('AppLogger', () {
    test('各级别日志应正确写入缓冲', () {
      AppLogger.instance.info('test', 'info msg');
      AppLogger.instance.warning('test', 'warn msg');
      AppLogger.instance.error('test', 'err msg', {'code': 1});

      final entries = AppLogger.instance.entries;
      expect(entries.length, 3);
      expect(entries[0].level, LogLevel.error);
      expect(entries[0].data?['code'], 1);
    });

    test('超出缓冲上限时应移除最早条目', () {
      for (var i = 0; i < 260; i++) {
        AppLogger.instance.info('test', 'msg $i');
      }
      expect(AppLogger.instance.entries.length, 256);
    });

    test('clear 应清空缓冲', () {
      AppLogger.instance.info('test', 'msg');
      AppLogger.instance.clear();
      expect(AppLogger.instance.entries, isEmpty);
    });
  });

  group('DiagnosticsLogger', () {
    const logger = DiagnosticsLogger();

    test('logCaptureState 应记录状态和原因', () {
      const state = BackgroundCaptureState(status: BackgroundCaptureStatus.restricted, label: '受限', reason: '测试限制');
      logger.logCaptureState(state);

      final entries = AppLogger.instance.entries;
      expect(entries.single.tag, 'capture');
      expect(entries.single.data?['status'], 'restricted');
    });

    test('logBackgroundLink 应记录平台摘要', () {
      logger.logBackgroundLink('iOS', '系统限制中', false);

      final entries = AppLogger.instance.entries;
      expect(entries.single.tag, 'background');
      expect(entries.single.data?['platform'], 'iOS');
    });

    test('logRuleOutput 应按提醒级别输出', () {
      final verdicts = <RuleVerdict>[
        const RuleVerdict(dimension: 'activity', level: 'concern', summary: '久坐', detail: '久坐占比高', shouldRemind: true, reminderType: 'sedentaryBreak'),
        const RuleVerdict(dimension: 'usage', level: 'normal', summary: '正常', detail: '使用正常'),
      ];
      logger.logRuleOutput(verdicts);

      final entries = AppLogger.instance.entries;
      expect(entries.length, 2);
      expect(entries.where((e) => e.level == LogLevel.warning), isNotEmpty);
    });

    test('logPermissionChange 应记录变化方向', () {
      logger.logPermissionChange(PermissionType.motion, 'denied', 'granted');

      final entries = AppLogger.instance.entries;
      expect(entries.single.tag, 'permission');
      expect(entries.single.data?['from'], 'denied');
      expect(entries.single.data?['to'], 'granted');
    });
  });
}