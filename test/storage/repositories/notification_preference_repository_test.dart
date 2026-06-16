import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/notification/notification_preference.dart';
import 'package:health_monitor/storage/isar/collections/notification_preference_record.dart';
import 'package:health_monitor/storage/repositories/notification_preference_repository.dart';
import 'package:isar/isar.dart';

void main() {
  test('勿扰设置仓储能写入并恢复时间窗口', () async {
    await _initializeIsarCoreForTest();
    final dir = await Directory.systemTemp.createTemp('pref-repo-test');
    final isar = await Isar.open(
      <CollectionSchema>[NotificationPreferenceRecordSchema],
      directory: dir.path,
      name: 'pref_repo_test',
    );
    final repository = IsarNotificationPreferenceRepository(isar);

    addTearDown(() async {
      await isar.close();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    await repository.save(
      const NotificationPreference(
        enabled: true,
        startHour: 22,
        startMinute: 30,
        endHour: 7,
        endMinute: 0,
      ),
    );

    final restored = await repository.read();
    expect(restored.enabled, isTrue);
    expect(restored.startHour, 22);
    expect(restored.endMinute, 0);
  });
}

Future<void> _initializeIsarCoreForTest() async {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null || localAppData.isEmpty) {
    throw StateError('缺少 LOCALAPPDATA，无法定位 Isar Windows 动态库。');
  }

  final hostedDirectory = Directory(
    '$localAppData\\Pub\\Cache\\hosted\\pub.dev',
  );
  final libraryDirectory =
      hostedDirectory.listSync().whereType<Directory>().firstWhere(
            (item) => item.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('isar_flutter_libs-'),
          );
  final libraryPath =
      '${libraryDirectory.path}${Platform.pathSeparator}windows${Platform.pathSeparator}isar.dll';
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{
      Abi.windowsX64: libraryPath,
    },
  );
}
