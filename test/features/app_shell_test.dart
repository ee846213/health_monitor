import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/app.dart';

void main() {
  testWidgets('应用壳应渲染今日概览标题', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthMonitorApp());
    await tester.pumpAndSettle();

    expect(find.text('今日概览'), findsOneWidget);
  });

  testWidgets('应用壳应提供采集调试入口', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthMonitorApp());
    await tester.pumpAndSettle();

    expect(find.text('打开采集调试'), findsOneWidget);
  });
}
