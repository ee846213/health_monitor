import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

const Color _bubbleSurface = Color(0xFF222A25);
const Color _bubbleTag = Color(0xFFBFD3C2);
const Color _bubbleText = Color(0xFFF7F6F1);
const Color _bubbleMuted = Color(0xFFD7D5CD);

class AiSuggestionBubble extends StatelessWidget {
  const AiSuggestionBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _bubbleSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const _AdviceSourceText(),
          ),
          const SizedBox(height: 12),
          const _AdviceBodyText(),
          const SizedBox(height: 10),
          const Text(
            '每日首次打开首页时刷新，同日重复进入会优先读取本地缓存。',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: _bubbleMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceSourceText extends ConsumerWidget {
  const _AdviceSourceText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(overviewAdviceSourceTextProvider);
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _bubbleTag,
      ),
    );
  }
}

class _AdviceBodyText extends ConsumerWidget {
  const _AdviceBodyText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(overviewAdviceBodyTextProvider);
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.7,
        color: _bubbleText,
      ),
    );
  }
}
