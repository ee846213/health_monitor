import 'package:flutter/material.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

const Color _sheetSurface = Color(0xFFFFFBF5);
const Color _sheetLine = Color(0xFFDDD8CF);
const Color _sheetText = Color(0xFF1F2320);
const Color _sheetMuted = Color(0xFF5D645B);

class StepTrendDetailSheet extends StatelessWidget {
  const StepTrendDetailSheet({super.key, required this.card});

  final DashboardStepCard card;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '近 7 天步数',
      summary:
          '今日 ${card.currentSteps} 步，目标 ${card.goalSteps} 步，达成 ${card.achievementPercent}%。',
      rows: const <String>[
        '点击卡片后这里会承接过去 7 天的步数柱状图浮层。',
        '后续可以继续扩展为更完整的趋势回看。',
      ],
    );
  }
}

class SedentaryTimelineDetailSheet extends StatelessWidget {
  const SedentaryTimelineDetailSheet({super.key, required this.card});

  final DashboardSedentaryCard card;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '今日久坐分布',
      summary:
          '累计久坐 ${card.totalMinutes} 分钟，单次最长 ${card.longestSingleMinutes} 分钟。',
      rows: const <String>[
        '这里用于承接当天久坐时段时间轴。',
        '便于快速看出哪些时间段最容易连续久坐。',
      ],
    );
  }
}

class ScreenUsageDetailSheet extends StatelessWidget {
  const ScreenUsageDetailSheet({super.key, required this.card});

  final DashboardScreenCard card;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: '分时段使用分布',
      summary:
          '今日亮屏 ${card.totalMinutes} 分钟，较昨日 ${card.yesterdayDeltaMinutes.abs()} 分钟。',
      rows: const <String>[
        '这里用于承接分时段使用分布。',
        '可以帮助识别晚间刷屏和碎片化使用高峰。',
      ],
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.title,
    required this.summary,
    required this.rows,
  });

  final String title;
  final String summary;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: _sheetSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _sheetText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: _sheetMuted,
              ),
            ),
            const SizedBox(height: 14),
            ...rows.map(
              (String row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _sheetLine),
                  ),
                  child: Text(
                    row,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: _sheetText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
