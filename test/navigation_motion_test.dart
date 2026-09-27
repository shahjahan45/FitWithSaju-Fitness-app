import 'package:fitwithsaju/core/motion/app_motion.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('motion durations stay inside the intended ranges', () {
    expect(AppMotion.mainNavigation.inMilliseconds, inInclusiveRange(220, 280));
    expect(AppMotion.detail.inMilliseconds, inInclusiveRange(280, 350));
    expect(AppMotion.modal.inMilliseconds, inInclusiveRange(250, 320));
    expect(AppMotion.internalTab.inMilliseconds, inInclusiveRange(160, 220));
    expect(AppMotion.authToHome.inMilliseconds, inInclusiveRange(300, 350));
    expect(AppMotion.onboarding.inMilliseconds, inInclusiveRange(280, 350));
    expect(AppMotion.success.inMilliseconds, inInclusiveRange(250, 320));
    expect(AppMotion.fullScreen.inMilliseconds, inInclusiveRange(280, 350));
  });

  testWidgets('bottom navigation preserves Explore field state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('nav-explore')));
    await tester.pump();
    await tester.pump(AppMotion.mainNavigation);

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'bench');

    await tester.tap(find.byKey(const ValueKey('nav-home')));
    await tester.pump();
    await tester.pump(AppMotion.mainNavigation);

    await tester.tap(find.byKey(const ValueKey('nav-explore')));
    await tester.pump();
    await tester.pump(AppMotion.mainNavigation);

    expect(find.text('bench'), findsOneWidget);
  });
}
