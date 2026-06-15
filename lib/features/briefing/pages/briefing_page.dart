import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_icons.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

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
    final asyncViewModel = ref.watch(briefingViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: _surface,
        elevation: 0,
        toolbarHeight: 8,
      ),
      body: asyncViewModel.when(
        skipLoadingOnRefresh: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) =>
            const Center(child: Text('加载简报失败')),
        data: (BriefingViewModel viewModel) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PageHeader(viewModel: viewModel),
                const SizedBox(height: 14),
                _TimeRangeSegment(
                  selectedRange: viewModel.selectedRange,
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    final fade = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    );
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(fade);
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: child,
                      ),
                    );
                  },
                  child: _DailyReportCard(
                    key: ValueKey<String>(viewModel.selectedRange.name),
                    viewModel: viewModel,
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
  const _PageHeader({required this.viewModel});

  final BriefingViewModel viewModel;

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
              _StatusChip(text: viewModel.windowLabel),
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
  const _DailyReportCard({super.key, required this.viewModel});

  final BriefingViewModel viewModel;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _SectionPill(text: viewModel.windowLabel),
              const SizedBox(width: 8),
              _SectionPill(
                text: viewModel.hasRealData ? '真实数据' : '等待积累',
                backgroundColor:
                    viewModel.hasRealData ? _sageSoft : const Color(0xFFF2E8DD),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.summaryLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.summaryDetail,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          _MetricGrid(viewModel: viewModel),
          const SizedBox(height: 14),
          const _SectionHeading(title: '本段观察'),
          const SizedBox(height: 10),
          ...viewModel.verdicts.map(
            (RuleVerdict verdict) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SummaryCard(
                title: _sectionTitleForDimension(verdict.dimension),
                content: verdict.detail,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _SectionHeading(title: '下一步建议'),
          const SizedBox(height: 10),
          _SuggestionBanner(viewModel: viewModel),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.viewModel});

  final BriefingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _MetricTile(
            title: '步数',
            value: '${viewModel.metrics.stepCount}',
            unit: '步',
            backgroundColor: _sageSoft,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            title: '久坐',
            value: '${viewModel.metrics.sedentaryMinutes}',
            unit: '分钟',
            backgroundColor: _warmAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            title: '看屏',
            value: '${viewModel.metrics.screenMinutes}',
            unit: '分钟',
            backgroundColor: _mistAccent,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.unit,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final String unit;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            '$value $unit',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '本段',
            style: const TextStyle(fontSize: 11, color: _textMuted),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.content});

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

class _SuggestionBanner extends StatelessWidget {
  const _SuggestionBanner({required this.viewModel});

  final BriefingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final reminder =
        viewModel.reminders.isEmpty ? null : viewModel.reminders.first;

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
                Text(
                  reminder?.title ?? '当前时间段没有新增提醒',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reminder?.message ?? '继续保持当前节奏，数据会持续进入下一轮简报。',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _sectionTitleForDimension(String dimension) {
  switch (dimension) {
    case 'activity':
      return '活动节律总结';
    case 'posture':
      return '姿势风险总结';
    case 'usage':
      return '数字生活摘要';
    case 'environment':
      return '环境状态摘要';
    default:
      return '本段观察';
  }
}
