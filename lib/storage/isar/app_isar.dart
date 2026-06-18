import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/storage/isar/collections/activity_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/ai_suggestion_cache_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_checkpoint_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_health_event_record.dart';
import 'package:health_monitor/storage/isar/collections/ambient_light_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/daily_metrics_record.dart';
import 'package:health_monitor/storage/isar/collections/location_summary_record.dart';
import 'package:health_monitor/storage/isar/collections/noise_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/notification_preference_record.dart';
import 'package:health_monitor/storage/isar/collections/posture_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/reminder_record_entity.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

const String appIsarName = 'health_monitor';

final List<CollectionSchema<dynamic>> appIsarSchemas =
    <CollectionSchema<dynamic>>[
  ActivitySampleRecordSchema,
  CaptureHealthEventRecordSchema,
  CaptureCheckpointRecordSchema,
  AmbientLightSampleRecordSchema,
  PostureSampleRecordSchema,
  LocationSummaryRecordSchema,
  NoiseSampleRecordSchema,
  UsageSummaryRecordSchema,
  DailyMetricsRecordSchema,
  NotificationPreferenceRecordSchema,
  AiSuggestionCacheRecordSchema,
  ReminderRecordEntitySchema,
];

final Map<String, Future<Isar>> _openingInstances = <String, Future<Isar>>{};

final appWritableBaseDirectoryProvider = FutureProvider<Directory>((
  Ref ref,
) async {
  try {
    return getApplicationSupportDirectory();
  } on MissingPluginException {
    // 单元测试或极早期引导阶段可能还拿不到平台目录插件。
    // 这里回退到系统临时目录，只作为兜底，正式运行时仍优先使用应用私有目录。
    return Directory.systemTemp;
  }
});

final appIsarDirectoryProvider = FutureProvider<String>((Ref ref) async {
  final baseDirectory =
      await ref.watch(appWritableBaseDirectoryProvider.future);
  // 首次启动时显式创建数据库目录，避免落到不存在或不可写的工作目录。
  return ensureAppIsarDirectory(baseDirectory);
});

final appIsarProvider = FutureProvider<Isar>((Ref ref) async {
  final directory = await ref.watch(appIsarDirectoryProvider.future);
  return openAppIsar(directory: directory);
});

Future<Isar> initializeAppIsar() async {
  final baseDirectory = await getApplicationSupportDirectory();
  final directory = await ensureAppIsarDirectory(baseDirectory);
  return openAppIsar(directory: directory);
}

Future<String> ensureAppIsarDirectory(Directory baseDirectory) async {
  final isarDirectory = Directory(
    '${baseDirectory.path}${Platform.pathSeparator}isar',
  );
  if (!await isarDirectory.exists()) {
    await isarDirectory.create(recursive: true);
  }
  return isarDirectory.path;
}

Future<Isar> openAppIsar({
  required String directory,
  String name = appIsarName,
}) {
  final existing = Isar.getInstance(name);
  if (existing != null && existing.isOpen) {
    return Future<Isar>.value(existing);
  }

  final key = '$directory::$name';
  return _openingInstances.putIfAbsent(
    key,
    () => _openAppIsarWithRetry(
      directory: directory,
      name: name,
    ),
  );
}

Future<Isar> _openAppIsarWithRetry({
  required String directory,
  required String name,
}) async {
  const retryDelays = <Duration>[
    Duration(milliseconds: 120),
    Duration(milliseconds: 360),
    Duration(milliseconds: 900),
  ];

  for (var attempt = 0;; attempt += 1) {
    final existing = Isar.getInstance(name);
    if (existing != null && existing.isOpen) {
      return existing;
    }

    try {
      return await Isar.open(
        appIsarSchemas,
        name: name,
        directory: directory,
      );
    } on IsarError catch (error) {
      final canRetry = error.toString().contains('MdbxError (11)') &&
          attempt < retryDelays.length;
      if (!canRetry) {
        rethrow;
      }
      await Future<void>.delayed(retryDelays[attempt]);
    }
  }
}
