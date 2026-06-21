import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/app/theme/health_motion_tokens.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';

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
    final motion = context.healthMotion;
    final tokens = context.healthTheme;
    final selectedIndex = TrendTab.values.indexOf(selectedTab);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            alignment: Alignment(
              -1 + selectedIndex * (2 / (TrendTab.values.length - 1)),
              0,
            ),
            duration: context.motionDuration(motion.base),
            curve: motion.standardCurve,
            child: FractionallySizedBox(
              widthFactor: 1 / TrendTab.values.length,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: tokens.sageSoft,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: tokens.sage),
                ),
              ),
            ),
          ),
          Row(
            children: TrendTab.values.map((TrendTab tab) {
              final isSelected = tab == selectedTab;
              return Expanded(
                child: InkWell(
                  key: ValueKey<String>('trend-tab-${tab.name}'),
                  onTap: () => onSelected(tab),
                  borderRadius: BorderRadius.circular(18),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: context.motionDuration(motion.fast),
                      curve: motion.standardCurve,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? tokens.sage : tokens.textSecondary,
                      ),
                      child: Text(_labelForTab(tab)),
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

String _labelForTab(TrendTab tab) {
  switch (tab) {
    case TrendTab.steps:
      return '活动';
    case TrendTab.sedentary:
      return '姿势';
    case TrendTab.screen:
      return '屏幕';
    case TrendTab.environment:
      return '噪音';
  }
}
