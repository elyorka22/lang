import 'package:flutter_test/flutter_test.dart';

import 'package:lingua/features/pronunciation/application/pronunciation_comparator.dart';

void main() {
  const comparator = PronunciationComparator();

  test('ignores punctuation and capitalization', () {
    final result = comparator.compare(
      expected: 'Hello, World!',
      recognized: 'hello world',
    );
    expect(result.score, 100);
    expect(result.isCorrect, isTrue);
  });

  test('detects missing words', () {
    final result = comparator.compare(
      expected: 'I would like some coffee.',
      recognized: 'I would like coffee.',
    );

    expect(result.missingWords, contains('some'));
    expect(
      result.wordMatches.any(
        (m) => m.status.name == 'missing' && m.expected == 'some',
      ),
      isTrue,
    );
    expect(result.score, greaterThan(70));
    expect(result.score, lessThan(100));
  });

  test('marks excellent rating at 90+', () {
    final result = comparator.compare(
      expected: 'Good morning',
      recognized: 'Good morning',
    );
    expect(result.score, 100);
    expect(result.isCorrect, isTrue);
    expect(result.rating.name, 'excellent');
  });
}
