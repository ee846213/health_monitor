class IosBackgroundCaptureHostStatus {
  const IosBackgroundCaptureHostStatus({
    required this.isRunning,
    required this.summary,
    this.lastErrorMessage,
    this.notificationBody,
  });

  final bool isRunning;
  final String summary;
  final String? lastErrorMessage;
  final String? notificationBody;

  factory IosBackgroundCaptureHostStatus.fromChannelPayload(
    Map<Object?, Object?> payload,
  ) {
    return IosBackgroundCaptureHostStatus(
      isRunning: payload['isRunning'] as bool? ?? false,
      summary: payload['summary'] as String? ?? 'iPhone 宿主尚未返回后台状态摘要。',
      lastErrorMessage: payload['lastErrorMessage'] as String?,
      notificationBody: payload['notificationBody'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is IosBackgroundCaptureHostStatus &&
        other.isRunning == isRunning &&
        other.summary == summary &&
        other.lastErrorMessage == lastErrorMessage &&
        other.notificationBody == notificationBody;
  }

  @override
  int get hashCode => Object.hash(isRunning, summary, lastErrorMessage, notificationBody);
}
