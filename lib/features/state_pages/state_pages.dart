import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';

const Color _surface = Color(0xFFFFFDF8);
const Color _surfaceSoft = Color(0xFFF0ECE4);
const Color _sageSoft = Color(0xFFE6EEE8);
const Color _sageDeep = Color(0xFF5C7768);
const Color _dangerSoft = Color(0xFFC88976);
const Color _textPrimary = Color(0xFF1F2320);
const Color _textSecondary = Color(0xFF505750);
const Color _textMuted = Color(0xFF7A8179);
const Color _line = Color(0xFFDDD8CF);

class PermissionDeniedPage extends StatelessWidget {
  const PermissionDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const Text(
          '权限未开启',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        backgroundColor: _surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '权限未开启',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _dangerSoft,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '还不能稳定判断你的活动节律。',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '如果没有开启活动、位置或麦克风相关权限，应用仍能继续运行，但不会生成完整的久坐、姿势和环境相关建议。',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              _ActionBlock(
                children: <Widget>[
                  _ActionRow(
                    title: '返回我的页面',
                    subtitle: '先查看哪些能力未开启，再决定是否补开权限。',
                    actionLabel: '去查看',
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataInsufficientPage extends StatelessWidget {
  const DataInsufficientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const Text(
          '数据不足',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        backgroundColor: _surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _sageSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '今日样本仍在积累',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _sageDeep,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '今天的数据还不够，我们先不急着下结论。',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '继续正常使用手机，让活动、姿势、位置和看屏样本再积累一段时间，首页和简报会自动切换成真实结果。',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 16),
              _ActionBlock(
                children: <Widget>[
                  _ActionRow(
                    title: '查看采集调试页',
                    subtitle: '如果想确认采集链路是否正常，可以直接看实时样本和写入状态。',
                    actionLabel: '去诊断',
                    onTap: () => context.go('/diagnostics'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderExplanationPage extends StatelessWidget {
  const ReminderExplanationPage({super.key, required this.record});

  final ReminderRecord record;

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        '${record.triggeredAt.hour.toString().padLeft(2, '0')}:${record.triggeredAt.minute.toString().padLeft(2, '0')} · ${record.title}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            context.go('/reminders');
          },
        ),
        title: const Text(
          '提醒原因',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        backgroundColor: _surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.message,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 14),
              _ExplanationBlock(title: '触发依据', content: record.reasonSummary),
              const SizedBox(height: 8),
              const _ExplanationBlock(
                title: '为什么是现在',
                content: '这条提醒来自本轮规则计算中最靠前的提醒结论，页面会优先展示当前最值得处理的风险。',
              ),
              const SizedBox(height: 8),
              _ExplanationBlock(title: '建议动作', content: record.actionSuggestion),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationBlock extends StatelessWidget {
  const _ExplanationBlock({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(28),
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
