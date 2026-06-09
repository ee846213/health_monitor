class AndroidBackgroundCaptureHostStatus {
  const AndroidBackgroundCaptureHostStatus({
    required this.isRunning,
    required this.summary,
  });

  final bool isRunning;
  final String summary;

  factory AndroidBackgroundCaptureHostStatus.fromChannelPayload(
    Map<Object?, Object?> payload,
  ) {
    return AndroidBackgroundCaptureHostStatus(
      isRunning: payload['isRunning'] as bool? ?? false,
      summary: payload['summary'] as String? ?? 'Android 宿主尚未返回后台状态摘要。',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AndroidBackgroundCaptureHostStatus &&
        other.isRunning == isRunning &&
        other.summary == summary;
  }

  @override
  int get hashCode => Object.hash(isRunning, summary);
}
