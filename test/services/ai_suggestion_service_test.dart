import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/ai_suggestion_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/ai_suggestion_cache_repository.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('AI 建议服务遇到同日缓存时不会再触发 Dio 请求', () async {
    var requestTriggered = false;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestTriggered = true;
            handler.reject(
              DioException(
                requestOptions: options,
                error: '不应该触发网络请求',
              ),
            );
          },
        ),
      );
    final service = AiSuggestionService(
      cacheRepository: InMemoryAiSuggestionCacheRepository(
        initialCache: <String, String>{
          '2026-06-16': '今天先把晚饭后的 15 分钟留给散步。',
        },
      ),
      dio: dio,
      apiKey: 'test-key',
      model: 'gpt-5.5',
      fallbackBuilder: _fallbackBuilder,
    );

    final result = await service.buildDailyAdvice(
      referenceTime: DateTime(2026, 6, 16, 9),
      input: _ruleInput(),
      metrics: _metrics(),
      verdicts: const <RuleVerdict>[],
      environmentOverview: null,
    );

    expect(result.text, '今天先把晚饭后的 15 分钟留给散步。');
    expect(result.source, DailyAdviceSource.cache);
    expect(requestTriggered, isFalse);
  });

  test('AI 建议服务成功调用 Responses API 后会写入缓存', () async {
    var requestPath = '';
    Object? requestData;
    var authorizationHeader = '';
    final cacheRepository = InMemoryAiSuggestionCacheRepository();
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestPath = options.path;
            requestData = options.data;
            authorizationHeader =
                options.headers['Authorization'] as String? ?? '';
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                data: <String, dynamic>{
                  'output': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'type': 'message',
                      'content': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'type': 'output_text',
                          'text': '今天的节奏不错，晚饭后散步 15 分钟会更稳。',
                        },
                      ],
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
    final service = AiSuggestionService(
      cacheRepository: cacheRepository,
      dio: dio,
      apiKey: 'test-key',
      model: 'gpt-5.5',
      fallbackBuilder: _fallbackBuilder,
    );

    final result = await service.buildDailyAdvice(
      referenceTime: DateTime(2026, 6, 16, 9),
      input: _ruleInput(),
      metrics: _metrics(),
      verdicts: const <RuleVerdict>[
        RuleVerdict(
          dimension: 'activity',
          level: 'warning',
          summary: '活动偏少',
          detail: '午后可以再补一点步数。',
        ),
      ],
      environmentOverview: const EnvironmentOverview(
        headline: '环境整体平稳',
        detail: '当前环境读数整体平稳。',
        daytimeLightSummary: '舒适',
        nightNoiseSummary: '正常',
        primaryConcern: EnvironmentPrimaryConcern.none,
      ),
    );

    expect(result.text, '今天的节奏不错，晚饭后散步 15 分钟会更稳。');
    expect(result.source, DailyAdviceSource.llm);
    expect(requestPath, '/v1/responses');
    expect(authorizationHeader, 'Bearer test-key');
    expect(requestData, isA<Map<String, dynamic>>());
    expect(
      (requestData as Map<String, dynamic>)['model'],
      'gpt-5.5',
    );
    expect(
      (requestData as Map<String, dynamic>)['input'] as String,
      contains('建议要优先围绕步数、整体活动、久坐、屏幕使用、环境噪音这些可解释的日常指标。'),
    );
    expect(
      (requestData as Map<String, dynamic>)['input'] as String,
      contains('本次优先关注：步数、整体活动、久坐、屏幕使用、环境噪音。'),
    );
    expect(
      await cacheRepository.readForDate(DateTime(2026, 6, 16, 18)),
      '今天的节奏不错，晚饭后散步 15 分钟会更稳。',
    );
  });

  test('AI 建议服务在无密钥时降级为规则模板文案', () async {
    var requestTriggered = false;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestTriggered = true;
            handler.next(options);
          },
        ),
      );
    final service = AiSuggestionService(
      cacheRepository: InMemoryAiSuggestionCacheRepository(),
      dio: dio,
      apiKey: '',
      model: 'gpt-5.5',
      fallbackBuilder: _fallbackBuilder,
    );

    final result = await service.buildDailyAdvice(
      referenceTime: DateTime(2026, 6, 16, 9),
      input: _ruleInput(),
      metrics: _metrics(),
      verdicts: const <RuleVerdict>[],
      environmentOverview: null,
    );

    expect(result.text, '先按规则建议走，晚饭后补 15 分钟轻活动。');
    expect(result.source, DailyAdviceSource.fallback);
    expect(requestTriggered, isFalse);
  });
}

RuleInput _ruleInput() {
  return RuleInput(
    window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 16, 9)),
    activitySamples: const [],
    locationSummaries: const <LocationSummary>[],
    noiseSamples: const <NoiseSample>[],
    ambientLightSamples: const <AmbientLightSample>[],
    usageSummaries: const <DigitalUsageSummary>[],
    dailyMetricsList: const <DailyMetrics>[],
    missingDimensions: const <String>[],
  );
}

HealthInsightMetrics _metrics() {
  return const HealthInsightMetrics(
    stepCount: 4860,
    sedentaryMinutes: 96,
    screenMinutes: 148,
    outdoorMinutes: 18,
  );
}

String _fallbackBuilder(
  RuleInput input,
  HealthInsightMetrics metrics,
  List<RuleVerdict> verdicts,
  EnvironmentOverview? environmentOverview,
) {
  return '先按规则建议走，晚饭后补 15 分钟轻活动。';
}
