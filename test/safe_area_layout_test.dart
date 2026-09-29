import 'package:fitwithsaju/core/widgets/app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('page padding adds Android bottom inset to visual spacing', (
    tester,
  ) async {
    EdgeInsets? resolved;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          viewPadding: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            resolved = fitPagePadding(context, bottom: 24);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, isNotNull);
    expect(resolved!.left, 20);
    expect(resolved!.right, 20);
    expect(resolved!.top, 8);
    expect(resolved!.bottom, 72);
  });

  testWidgets('page padding still keeps visual spacing with gesture inset', (
    tester,
  ) async {
    EdgeInsets? resolved;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          viewPadding: EdgeInsets.only(bottom: 16),
        ),
        child: Builder(
          builder: (context) {
            resolved = fitPagePadding(context, bottom: 24);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved!.bottom, 40);
  });
}
