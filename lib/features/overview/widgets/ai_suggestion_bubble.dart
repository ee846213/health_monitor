import 'package:flutter/material.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

const Color _bubbleSurface = Color(0xFF222A25);
const Color _bubbleTag = Color(0xFFBFD3C2);
const Color _bubbleText = Color(0xFFF7F6F1);
const Color _bubbleMuted = Color(0xFFD7D5CD);

class AiSuggestionBubble extends StatelessWidget {
  const AiSuggestionBubble({
    super.key,
    required this.bubble,
  });

  final DailyAdviceBubble bubble;

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
            child: Text(
              'AI 建议 · ${_sourceLabel(bubble.source)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _bubbleTag,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bubble.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: _bubbleText,
            ),
          ),
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

String _sourceLabel(DailyAdviceSource source) {
  switch (source) {
    case DailyAdviceSource.llm:
      return '直连';
    case DailyAdviceSource.cache:
      return '缓存';
    case DailyAdviceSource.fallback:
      return '降级';
  }
}
