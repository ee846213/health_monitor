import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/services/location_capture_service.dart';

void main() {
  test('单个位置点应生成最小位置摘要', () async {
    final service = LocationCaptureService(
      positionStreamFactory: ({
        Duration samplingPeriod = const Duration(seconds: 30),
      }) {
        return Stream<GeoPositionSample>.value(
          GeoPositionSample(
            capturedAt: DateTime(2026, 6, 9, 18),
            latitude: 31.2304,
            longitude: 121.4737,
            accuracy: 15,
          ),
        );
      },
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => GeoPermissionStatus.allowed,
      requestPermission: () async => GeoPermissionStatus.allowed,
    );

    final summary = await service.watchLocationSummaries().first;

    expect(summary.date.year, 2026);
    expect(summary.distanceMeters, 0);
    expect(summary.visitCount, 1);
  });

  test('连续位置点应累积距离', () async {
    final controller = StreamController<GeoPositionSample>();
    final service = LocationCaptureService(
      positionStreamFactory: ({
        Duration samplingPeriod = const Duration(seconds: 30),
      }) {
        return controller.stream;
      },
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => GeoPermissionStatus.allowed,
      requestPermission: () async => GeoPermissionStatus.allowed,
    );

    final future = service.watchLocationSummaries().take(2).toList();
    controller
      ..add(
        GeoPositionSample(
          capturedAt: DateTime(2026, 6, 9, 18),
          latitude: 31.2304,
          longitude: 121.4737,
          accuracy: 15,
        ),
      )
      ..add(
        GeoPositionSample(
          capturedAt: DateTime(2026, 6, 9, 18, 5),
          latitude: 31.2310,
          longitude: 121.4750,
          accuracy: 15,
        ),
      );

    final results = await future;
    final first = results.first;
    final second = results.last;

    expect(first.distanceMeters, 0);
    expect(second.distanceMeters, greaterThan(0));

    await controller.close();
  });

  test('定位服务关闭时应抛出可消费异常', () async {
    final service = LocationCaptureService(
      positionStreamFactory: ({
        Duration samplingPeriod = const Duration(seconds: 30),
      }) {
        return const Stream<GeoPositionSample>.empty();
      },
      isLocationServiceEnabled: () async => false,
      checkPermission: () async => GeoPermissionStatus.allowed,
      requestPermission: () async => GeoPermissionStatus.allowed,
    );

    await expectLater(
      service.watchLocationSummaries().first,
      throwsA(isA<LocationCaptureException>()),
    );
  });
}
