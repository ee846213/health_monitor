import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';

void main() {
  test('健康分按 40/40/20 权重计算并在理想区间内保持满分', () {
    final score = calculateHealthScore(
      stepCount: 4800,
      sedentaryMinutes: 96,
      screenMinutes: 148,
    );

    expect(score.stepScore, 80);
    expect(score.sedentaryScore, 100);
    expect(score.screenScore, 100);
    expect(score.totalScore, 92);
  });

  test('屏幕与久坐超出理想上限后按线性规则扣分', () {
    final score = calculateHealthScore(
      stepCount: 6000,
      sedentaryMinutes: 240,
      screenMinutes: 270,
    );

    expect(score.stepScore, 100);
    expect(score.sedentaryScore, 50);
    expect(score.screenScore, 75);
    expect(score.totalScore, 75);
  });
}
