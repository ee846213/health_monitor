import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/capability_matrix.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';

const _surface = Color(0xFFFFFDF8);
const _surfaceSoft = Color(0xFFF0ECE4);
const _textPrimary = Color(0xFF1F2320);
const _textSecondary = Color(0xFF505750);
const _textMuted = Color(0xFF7A8179);
const _line = Color(0xFFDDD8CF);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(title: const Text('我的', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: _textPrimary)), backgroundColor: _surface, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _MyRemindersCard(),
          const SizedBox(height: 20),
          _ReminderPrefsCard(),
          const SizedBox(height: 20),
          _PermissionStatusCard(),
        ]),
      ),
    );
  }
}

class _MyRemindersCard extends StatelessWidget {
  const _MyRemindersCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('我的提醒', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        SizedBox(height: 4),
        Text('今天提醒 2 次', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary)),
        SizedBox(height: 4),
        Text('最近一条是 15:00 的"起身走一走"。', style: TextStyle(fontSize: 13, color: _textSecondary)),
        SizedBox(height: 12),
        _ProfileRow(title: '进入提醒记录', subtitle: '查看时间、提醒文案和触发原因'),
      ]),
    );
  }
}

class _ReminderPrefsCard extends StatelessWidget {
  const _ReminderPrefsCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('提醒与显示偏好', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
        SizedBox(height: 10),
        _PrefRow(title: '久坐提醒强度', value: '轻柔'),
        SizedBox(height: 8),
        _PrefRow(title: '夜间减少提醒', value: '已开启'),
        SizedBox(height: 8),
        _PrefRow(title: '简报提醒时间', value: '20:30'),
        SizedBox(height: 8),
        _PrefRow(title: '显示扩展洞察', value: '显示重点项'),
      ]),
    );
  }
}

class _PermissionStatusCard extends StatelessWidget {
  const _PermissionStatusCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surfaceSoft, borderRadius: BorderRadius.circular(28), border: Border.all(color: _line)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('权限与感知状态', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary)),
        SizedBox(height: 10),
        _PermRow(title: '活动识别', subtitle: '用于步行、久坐和活动节律判断。', value: '已开启'),
        SizedBox(height: 8),
        _PermRow(title: '位置', subtitle: '只用于判断室内外和活动范围。', value: '已开启'),
        SizedBox(height: 8),
        _PermRow(title: '麦克风环境噪音', subtitle: '当前未开启，所以不会给环境相关建议。', value: '未开启'),
        SizedBox(height: 8),
        _PermRow(title: '数字生活习惯分析', subtitle: '用于判断看屏频率和碎片查看时段。', value: '已开启'),
      ]),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.title, required this.subtitle});
  final String title, subtitle;
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
        const Text('查看', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.title, required this.value});
  final String title, value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: _line)),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({required this.title, required this.subtitle, required this.value});
  final String title, subtitle, value;
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
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted)),
      ]),
    );
  }
}