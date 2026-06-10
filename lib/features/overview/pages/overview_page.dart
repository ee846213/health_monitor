import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/app/theme/app_icons.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';

// Pencil 设计文件精确色值常量
const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);
const Color _warmSand = Color(0xFFF4E8DA);
const Color _mistBlue = Color(0xFFE0EBEE);
const Color _glass = Color(0xFFFFFDF0CC);

class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: asyncVm.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('加载失败')),
          data: (vm) => _OverviewBody(vm: vm),
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.vm});
  final OverviewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 44, 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _PageHeader(),
        const SizedBox(height: 24),
        _TodayStatusCard(vm: vm),
        if (vm.hasMissingDimensions) ...[
          const SizedBox(height: 12),
          _MissingBanner(vm: vm),
        ],
        const SizedBox(height: 24),
        _MoreObservationsCard(vm: vm),
        const SizedBox(height: 24),
        _TodaySuggestionsCard(vm: vm),
      ]),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('晚上好', style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)),
          SizedBox(height: 8),
          Text('看看你今天的状态，先从最重要的一件事开始。', style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.5)),
        ]),
        _TagChip(text: '我的感知'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({required this.vm});
  final OverviewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('今日状态', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 4),
        const Text('今天整体还不错，下午久坐有点集中。',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.15)),
        const SizedBox(height: 4),
        const Text('现在起身活动 3 分钟，会比补步数更有效。',
            style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.5)),
        const SizedBox(height: 16),
        _ConclusionBox(),
        const SizedBox(height: 10),
        _MetricsRow(),
      ]),
    );
  }
}

class _ConclusionBox extends StatelessWidget {
  const _ConclusionBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('结论先看', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _sageDeep)),
        SizedBox(height: 4),
        Text('今天不用加码。', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _sageDeep, height: 1.15)),
        SizedBox(height: 4),
        Text('先把下半天的节奏收回来，身体会更舒服。',
            style: TextStyle(fontSize: 13, color: _sageDeep, height: 1.5)),
        SizedBox(height: 10),
        Row(children: [
          _MiniTag(strong: '恢复', weak: '平稳'),
          SizedBox(width: 8),
          _MiniTag(strong: '久坐', weak: '偏集中'),
        ]),
      ]),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.strong, required this.weak});
  final String strong;
  final String weak;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(strong, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textSecondary)),
        const SizedBox(width: 4),
        Text(weak, style: const TextStyle(fontSize: 11, color: _textSecondary)),
      ]),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();
  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Expanded(child: _MetricCard(name: '步数', value: '6,240', unit: '步', status: '正常', bgColor: _surface)),
      SizedBox(width: 10),
      Expanded(child: _MetricCard(name: '久坐', value: '3.2', unit: '小时', status: '偏高', bgColor: _warmSand)),
      SizedBox(width: 10),
      Expanded(child: _MetricCard(name: '看屏', value: '2.8', unit: '小时', status: '稍多', bgColor: _mistBlue)),
    ]);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.name, required this.value, required this.unit, required this.status, required this.bgColor});
  final String name, value, unit, status;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(width: 6),
          Text(unit, style: const TextStyle(fontSize: 12, color: _textMuted)),
        ]),
        const SizedBox(height: 6),
        Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}

class _MissingBanner extends StatelessWidget {
  const _MissingBanner({required this.vm});
  final OverviewViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFD8A56E).withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
      child: Text('部分数据维度暂不可用（${vm.missingDimensions.join('、')}）',
          style: const TextStyle(fontSize: 12, color: Color(0xFFD8A56E))),
    );
  }
}

class _MoreObservationsCard extends StatelessWidget {
  const _MoreObservationsCard({required this.vm});
  final OverviewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('更多观察', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
        const SizedBox(height: 12),
        _ObsRow(title: '户外时间偏少', desc: '今天大多待在室内，换气和走动都偏少。'),
        const SizedBox(height: 8),
        _ObsRow(title: '今晚看手机偏频繁', desc: '多发生在任务切换和放松前后。'),
        const SizedBox(height: 8),
        _ObsRow(title: '低头用机时间偏长', desc: '如果今晚把手机抬高一点，颈肩会轻松很多。'),
      ]),
    );
  }
}

class _ObsRow extends StatelessWidget {
  const _ObsRow({required this.title, required this.desc});
  final String title, desc;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 12, color: _textSecondary, height: 1.5)),
          ]),
        ),
        const SizedBox(width: 8),
        const Text('查看', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}

class _TodaySuggestionsCard extends StatelessWidget {
  const _TodaySuggestionsCard({required this.vm});
  final OverviewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('今日建议', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
        SizedBox(height: 12),
        _SuggestionRow(
          iconBg: Color(0xFFE6EEE8),
          iconColor: Color(0xFF5C7768),
          mainText: '现在起身走 3 分钟。',
          subText: '先把下午这段久坐打断，不用额外安排运动。',
        ),
        SizedBox(height: 8),
        _SuggestionRow(
          iconBg: Color(0xFFE7EFE8),
          iconColor: Color(0xFF4A6B52),
          mainText: '下次提醒延后 30 分钟。',
          subText: '等你忙完这一段，再出现会更不打扰。',
        ),
      ]),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.iconBg, required this.iconColor, required this.mainText, required this.subText});
  final Color iconBg, iconColor;
  final String mainText, subText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line)),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(19)),
          child: Icon(AppIcons.bellRing, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mainText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
            const SizedBox(height: 6),
            Text(subText, style: const TextStyle(fontSize: 12, color: _textSecondary, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}