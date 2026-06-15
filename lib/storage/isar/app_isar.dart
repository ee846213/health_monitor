import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/storage/isar/collections/activity_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_checkpoint_record.dart';
import 'package:health_monitor/storage/isar/collections/capture_health_event_record.dart';
import 'package:health_monitor/storage/isar/collections/ambient_light_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/daily_metrics_record.dart';
import 'package:health_monitor/storage/isar/collections/location_summary_record.dart';
import 'package:health_monitor/storage/isar/collections/noise_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/posture_sample_record.dart';
import 'package:health_monitor/storage/isar/collections/reminder_record_entity.dart';
import 'package:health_monitor/storage/isar/collections/usage_summary_record.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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
  final isarDirectory = Directory(
    '${baseDirectory.path}${Platform.pathSeparator}isar',
  );

  if (!await isarDirectory.exists()) {
    // 首次启动时需要显式创建数据库目录。
    // 这样可以避免 Isar 在移动端落到不存在或不可写的当前工作目录。
    await isarDirectory.create(recursive: true);
  }

  return isarDirectory.path;
});

final appIsarProvider = FutureProvider<Isar>((Ref ref) async {
  final directory = await ref.watch(appIsarDirectoryProvider.future);
  final isar = await Isar.open(
    <CollectionSchema>[
      ActivitySampleRecordSchema,
      CaptureHealthEventRecordSchema,
      CaptureCheckpointRecordSchema,
      AmbientLightSampleRecordSchema,
      PostureSampleRecordSchema,
      LocationSummaryRecordSchema,
      NoiseSampleRecordSchema,
      UsageSummaryRecordSchema,
      DailyMetricsRecordSchema,
      ReminderRecordEntitySchema,
    ],
    name: 'health_monitor',
    directory: directory,
  );
  ref.onDispose(() async {
    await isar.close();
  });
  return isar;
});
