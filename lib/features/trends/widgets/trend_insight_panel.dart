import 'package:flutter/material.dart';

const Color _insightSurface = Color(0xFFF1ECE3);
const Color _insightLine = Color(0xFFDAD4CA);
const Color _insightText = Color(0xFF1F2320);
const Color _insightMuted = Color(0xFF5D645B);

class TrendInsightPanel extends StatelessWidget {
  const TrendInsightPanel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _insightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _insightLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '智能洞察',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _insightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: _insightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
