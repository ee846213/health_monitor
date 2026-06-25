import 'package:flutter/material.dart';
import 'package:health_monitor/app/theme/app_theme_extension.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';

Future<void> showRhythmNodeDetailSheet(
  BuildContext context,
  DailyRhythmNode node,
) {
  final tokens = context.healthTheme;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${_time(node.time)} · ${node.title}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(node.value, style: tokens.sectionTitleStyle),
              const SizedBox(height: 12),
              Text(node.reason, style: tokens.bodyStyle),
              const SizedBox(height: 12),
              Text(node.suggestion, style: tokens.bodyStyle),
            ],
          ),
        ),
      );
    },
  );
}

String _time(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
