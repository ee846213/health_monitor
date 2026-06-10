/// 日志级别。
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志条目。
class LogEntry {
  const LogEntry({required this.timestamp, required this.level, required this.tag, required this.message, this.data});

  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Map<String, Object?>? data;

  @override
  String toString() => '[$level] $tag: $message${data != null ? ' $data' : ''}';
}

/// 轻量级结构化日志器。
///
/// 内置内存缓冲（最近 256 条），支持通过 [entries] 读取历史日志。
/// 在调试页和诊断链路中不需要额外依赖。
class AppLogger {
  AppLogger._() : _entries = <LogEntry>[];

  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  final List<LogEntry> _entries;
  static const int _maxEntries = 256;

  /// 最近日志（按时间倒序）。
  List<LogEntry> get entries => List.unmodifiable(_entries.reversed);

  void log(LogLevel level, String tag, String message, [Map<String, Object?>? data]) {
    final entry = LogEntry(timestamp: DateTime.now(), level: level, tag: tag, message: message, data: data);
    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
  }

  void debug(String tag, String message, [Map<String, Object?>? data]) =>
      log(LogLevel.debug, tag, message, data);
  void info(String tag, String message, [Map<String, Object?>? data]) =>
      log(LogLevel.info, tag, message, data);
  void warning(String tag, String message, [Map<String, Object?>? data]) =>
      log(LogLevel.warning, tag, message, data);
  void error(String tag, String message, [Map<String, Object?>? data]) =>
      log(LogLevel.error, tag, message, data);

  /// 清空缓冲（用于测试或重置）。
  void clear() => _entries.clear();
}

/// 便捷方法，直接使用单例。
AppLogger logger() => AppLogger.instance;