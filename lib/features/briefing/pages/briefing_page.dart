import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';

const _surface = Color(0xFFFFFDF8);
const _surfaceSoft = Color(0xFFF0ECE4);
const _sageSoft = Color(0xFFE6EEE8);
const _sageDeep = Color(0xFF5C7768);
const _textPrimary = Color(0xFF1F2320);
const _textSecondary = Color(0xFF505750);
const _textMuted = Color(0xFF7A8179);
const _line = Color(0xFFDDD8CF);

class BriefingPage extends ConsumerWidget {
  const BriefingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVm = ref.watch(overviewViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(title: const Text('今日简报', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)), backgroundColor: _surface, elevation: 0),
      body: asyncVm.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('加载失败')),
        data: (vm) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DailyReportCard(vm: vm),
          ]),
        ),
      ),
    );
  }
}

class _DailyReportCard extends StatelessWidget {
  const _DailyReportCard({required this.vm});
  final OverviewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('6 月 10 日 · 周三', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 4),
        const Text('今天整体还不错，下午久坐有点集中。', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.15)),
        const SizedBox(height: 14),
        _TagRow(tags: const [
          _TagItem(strong: '步数', weak: '正常'),
          _TagItem(strong: '久坐', weak: '偏高', bg: Color(0xFFFFF3E8)),
          _TagItem(strong: '看屏', weak: '稍多', bg: Color(0xFFEAF1F4)),
        ]),
        const SizedBox(height: 14),
        _SummaryCard(title: '活动节律总结', content: '上午节奏平稳，下午两段久坐连在了一起，晚饭后走动把状态稍微拉回来了一点。'),
        const SizedBox(height: 8),
        _SummaryCard(title: '数字生活摘要', content: '今晚解锁次数偏多，但大多是碎片时间里的短查看。'),
        const SizedBox(height: 8),
        _SummaryCard(title: '姿势或环境摘要', content: '今天大多在室内，低头用机主要集中在通勤后和睡前这两段时间。'),
        const SizedBox(height: 14),
        _SuggestionBanner(),
      ]),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tags});
  final List<_TagItem> tags;
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: tags.map((t) => _TagChip(strong: t.strong, weak: t.weak, bg: t.bg)).toList());
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.strong, required this.weak, this.bg = _surfaceSoft});
  final String strong, weak;
  final Color bg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(strong, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textSecondary)),
        const SizedBox(width: 4),
        Text(weak, style: const TextStyle(fontSize: 11, color: _textSecondary)),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.content});
  final String title, content;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 13, color: _textSecondary, height: 1.55)),
      ]),
    );
  }
}

class _SuggestionBanner extends StatelessWidget {
  const _SuggestionBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EBE2), borderRadius: BorderRadius.circular(22), border: Border.all(color: _line)),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: _sageSoft, borderRadius: BorderRadius.circular(19)), child: const Icon(Icons.notifications_active_rounded, size: 18, color: _sageDeep)),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('明天优先把下午第一段久坐打断。', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
            SizedBox(height: 6),
            Text('先起身走 3 分钟，比晚上补步数更容易做到。', style: TextStyle(fontSize: 12, color: _textSecondary, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _TagItem {
  final String strong, weak;
  final Color? bg;
  const _TagItem({required this.strong, required this.weak, this.bg});
}