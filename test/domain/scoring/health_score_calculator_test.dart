import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';

void main() {
  test('健康分按 40/40/20 权重计算并对各维度封顶', () {
    final score = calculateHealthScore(
      stepCount: 4800,
      sedentaryMinutes: 96,
      screenMinutes: 148,
    );

    expect(score.stepScore, 80);
    expect(score.sedentaryScore, 100);
    expect(score.screenScore, 82);
    expect(score.totalScore, 88);
  });
}
