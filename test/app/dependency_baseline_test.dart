import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  test('阶段1依赖基线应包含后台任务与通知桥接所需包', () {
    expect(Workmanager, isNotNull);
    expect(AndroidFlutterLocalNotificationsPlugin, isNotNull);
  });
}
