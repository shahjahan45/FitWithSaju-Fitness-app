import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppPreferences.initialize();
  });

  test('app preferences persist and round-trip through backup data', () async {
    await AppPreferences.setHapticsEnabled(false);
    await AppPreferences.setSoundsEnabled(true);
    await AppPreferences.setReduceMotion(true);
    await AppPreferences.setAutoSyncContent(false);

    final backup = AppPreferences.exportData();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppPreferences.initialize();
    expect(AppPreferences.current.hapticsEnabled, isTrue);

    await AppPreferences.importData(backup);
    expect(AppPreferences.current.hapticsEnabled, isFalse);
    expect(AppPreferences.current.soundsEnabled, isTrue);
    expect(AppPreferences.current.reduceMotion, isTrue);
    expect(AppPreferences.current.autoSyncContent, isFalse);
  });
}
