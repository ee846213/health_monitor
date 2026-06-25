import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_concentration.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';

void main() {
  final day = DateTime(2026, 6, 22);

  test('活动峰值步数不足时不展示节点', () {
    expect(
      DailyRhythmConcentration.shouldShowActivity(
        DailyRhythmSignals(
          activityPeakAt: day,
          activityPeakSteps: 120,
        ),
      ),
      isFalse,
    );
  });

  test('最长久坐不足 60 分钟时不展示节点', () {
    expect(
      DailyRhythmConcentration.shouldShowPosture(
        DailyRhythmSignals(
          sedentaryStartAt: day,
          sedentaryLongestMinutes: 59,
        ),
      ),
      isFalse,
    );
    expect(
      DailyRhythmConcentration.shouldShowPosture(
        DailyRhythmSignals(
          sedentaryStartAt: day,
          sedentaryLongestMinutes: 60,
        ),
      ),
      isTrue,
    );
  });

  test('数字习惯仅有夜间降级时刻时不展示节点', () {
    expect(
      DailyRhythmConcentration.shouldShowDigital(
        DailyRhythmSignals(
          digitalUsageAt: day,
          digitalUsageIsPrecise: false,
        ),
        hasScreen: true,
      ),
      isFalse,
    );
    expect(
      DailyRhythmConcentration.shouldShowDigital(
        DailyRhythmSignals(
          digitalUsageAt: day,
          digitalUsageIsPrecise: true,
          digitalLongestSessionMinutes: 29,
        ),
        hasScreen: true,
      ),
      isFalse,
    );
    expect(
      DailyRhythmConcentration.shouldShowDigital(
        DailyRhythmSignals(
          digitalUsageAt: day,
          digitalUsageIsPrecise: true,
          digitalLongestSessionMinutes: 30,
        ),
        hasScreen: true,
      ),
      isTrue,
    );
  });

  test('噪音维度不再参与节奏轴展示', () {
    expect(
      DailyRhythmConcentration.shouldShowDimension(
        DailyRhythmDimension.noise,
        DailyRhythmSignals(
          noisePeakAt: day,
          noisePeakDecibel: 80,
        ),
        hasScreen: true,
      ),
      isFalse,
    );
  });

  test('步数未达标或缺少时刻时不展示达标节点', () {
    expect(
      DailyRhythmConcentration.shouldShowStepGoalReached(
        DailyRhythmSignals(stepGoalReachedAt: day),
        currentSteps: 6200,
        goalSteps: 6000,
      ),
      isTrue,
    );
    expect(
      DailyRhythmConcentration.shouldShowStepGoalReached(
        const DailyRhythmSignals(),
        currentSteps: 5163,
        goalSteps: 6000,
      ),
      isFalse,
    );
    expect(
      DailyRhythmConcentration.shouldShowStepGoalReached(
        DailyRhythmSignals(stepGoalReachedAt: day),
        currentSteps: 5800,
        goalSteps: 6000,
      ),
      isFalse,
    );
  });

  test('步数未达标时不展示达标节点', () {
    expect(
      DailyRhythmConcentration.shouldShowStepGoalReached(
        DailyRhythmSignals(stepGoalReachedAt: day),
        currentSteps: 5163,
        goalSteps: 6000,
      ),
      isFalse,
    );
    expect(
      DailyRhythmConcentration.shouldShowStepGoalReached(
        DailyRhythmSignals(stepGoalReachedAt: day),
        currentSteps: 6200,
        goalSteps: 6000,
      ),
      isTrue,
    );
  });

  test('shouldShowDimension 应按维度路由判定', () {
    final signals = DailyRhythmSignals(
      activityPeakAt: day,
      activityPeakSteps: 300,
    );
    expect(
      DailyRhythmConcentration.shouldShowDimension(
        DailyRhythmDimension.activity,
        signals,
        hasScreen: true,
      ),
      isTrue,
    );
    expect(
      DailyRhythmConcentration.shouldShowDimension(
        DailyRhythmDimension.posture,
        signals,
        hasScreen: true,
      ),
      isFalse,
    );
  });
}
