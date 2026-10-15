import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 12 splash drawable exists for both v31 themes', () {
    final splash = File(
      'android/app/src/main/res/drawable/splash_logo.png',
    );
    final dayTheme = File(
      'android/app/src/main/res/values-v31/styles.xml',
    );
    final nightTheme = File(
      'android/app/src/main/res/values-night-v31/styles.xml',
    );

    expect(splash.existsSync(), isTrue);
    expect(splash.lengthSync(), greaterThan(0));
    expect(dayTheme.existsSync(), isTrue);
    expect(nightTheme.existsSync(), isTrue);

    const reference = '@drawable/splash_logo';
    expect(dayTheme.readAsStringSync(), contains(reference));
    expect(nightTheme.readAsStringSync(), contains(reference));
  });
}
