class IosBackgroundCaptureConfig {
  const IosBackgroundCaptureConfig({
    required this.statusTitle,
    required this.statusBody,
    required this.enableMotion,
    required this.enableLocation,
    required this.enableDigitalUsage,
    required this.backgroundRefreshIntervalMinutes,
  });

  final String statusTitle;
  final String statusBody;
  final bool enableMotion;
  final bool enableLocation;
  final bool enableDigitalUsage;
  final int backgroundRefreshIntervalMinutes;

  Map<String, Object> channelPayload() {
    return <String, Object>{
      'statusTitle': statusTitle,
      'statusBody': statusBody,
      'enableMotion': enableMotion,
      'enableLocation': enableLocation,
      'enableDigitalUsage': enableDigitalUsage,
      'backgroundRefreshIntervalMinutes': backgroundRefreshIntervalMinutes,
    };
  }
}
