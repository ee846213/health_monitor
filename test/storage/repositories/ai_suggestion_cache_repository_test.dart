import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/storage/isar/collections/ai_suggestion_cache_record.dart';
import 'package:health_monitor/storage/repositories/ai_suggestion_cache_repository.dart';
import 'package:isar/isar.dart';

void main() {
  test('AI 建议缓存只会命中同一天的 dateKey', () async {
    await _initializeIsarCoreForTest();
    final dir = await Directory.systemTemp.createTemp('ai-cache-test');
    final isar = await Isar.open(
      <CollectionSchema>[AiSuggestionCacheRecordSchema],
      directory: dir.path,
      name: 'ai_cache_repo_test',
    );
    final repository = IsarAiSuggestionCacheRepository(isar);

    addTearDown(() async {
      await isar.close();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    await repository.save(
      date: DateTime(2026, 6, 16, 9, 0),
      text: '晚饭后散步 15 分钟会更稳。',
    );

    expect(
      await repository.readForDate(DateTime(2026, 6, 16, 21, 0)),
      '晚饭后散步 15 分钟会更稳。',
    );
    expect(
      await repository.readForDate(DateTime(2026, 6, 17, 8, 0)),
      isNull,
    );
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
