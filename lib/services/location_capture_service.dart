import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:health_monitor/domain/location/location_summary.dart';

typedef GeoPositionStreamFactory = Stream<GeoPositionSample> Function({
  Duration samplingPeriod,
});
typedef GeoServiceEnabledChecker = Future<bool> Function();
typedef GeoPermissionChecker = Future<GeoPermissionStatus> Function();
typedef GeoPermissionRequester = Future<GeoPermissionStatus> Function();

enum GeoPermissionStatus {
  allowed,
  denied,
  restricted,
}

class GeoPositionSample {
  const GeoPositionSample({
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final DateTime capturedAt;
  final double latitude;
  final double longitude;
  final double accuracy;
}

class LocationCaptureException implements Exception {
  const LocationCaptureException(this.message);

  final String message;

  @override
  String toString() => 'LocationCaptureException($message)';
}

class LocationCaptureService {
  LocationCaptureService({
    GeoPositionStreamFactory? positionStreamFactory,
    GeoServiceEnabledChecker? isLocationServiceEnabled,
    GeoPermissionChecker? checkPermission,
    GeoPermissionRequester? requestPermission,
  }) : _positionStreamFactory = positionStreamFactory ?? _defaultPositionStreamFactory,
       _isLocationServiceEnabled = isLocationServiceEnabled ?? _defaultIsLocationServiceEnabled,
       _checkPermission = checkPermission ?? _defaultCheckPermission,
       _requestPermission = requestPermission ?? _defaultRequestPermission;

  final GeoPositionStreamFactory _positionStreamFactory;
  final GeoServiceEnabledChecker _isLocationServiceEnabled;
  final GeoPermissionChecker _checkPermission;
  final GeoPermissionRequester _requestPermission;

  Stream<LocationSummary> watchLocationSummaries({
    Duration samplingPeriod = const Duration(seconds: 30),
  }) async* {
    final bool enabled = await _isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationCaptureException('定位服务未开启');
    }

    GeoPermissionStatus permission = await _checkPermission();
    if (permission != GeoPermissionStatus.allowed) {
      permission = await _requestPermission();
    }
    if (permission != GeoPermissionStatus.allowed) {
      throw const LocationCaptureException('定位权限不可用');
    }

    GeoPositionSample? previous;
    double totalDistance = 0;

    await for (final GeoPositionSample current
        in _positionStreamFactory(samplingPeriod: samplingPeriod)) {
      if (previous != null) {
        totalDistance += _distanceMeters(previous, current);
      }

      yield LocationSummary(
        date: current.capturedAt,
        distanceMeters: totalDistance,
        outdoorDuration: const Duration(minutes: 0),
        visitCount: 1,
        commuteCount: 0,
      );

      previous = current;
    }
  }

  static Stream<GeoPositionSample> _defaultPositionStreamFactory({
    Duration samplingPeriod = const Duration(seconds: 30),
  }) {
    const settings = geolocator.LocationSettings(
      accuracy: geolocator.LocationAccuracy.medium,
      distanceFilter: 10,
    );

    return geolocator.Geolocator.getPositionStream(
      locationSettings: settings,
    ).map((geolocator.Position position) {
      return GeoPositionSample(
        capturedAt: position.timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    });
  }

  static Future<bool> _defaultIsLocationServiceEnabled() {
    return geolocator.Geolocator.isLocationServiceEnabled();
  }

  static Future<GeoPermissionStatus> _defaultCheckPermission() async {
    return _mapPermission(await geolocator.Geolocator.checkPermission());
  }

  static Future<GeoPermissionStatus> _defaultRequestPermission() async {
    return _mapPermission(await geolocator.Geolocator.requestPermission());
  }

  static GeoPermissionStatus _mapPermission(geolocator.LocationPermission permission) {
    switch (permission) {
      case geolocator.LocationPermission.always:
      case geolocator.LocationPermission.whileInUse:
        return GeoPermissionStatus.allowed;
      case geolocator.LocationPermission.denied:
        return GeoPermissionStatus.denied;
      case geolocator.LocationPermission.deniedForever:
      case geolocator.LocationPermission.unableToDetermine:
        return GeoPermissionStatus.restricted;
    }
  }

  // 这里用近似球面距离已经足够支撑“最小真实闭环”验证，
  // 当前目标是确认真实位置流能稳定进入领域摘要，而不是立即做高精度轨迹分析。
  double _distanceMeters(GeoPositionSample start, GeoPositionSample end) {
    const earthRadius = 6371000.0;
    final startLat = _toRadians(start.latitude);
    final endLat = _toRadians(end.latitude);
    final deltaLat = _toRadians(end.latitude - start.latitude);
    final deltaLng = _toRadians(end.longitude - start.longitude);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(startLat) *
            math.cos(endLat) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180;
}
