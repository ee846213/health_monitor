class AndroidBackgroundCaptureConfig {
  const AndroidBackgroundCaptureConfig({
    required this.notificationTitle,
    required this.notificationBody,
    required this.enableMotion,
    required this.enableLocation,
    required this.enableNoise,
    required this.enableDigitalUsage,
    required this.sampleIntervalMinutes,
  });

  final String notificationTitle;
  final String notificationBody;
  final bool enableMotion;
  final bool enableLocation;
  final bool enableNoise;
  final bool enableDigitalUsage;
  final int sampleIntervalMinutes;

  Map<String, Object> channelPayload() {
    return <String, Object>{
      'notificationTitle': notificationTitle,
      'notificationBody': notificationBody,
      'enableMotion': enableMotion,
      'enableLocation': enableLocation,
      'enableNoise': enableNoise,
      'enableDigitalUsage': enableDigitalUsage,
      'sampleIntervalMinutes': sampleIntervalMinutes,
    };
  }
}
