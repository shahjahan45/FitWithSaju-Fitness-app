import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('replaceWeeklyPlan normalizes all seven days atomically', () async {
    await LocalStore.replaceWeeklyPlan(<Map<String, dynamic>>[
      <String, dynamic>{
        'day': 'Monday',
        'title': 'Program Day',
        'isRest': false,
        'durationMinutes': 50,
        'exerciseIds': <String>['3TZduzM', '7F1DVzn'],
      },
      <String, dynamic>{
        'day': 'Wednesday',
        'title': 'Second Day',
        'isRest': false,
        'durationMinutes': 45,
        'exerciseIds': <String>['2Qh2J1e'],
      },
    ]);

    final plan = await LocalStore.weeklyPlan();
    expect(plan, hasLength(7));
    expect(plan.map((item) => item['day']), LocalStore.weekDays);
    expect(plan.first['title'], 'Program Day');
    expect(plan[1]['isRest'], isTrue);
    expect(plan[2]['title'], 'Second Day');
    expect(plan.last['isRest'], isTrue);
  });
}
