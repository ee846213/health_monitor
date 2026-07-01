# 2026-07-01 启动耗时优化记录

## 背景

本轮目标是降低 Flutter 首帧前的同步等待，让用户更早看到应用壳和首屏加载态。Flutter 官方性能资料建议将耗时工作从首帧关键路径中移出，并用 profile/DevTools 观察启动与帧耗时：

- [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter performance profiling](https://docs.flutter.dev/perf/ui-performance)

## 优化前问题

`lib/main.dart` 在 `runApp` 前执行：

```dart
final isar = await initializeAppIsar();
```

这意味着应用必须等 `getApplicationSupportDirectory`、数据库目录创建、`Isar.open` 全部完成后才挂载 UI。即使首页最终会显示加载态，用户也要先等待数据库初始化。

同时，根组件 `initState` 会立即触发后台采集、使用统计、原生风险事件同步。它们虽然是异步任务，但 provider 构建和平台调用会进入首帧调度窗口。

## 本次改动

- `lib/main.dart` 不再预先打开 Isar，直接挂载 `ProviderScope` 与 `HealthMonitorApp`。
- Isar 初始化回到已有的 `appIsarProvider` 异步链路，由仓库层的 `_openingInstances` 继续保证同名数据库并发打开时复用同一个 Future。
- `lib/app/app.dart` 将启动同步任务挪到 `addPostFrameCallback`，让首帧先完成应用壳渲染，再开始后台采集与同步。
- 新增 `test/app/startup_performance_test.dart`：用一个永不完成的 `appIsarProvider` 验证首帧仍能渲染底部导航与加载态。
- 新增 `.tooling/measure_startup_isar_test.dart`：用于复测被移出首帧前路径的 Isar 初始化耗时。

## 本机量化结果

运行环境：

- Windows 本机
- Flutter 3.44.0 stable
- Dart 3.12.0
- 命令：`$env:STARTUP_BENCHMARK_RUNS='12'; flutter test .tooling\measure_startup_isar_test.dart --plain-name "测量首帧前已移除的 Isar 初始化耗时"`

结果：

| 指标 | 数值 |
| --- | ---: |
| 运行次数 | 12 |
| 最小值 | 22.84 ms |
| 中位数 | 25.11 ms |
| 平均值 | 30.88 ms |
| 最大值 | 53.04 ms |
| 优化后首帧前 Isar 阻塞 | 0.00 ms |
| 该阻塞项下降 | 100% |

结论：本轮把首帧前数据库初始化阻塞从关键路径中移除。按本机中位数计算，首帧前路径减少约 **25.11 ms**；按平均值计算减少约 **30.88 ms**。这不是整机冷启动总耗时的完整下降值，因为原生进程启动、Flutter engine 初始化、资源加载和真实设备 I/O 仍需单独在 profile 模式下测量。

## 真机量化结果

运行环境：

- 设备：V2329A
- 系统：Android 16，API 36
- 架构：android-arm64
- 构建：profile APK
- 对比版本：
  - baseline：`9ed3285fd7c158a0ec4043162f5fbee2930c9bb5`
  - optimized：当前启动优化版本
- 测量方式：
  - `am start -W`：Android Activity 层冷进程启动耗时。
  - 临时 `STARTUP_PROBE`：profile APK 内部打点，仅用于本次测量，记录 Dart `main()` 到 `runApp`、到首帧 callback 的耗时；测量完成后已移除临时代码。
  - 每轮启动前执行 `pm clear` 并授予常规 runtime 权限，尽量测清数据冷启动下的首帧前链路。

真机 probe 结果：

| 指标 | baseline | optimized | 优化量 | 优化比例 |
| --- | ---: | ---: | ---: | ---: |
| `main -> runApp` 中位数 | 84 ms | 0 ms | 84 ms | 100.0% |
| `main -> runApp` 平均值 | 89.1 ms | 0.1 ms | 89.0 ms | 99.9% |
| `main -> 首帧 callback` 中位数 | 94 ms | 64 ms | 30 ms | 31.9% |
| `main -> 首帧 callback` 平均值 | 99.4 ms | 64.6 ms | 34.8 ms | 35.0% |

Activity 层 `am start -W` 结果：

| 指标 | baseline | optimized | 优化量 | 优化比例 |
| --- | ---: | ---: | ---: | ---: |
| `TotalTime` 中位数 | 790 ms | 742.5 ms | 47.5 ms | 6.0% |
| `TotalTime` 平均值 | 806.2 ms | 744.2 ms | 62.0 ms | 7.7% |
| `WaitTime` 中位数 | 820.5 ms | 751.5 ms | 69.0 ms | 8.4% |
| `WaitTime` 平均值 | 836.4 ms | 777.3 ms | 59.1 ms | 7.1% |

补充测量：不清数据、只 `force-stop` 的日常冷进程启动中，Activity 层几乎无变化：

| 指标 | baseline | optimized | 变化 |
| --- | ---: | ---: | ---: |
| `TotalTime` 中位数 | 604.5 ms | 608.5 ms | +4.0 ms |
| `WaitTime` 中位数 | 616.0 ms | 616.5 ms | +0.5 ms |
| `TotalTime` 平均值 | 607.1 ms | 608.8 ms | +1.7 ms |
| `WaitTime` 平均值 | 621.4 ms | 613.8 ms | -7.6 ms |

结论：真机上，最直接受本次改动影响的 `main -> runApp` 阻塞基本被清零；Dart 首帧 callback 中位数减少 **30 ms**，平均减少 **34.8 ms**。Android Activity 层的日常冷进程启动没有稳定可见的下降，说明该系统指标主要被原生启动、Flutter engine、LaunchTheme 首绘和设备调度噪声主导；本次代码优化应以 Dart probe 作为主要证据。

## 验证

- `flutter test test\app\startup_performance_test.dart`
- `$env:STARTUP_BENCHMARK_RUNS='12'; flutter test .tooling\measure_startup_isar_test.dart --plain-name "测量首帧前已移除的 Isar 初始化耗时"`
- 真机 probe 记录：`.tooling/startup_traces/real_device_startup_probe.csv`
- 真机 Activity 记录：`.tooling/startup_traces/real_device_launch_times.csv`

## 后续建议

- 在 Android 真机 profile 包中补一次 `flutter run --profile` + DevTools Startup/Timeline 采样，记录 `first frame rasterized` 与数据库 ready 的间隔。
- 若后续首页仍显得慢，下一步优先拆分 `overviewReadyDataProvider`：先展示缓存或空态骨架，再并行加载权限、洞察、AI 建议与提醒历史。
