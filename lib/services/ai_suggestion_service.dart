import 'package:dio/dio.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/ai_suggestion_cache_repository.dart';

typedef DailyAdviceFallbackBuilder = String Function(
  RuleInput input,
  HealthInsightMetrics metrics,
  List<RuleVerdict> verdicts,
  EnvironmentOverview? environmentOverview,
);

class AiSuggestionService {
  AiSuggestionService({
    required AiSuggestionCacheRepository cacheRepository,
    required Dio dio,
    required String apiKey,
    required String model,
    required DailyAdviceFallbackBuilder fallbackBuilder,
  })  : _cacheRepository = cacheRepository,
        _dio = dio,
        _apiKey = apiKey.trim(),
        _model = model,
        _fallbackBuilder = fallbackBuilder;

  final AiSuggestionCacheRepository _cacheRepository;
  final Dio _dio;
  final String _apiKey;
  final String _model;
  final DailyAdviceFallbackBuilder _fallbackBuilder;

  Future<DailyAdviceBubble> buildDailyAdvice({
    required DateTime referenceTime,
    required RuleInput input,
    required HealthInsightMetrics metrics,
    required List<RuleVerdict> verdicts,
    required EnvironmentOverview? environmentOverview,
  }) async {
    final cached = await _cacheRepository.readForDate(referenceTime);
    if (cached != null && cached.isNotEmpty) {
      return DailyAdviceBubble(
        text: cached,
        source: DailyAdviceSource.cache,
      );
    }

    if (_apiKey.isEmpty ||
        !_hasEnoughContext(metrics, verdicts, environmentOverview)) {
      return _fallback(
        input: input,
        metrics: metrics,
        verdicts: verdicts,
        environmentOverview: environmentOverview,
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/responses',
        data: <String, dynamic>{
          'model': _model,
          'input': _buildPrompt(
            metrics: metrics,
            verdicts: verdicts,
            environmentOverview: environmentOverview,
          ),
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );
      final text = _extractOutputText(response.data);
      if (text == null || text.isEmpty) {
        return _fallback(
          input: input,
          metrics: metrics,
          verdicts: verdicts,
          environmentOverview: environmentOverview,
        );
      }

      await _cacheRepository.save(date: referenceTime, text: text);
      return DailyAdviceBubble(
        text: text,
        source: DailyAdviceSource.llm,
      );
    } on DioException {
      return _fallback(
        input: input,
        metrics: metrics,
        verdicts: verdicts,
        environmentOverview: environmentOverview,
      );
    }
  }

  DailyAdviceBubble _fallback({
    required RuleInput input,
    required HealthInsightMetrics metrics,
    required List<RuleVerdict> verdicts,
    required EnvironmentOverview? environmentOverview,
  }) {
    return DailyAdviceBubble(
      text: _fallbackBuilder(
        input,
        metrics,
        verdicts,
        environmentOverview,
      ),
      source: DailyAdviceSource.fallback,
    );
  }
}

bool _hasEnoughContext(
  HealthInsightMetrics metrics,
  List<RuleVerdict> verdicts,
  EnvironmentOverview? environmentOverview,
) {
  if (verdicts.isNotEmpty || environmentOverview != null) {
    return true;
  }

  return metrics.stepCount > 0 ||
      metrics.sedentaryMinutes > 0 ||
      metrics.screenMinutes > 0 ||
      metrics.outdoorMinutes > 0;
}

String _buildPrompt({
  required HealthInsightMetrics metrics,
  required List<RuleVerdict> verdicts,
  required EnvironmentOverview? environmentOverview,
}) {
  final focusTopics = _buildFocusTopics(
    metrics: metrics,
    verdicts: verdicts,
    environmentOverview: environmentOverview,
  );
  final verdictSummary = verdicts.isEmpty
      ? '暂无高优先级规则结论。'
      : verdicts
          .take(3)
          .map((RuleVerdict verdict) => '${verdict.summary}：${verdict.detail}')
          .join('；');
  final environmentLabel = environmentOverview == null
      ? '环境状态暂缺'
      : '${environmentOverview.daytimeLightSummary} / ${environmentOverview.nightNoiseSummary}';

  return [
    '你是健康监测 App 的每日建议助手。',
    '请只输出一句中文建议，语气亲切、生活化、非命令式，避免医学化表达。',
    '建议要优先围绕步数、整体活动、久坐、屏幕使用、环境噪音这些可解释的日常指标。',
    '若存在明显问题，优先点出 1 到 2 个最值得调整的维度；若整体平稳，也尽量从这些维度里给出保持建议。',
    '今日步数：${metrics.stepCount}。',
    '今日久坐分钟：${metrics.sedentaryMinutes}。',
    '今日屏幕使用分钟：${metrics.screenMinutes}。',
    '今日户外分钟：${metrics.outdoorMinutes}。',
    '当前环境：$environmentLabel。',
    '本次优先关注：${focusTopics.join('、')}。',
    '规则结论：$verdictSummary',
  ].join('\n');
}

List<String> _buildFocusTopics({
  required HealthInsightMetrics metrics,
  required List<RuleVerdict> verdicts,
  required EnvironmentOverview? environmentOverview,
}) {
  final topics = <String>[];

  void addTopic(String topic) {
    if (!topics.contains(topic)) {
      topics.add(topic);
    }
  }

  addTopic('步数');
  addTopic('整体活动');

  if (metrics.sedentaryMinutes >= 90) {
    addTopic('久坐');
  }
  if (metrics.screenMinutes >= 120) {
    addTopic('屏幕使用');
  }
  if (environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.highNoise ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed) {
    addTopic('环境噪音');
  }
  if (environmentOverview?.primaryConcern ==
          EnvironmentPrimaryConcern.lowLight ||
      environmentOverview?.primaryConcern == EnvironmentPrimaryConcern.mixed) {
    addTopic('白天光照');
  }

  for (final verdict in verdicts) {
    switch (verdict.dimension) {
      case 'activity':
        addTopic('整体活动');
      case 'usage':
        addTopic('屏幕使用');
      case 'environment':
      case 'noise':
        addTopic('环境噪音');
      default:
        break;
    }
  }

  if (!topics.contains('久坐')) {
    topics.add('久坐');
  }
  if (!topics.contains('屏幕使用')) {
    topics.add('屏幕使用');
  }
  if (!topics.contains('环境噪音')) {
    topics.add('环境噪音');
  }

  return topics.take(5).toList(growable: false);
}

String? _extractOutputText(Map<String, dynamic>? data) {
  if (data == null) {
    return null;
  }

  final output = data['output'];
  if (output is! List) {
    return null;
  }

  for (final item in output) {
    if (item is! Map<String, dynamic>) {
      continue;
    }
    final content = item['content'];
    if (content is! List) {
      continue;
    }
    for (final contentItem in content) {
      if (contentItem is! Map<String, dynamic>) {
        continue;
      }
      final text = contentItem['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }
    }
  }

  return null;
}
