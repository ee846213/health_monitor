import 'package:flutter/material.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';

const _surface = Color(0xFFFFFDF8);
const _surfaceSoft = Color(0xFFF0ECE4);
const _sageSoft = Color(0xFFE6EEE8);
const _sageDeep = Color(0xFF5C7768);
const _dangerSoft = Color(0xFFC88976);
const _textPrimary = Color(0xFF1F2320);
const _textSecondary = Color(0xFF505750);
const _textMuted = Color(0xFF7A8179);
const _line = Color(0xFFDDD8CF);

/// 权限未开启页面。
class PermissionDeniedPage extends StatelessWidget {
  const PermissionDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(title: const Text('权限未开启', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)), backgroundColor: _surface, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('权限未开启', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dangerSoft)),
            SizedBox(height: 4),
            Text('还不能判断你的活动节律。', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.15)),
            SizedBox(height: 8),
            Text('如果不开启活动识别，我们仍能展示基础使用情况，但不会给出久坐、走路和姿势相关建议。', style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.55)),
            SizedBox(height: 18),
            _AbilityCard(),
          ]),
        ),
      ),
    );
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(children: [
        _ActionRow(title: '开启后能获得', subtitle: '久坐提醒、姿势风险和活动节律总结。', action: '去开启'),
        SizedBox(height: 10),
        _ActionRow(title: '不开启仍可使用', subtitle: '基础使用情况、看屏频率和时间摘要仍会正常展示。', action: '继续使用'),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title, required this.subtitle, required this.action});
  final String title, subtitle, action;
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
            Text(subtitle, style: const TextStyle(fontSize: 12, color: _textSecondary, height: 1.5)),
          ]),
        ),
        Text(action, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}

/// 数据不足空态页面。
class DataInsufficientPage extends StatelessWidget {
  const DataInsufficientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(title: const Text('数据不足', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)), backgroundColor: _surface, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _EmptyGraphic(),
            SizedBox(height: 16),
            Text('今天的数据还不够，我们先不急着下结论。', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.15)),
            SizedBox(height: 8),
            Text('再多用一段时间，等活动、姿势和看屏节律稳定下来，我们会给出更可靠的今日简报。', style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.55)),
            SizedBox(height: 16),
            _WaitSuggestions(),
          ]),
        ),
      ),
    );
  }
}

class _EmptyGraphic extends StatelessWidget {
  const _EmptyGraphic();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(color: _sageSoft, borderRadius: BorderRadius.circular(24)),
      alignment: Alignment.center,
      child: const Text('今日样本仍在积累', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _sageDeep)),
    );
  }
}

class _WaitSuggestions extends StatelessWidget {
  const _WaitSuggestions();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(children: [
        _ActionRow(title: '继续正常使用', subtitle: '像平时一样使用手机，数据会在后台自动积累。', action: '知道了'),
        SizedBox(height: 10),
        _ActionRow(title: '想更快形成简报', subtitle: '保持 App 在前台或在后台运行，采集样本会更快稳定。', action: '了解'),
      ]),
    );
  }
}

/// 提醒原因解释页面。
class ReminderExplanationPage extends StatelessWidget {
  const ReminderExplanationPage({super.key, required this.record});

  final ReminderRecord record;

  @override
  Widget build(BuildContext context) {
    final timeLabel = '${record.triggeredAt.hour.toString().padLeft(2, '0')}:${record.triggeredAt.minute.toString().padLeft(2, '0')} · ${record.title}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(title: const Text('提醒原因', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)), backgroundColor: _surface, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(timeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
            const SizedBox(height: 4),
            Text(record.message, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary, height: 1.18)),
            const SizedBox(height: 14),
            _ExplanationBlock(title: '触发依据', content: record.reasonSummary),
            const SizedBox(height: 8),
            _ExplanationBlock(title: '为什么是现在', content: '这个时间点继续坐下去，比晚点补走几步更容易带来肩颈和腰背的不适。'),
            const SizedBox(height: 8),
            _ExplanationBlock(title: '为什么给这条建议', content: record.actionSuggestion),
          ]),
        ),
      ),
    );
  }
}

class _ExplanationBlock extends StatelessWidget {
  const _ExplanationBlock({required this.title, required this.content});
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