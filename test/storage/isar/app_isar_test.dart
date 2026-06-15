import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';

void main() {
  test('appIsarDirectoryProvider 应基于可覆写目录创建专用子目录', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'health_monitor_isar_test_',
    );
    final container = ProviderContainer(
      overrides: <Override>[
        appWritableBaseDirectoryProvider.overrideWith(
          (Ref ref) async => tempDirectory,
        ),
      ],
    );

    addTearDown(() async {
      container.dispose();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final isarDirectoryPath = await container.read(
      appIsarDirectoryProvider.future,
    );
    final isarDirectory = Directory(isarDirectoryPath);

    expect(
      isarDirectoryPath,
      '${tempDirectory.path}${Platform.pathSeparator}isar',
    );
    expect(await isarDirectory.exists(), isTrue);
  });
}
