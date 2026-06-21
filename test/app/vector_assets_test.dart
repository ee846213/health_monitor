import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/theme/app_vector_icons.dart';

void main() {
  test('设计稿所需 Material Symbols Rounded SVG 均存在且包含矢量路径', () {
    const icons = <String>[
      'arrow_forward',
      'article',
      'bedtime',
      'calendar_month',
      'chair_alt',
      'chevron_left',
      'chevron_right',
      'cloud_sync',
      'dark_mode',
      'devices',
      'directions_walk',
      'favorite',
      'graphic_eq',
      'home',
      'info',
      'keyboard_arrow_down',
      'link',
      'notifications',
      'person',
      'phone_iphone',
      'show_chart',
      'verified_user',
      'wb_sunny',
    ];

    for (final icon in icons) {
      for (final weight in <int>[400, 500]) {
        final file = File(AppVectorIcons.path(icon, weight: weight));
        expect(file.existsSync(), isTrue, reason: file.path);
        expect(file.readAsStringSync(), contains('<path'));
      }
    }
  });

  test('我的页面植物装饰为可用 SVG', () {
    final file = File(AppVectorIcons.profilePlant);
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('<svg'));
  });
}
