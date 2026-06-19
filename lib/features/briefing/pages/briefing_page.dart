import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_icons.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/widgets/metric_detail_sheets.dart';

const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _sageLight = Color(0xFFF5F8F2);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);
const Color _warmAccent = Color(0xFFF4E8DA);
const Color _mistAccent = Color(0xFFE0EBEE);
const Color _shadow = Color(0x12000000);

class BriefingPage extends ConsumerWidget {
  const BriefingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRange = ref.watch(briefingPageRangeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: _surface,
        elevation: 0,
        toolbarHeight: 8,
      ),
      body: asyncRange.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) =>
            const Center(child: Text('加载简报失败')),
        data: (BriefingTimeRange selectedRange) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const HealthStaggeredEntrance(
                  index: 0,
                  child: _PageHeader(),
                ),
                const SizedBox(height: 14),
                HealthStaggeredEntrance(
                  index: 1,
                  child: _TimeRangeSegment(
                    selectedRange: selectedRange,
                  ),
                ),
                const SizedBox(height: 14),
                HealthStaggeredEntrance(
                  index: 2,
                  child: HealthAnimatedSwitcher(
                    duration: context.healthMotion.base,
                    child: _DailyReportCard(
                      key: ValueKey<String>(selectedRange.name),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _surface,
            _sageLight,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: _shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _sageSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  AppIcons.briefing,
                  size: 18,
                  color: _sageDeep,
                ),
              ),
              const Spacer(),
              const _WindowLabelChip(),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '简报',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '先看时间段，再看本段最值得注意的变化。',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowLabelChip extends ConsumerWidget {
  const _WindowLabelChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StatusChip(text: ref.watch(briefingWindowLabelProvider));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
        ),
      ),
    );
  }
}

class _TimeRangeSegment extends ConsumerWidget {
  const _TimeRangeSegment({required this.selectedRange});

  final BriefingTimeRange selectedRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<BriefingTimeRange>(
      segments: BriefingTimeRange.values
          .map(
            (BriefingTimeRange range) => ButtonSegment<BriefingTimeRange>(
              value: range,
              label: Text(range.label),
            ),
          )
          .toList(growable: false),
      selected: <BriefingTimeRange>{selectedRange},
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _sageSoft;
          }
          return _surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _sageDeep;
          }
          return _textMuted;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: _line),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onSelectionChanged: (Set<BriefingTimeRange> selection) {
        if (selection.isEmpty) {
          return;
        }
        ref.read(briefingTimeRangeProvider.notifier).state = selection.first;
      },
    );
  }
}

class _DailyReportCard extends StatelessWidget {
  const _DailyReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: _shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ReportStatusRow(),
          SizedBox(height: 8),
          _ReportHeadline(),
          SizedBox(height: 8),
          _ReportSupportingDetail(),
          SizedBox(height: 14),
          _MetricGrid(),
          SizedBox(height: 14),
          _SectionHeading(title: '建议'),
          SizedBox(height: 10),
          _SuggestionBanner(),
          _QualityNoteSection(),
        ],
      ),
    );
  }
}

class _ReportStatusRow extends ConsumerWidget {
  const _ReportStatusRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowLabel = ref.watch(briefingWindowLabelProvider);
    final hasRealData = ref.watch(briefingHasRealDataProvider);
    return Row(
      children: <Widget>[
        _SectionPill(text: windowLabel),
        const SizedBox(width: 8),
        _SectionPill(
          text: hasRealData ? '真实数据' : '等待积累',
          backgroundColor: hasRealData ? _sageSoft : const Color(0xFFF2E8DD),
        ),
      ],
    );
  }
}

class _ReportHeadline extends ConsumerWidget {
  const _ReportHeadline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(briefingHeadlineProvider),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        height: 1.1,
      ),
    );
  }
}

class _ReportSupportingDetail extends ConsumerWidget {
  const _ReportSupportingDetail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(briefingSupportingDetailProvider),
      style: const TextStyle(
        fontSize: 13,
        color: _textSecondary,
        height: 1.6,
      ),
    );
  }
}

