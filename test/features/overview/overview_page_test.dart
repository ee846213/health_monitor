import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';

void main() {
  testWidgets('首页应正常渲染 OverviewPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OverviewPage()),
      ),
    );
    // FutureProvider 在测试中同步解决，故直接到 data 分支。
    await tester.pump();
    expect(find.byType(OverviewPage), findsOneWidget);
  });
}