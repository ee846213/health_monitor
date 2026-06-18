import 'dart:ffi';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';
import 'package:isar/isar.dart';

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

  test('并发初始化同名数据库时应复用同一个打开 Future', () async {
    await _initializeIsarCoreForTest();
    final tempDirectory = await Directory.systemTemp.createTemp(
      'health_monitor_isar_singleton_test_',
    );
    final directory = await ensureAppIsarDirectory(tempDirectory);
    final name =
        'health_monitor_singleton_${DateTime.now().microsecondsSinceEpoch}';

    final instances = await Future.wait<Isar>(<Future<Isar>>[
      openAppIsar(directory: directory, name: name),
      openAppIsar(directory: directory, name: name),
      openAppIsar(directory: directory, name: name),
    ]);

    addTearDown(() async {
      if (instances.first.isOpen) {
        await instances.first.close();
      }
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    expect(identical(instances[0], instances[1]), isTrue);
    expect(identical(instances[1], instances[2]), isTrue);
  });

  test('Isar 数字生活摘要不应被同日空刷新覆盖', () async {
    await _initializeIsarCoreForTest();
    final tempDirectory = await Directory.systemTemp.createTemp(
      'health_monitor_usage_merge_test_',
    );
    final directory = await ensureAppIsarDirectory(tempDirectory);
    final name =
        'health_monitor_usage_${DateTime.now().microsecondsSinceEpoch}';
    final isar = await openAppIsar(directory: directory, name: name);
    final repository = IsarUsageSummaryRepository(Future<Isar>.value(isar));

    addTearDown(() async {
      if (isar.isOpen) {
        await isar.close();
      }
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    await repository.upsertSummary(
      DigitalUsageSummary(
        date: DateTime(2026, 6, 18),
        screenOnDuration: const Duration(minutes: 521),
        unlockCount: 42,
        viewCount: 60,
        nighttimeUsageDuration: const Duration(minutes: 38),
        focusSessionBreakCount: 8,
        topCategory: UsageCategory.social,
        source: DigitalUsageSource.androidUsageStats,
      ),
    );
    await repository.upsertSummary(
      DigitalUsageSummary(
        date: DateTime(2026, 6, 18),
        screenOnDuration: Duration.zero,
        unlockCount: 0,
        nighttimeUsageDuration: Duration.zero,
        focusSessionBreakCount: 0,
        topCategory: UsageCategory.unknown,
        source: DigitalUsageSource.androidUsageStats,
      ),
    );

    final result = await repository.getByDate(DateTime(2026, 6, 18));

    expect(result?.screenOnDuration, const Duration(minutes: 521));
    expect(result?.nighttimeUsageDuration, const Duration(minutes: 38));
    expect(result?.topCategory, UsageCategory.social);
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
  final libraryPath = '${libraryDirectory.path}${Platform.pathSeparator}windows'
      '${Platform.pathSeparator}isar.dll';
  await Isar.initializeIsarCore(
    libraries: <Abi, String>{
      Abi.windowsX64: libraryPath,
    },
  );
}
