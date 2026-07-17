import 'package:flutter_test/flutter_test.dart';

import 'package:lingua/shared/models/learning_stats.dart';
import 'package:lingua/shared/models/user_profile.dart';

void main() {
  test('DailyGoal overall progress clamps to 0–1', () {
    const goal = DailyGoal(
      minutesDone: 15,
      messagesDone: 10,
      voiceDone: 3,
      wordsDone: 5,
      aiLessonsDone: 1,
    );
    expect(goal.overallProgress, 1.0);
    expect(goal.isComplete, isTrue);
  });

  test('UserProfile copyWith updates display name', () {
    const user = UserProfile(
      id: '1',
      displayName: 'Alex',
      username: 'alex',
      nativeLanguage: 'English',
      learningLanguages: [],
    );
    final updated = user.copyWith(displayName: 'Alexa');
    expect(updated.displayName, 'Alexa');
    expect(updated.id, '1');
  });
}
