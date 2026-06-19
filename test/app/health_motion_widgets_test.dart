import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/theme.dart';
import 'package:health_monitor/app/widgets/health_motion_widgets.dart';

void main() {
  testWidgets('HealthAnimatedValue 会从旧值平滑过渡到目标值', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: HealthAnimatedValue(
          value: 100,
          builder: (_, value, __) => Text(value.round().toString()),
        ),
      ),
    );

    expect(find.text('100'), findsNothing);
    await tester.pump(const Duration(milliseconds: 325));
    expect(find.text('100'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('减少动态效果时数值直接显示最终状态', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        disableAnimations: true,
        child: HealthAnimatedValue(
          value: 100,
          builder: (_, value, __) => Text(value.round().toString()),
        ),
      ),
    );

    expect(find.text('100'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('减少动态效果时按压表面不缩放', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        disableAnimations: true,
        child: HealthPressableSurface(
          onTap: () {},
          child: const SizedBox(
            key: Key('pressable'),
            width: 100,
            height: 100,
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byKey(const Key('pressable')));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1);
    await gesture.up();
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.disableAnimations = false,
  });

  final Widget child;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(disableAnimations: disableAnimations),
          child: child!,
        );
      },
      home: Scaffold(body: Center(child: child)),
    );
  }
}
