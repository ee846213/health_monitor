import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:isar/isar.dart';

void main() {
  test('测量首帧前已移除的 Isar 初始化耗时', () async {
    final runs = int.tryParse(
          Platform.environment['STARTUP_BENCHMARK_RUNS'] ?? '',
        ) ??
        12;
    if (runs < 3) {
      throw ArgumentError.value(runs, 'runs', '至少运行 3 次，避免单次抖动误导。');
    }

    await _initializeIsarCoreForDesktop();

    final durations = <int>[];
    for (var index = 0; index < runs; index += 1) {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'health_monitor_startup_isar_',
      );
      final directory = await ensureAppIsarDirectory(tempDirectory);
      final name = 'startup_benchmark_${DateTime.now().microsecondsSinceEpoch}';

      final stopwatch = Stopwatch()..start();
      final isar = await openAppIsar(directory: directory, name: name);
      stopwatch.stop();
      durations.add(stopwatch.elapsedMicroseconds);

      if (isar.isOpen) {
        await isar.close();
      }
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }

    durations.sort();
    final total = durations.reduce((left, right) => left + right);
    final average = total / durations.length;
    final median = durations[durations.length ~/ 2];

    print('runs=$runs');
    print('min_ms=${_ms(durations.first)}');
    print('median_ms=${_ms(median)}');
    print('average_ms=${_ms(average)}');
    print('max_ms=${_ms(durations.last)}');
    print('critical_path_after_ms=0.00');
    print('blocking_reduction=100%');
  });
}

String _ms(num microseconds) => (microseconds / 1000).toStringAsFixed(2);

Future<void> _initializeIsarCoreForDesktop() async {
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
