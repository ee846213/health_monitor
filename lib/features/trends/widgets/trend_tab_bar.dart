import 'package:flutter/material.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

const Color _tabActive = Color(0xFF5F775F);
const Color _tabActiveSurface = Color(0xFFE9F0E6);
const Color _tabInactiveSurface = Color(0xFFFFFFFF);
const Color _tabInactiveText = Color(0xFF5D645B);
const Color _tabLine = Color(0xFFDAD4CA);

class TrendTabBar extends StatelessWidget {
  const TrendTabBar({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });

  final TrendTab selectedTab;
  final ValueChanged<TrendTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: TrendTab.values.map((TrendTab tab) {
        final isSelected = tab == selectedTab;
        return InkWell(
          onTap: () => onSelected(tab),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _tabActiveSurface : _tabInactiveSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isSelected ? _tabActive : _tabLine),
            ),
            child: Text(
              _labelForTab(tab),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? _tabActive : _tabInactiveText,
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

String _labelForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '步数';
    case TrendTab.sedentary:
      return '久坐';
    case TrendTab.screen:
      return '屏幕';
    case TrendTab.environment:
      return '环境分';
  }
}