class _MetricGrid extends ConsumerWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(briefingMetricsProvider);
    final selectedRange = ref.watch(briefingTimeRangeProvider);
    if (metrics.length < 3) {
      return const SizedBox.shrink();
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricTile(
            key: const Key('briefing-step-card'),
            title: metrics[0].label,
            value: metrics[0].value,
            unit: metrics[0].unit,
            backgroundColor: _sageSoft,
            onTap: () => _showStepDetailSheet(
              context,
              selectedRange,
              int.tryParse(metrics[0].value) ?? 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            key: const Key('briefing-sedentary-card'),
            title: metrics[1].label,
            value: metrics[1].value,
            unit: metrics[1].unit,
            backgroundColor: _warmAccent,
            onTap: () => _showSedentaryDetailSheet(
              context,
              selectedRange,
              int.tryParse(metrics[1].value) ?? 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            key: const Key('briefing-screen-card'),
            title: metrics[2].label,
            value: metrics[2].value,
            unit: metrics[2].unit,
            backgroundColor: _mistAccent,
            onTap: () => _showScreenDetailSheet(
              context,
              selectedRange,
              int.tryParse(metrics[2].value) ?? 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String value;
  final String unit;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$value $unit',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '本段',
                style: TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showStepDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int steps,
) {
  final goalSteps = range == BriefingTimeRange.recent7Days ? 42000 : 6000;
  final achievementPercent =
      goalSteps == 0 ? 0 : (steps / goalSteps * 100).round();
  return showMetricDetailSheet(
    context,
    StepTrendDetailSheet(
      card: DashboardStepCard(
        currentSteps: steps,
        goalSteps: goalSteps,
        achievementPercent: achievementPercent,
      ),
      detailProvider: briefingStepDetailProvider(range),
      summary: '${range.label}累计 $steps 步。',
      progressLabel: switch (range) {
        BriefingTimeRange.today => '今日进度',
        BriefingTimeRange.yesterday => '昨日进度',
        BriefingTimeRange.recent7Days => '7 日目标进度',
      },
    ),
  );
}

Future<void> _showSedentaryDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int minutes,
) {
  return showMetricDetailSheet(
    context,
    SedentaryTimelineDetailSheet(
      card: DashboardSedentaryCard(
        totalMinutes: minutes,
        longestSingleMinutes: 0,
      ),
      detailProvider: briefingSedentaryDetailProvider(range),
      title: '${range.label}久坐分布',
      summary: '${range.label}累计久坐 $minutes 分钟。',
    ),
  );
}

Future<void> _showScreenDetailSheet(
  BuildContext context,
  BriefingTimeRange range,
  int minutes,
) {
  return showMetricDetailSheet(
    context,
    ScreenUsageDetailSheet(
      card: DashboardScreenCard(
        totalMinutes: minutes,
        yesterdayDeltaMinutes: 0,
        changeDirection: DashboardChangeDirection.steady,
      ),
      detailProvider: briefingScreenDetailProvider(range),
      title: '${range.label}分时段使用分布',
      summary: '${range.label}亮屏 $minutes 分钟。',
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _sageDeep,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({
    required this.text,
    this.backgroundColor = _surfaceSoft,
  });

  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textSecondary,
        ),
      ),
    );
  }
}

class _SuggestionBanner extends ConsumerWidget {
  const _SuggestionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(briefingSuggestionsProvider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EBE2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _sageSoft,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(AppIcons.bellRing, size: 18, color: _sageDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final suggestion in suggestions) ...<Widget>[
                  Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (suggestion != suggestions.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityNoteSection extends ConsumerWidget {
  const _QualityNoteSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualityNote = ref.watch(briefingQualityNoteProvider);
    if (qualityNote == null || qualityNote.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 14),
        const _SectionHeading(title: '质量说明'),
        const SizedBox(height: 10),
        _SummaryCard(
          title: '数据质量',
          content: qualityNote,
        ),
      ],
    );
  }
}
