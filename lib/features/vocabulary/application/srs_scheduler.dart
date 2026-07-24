import '../../../shared/models/vocabulary_item.dart';

/// SM-2–style scheduler for vocabulary reviews.
class SrsScheduler {
  const SrsScheduler();

  VocabularyItem applyReview(VocabularyItem item, ReviewGrade grade) {
    final now = DateTime.now();
    var ease = item.easeFactor;
    var reps = item.repetitions;
    var interval = item.intervalDays;
    var lapses = item.lapses;
    var status = item.srsStatus;

    switch (grade) {
      case ReviewGrade.again:
        reps = 0;
        lapses += 1;
        interval = 0;
        ease = (ease - 0.2).clamp(1.3, 3.0);
        status = SrsStatus.learning;
        return item.copyWith(
          easeFactor: ease,
          repetitions: reps,
          intervalDays: interval,
          lapses: lapses,
          srsStatus: status,
          nextReviewAt: now.add(const Duration(minutes: 10)),
          lastReviewedAt: now,
        );
      case ReviewGrade.hard:
        ease = (ease - 0.15).clamp(1.3, 3.0);
        if (reps == 0) {
          interval = 1;
          reps = 1;
          status = SrsStatus.learning;
        } else {
          interval = (interval * 1.2).round().clamp(1, 3650);
          reps += 1;
          status = interval >= 21 ? SrsStatus.review : SrsStatus.learning;
        }
        break;
      case ReviewGrade.good:
        if (reps == 0) {
          interval = 1;
          reps = 1;
          status = SrsStatus.learning;
        } else if (reps == 1) {
          interval = 3;
          reps = 2;
          status = SrsStatus.learning;
        } else {
          interval = (interval * ease).round().clamp(1, 3650);
          reps += 1;
          status = interval >= 21 ? SrsStatus.review : SrsStatus.learning;
        }
        break;
      case ReviewGrade.easy:
        ease = (ease + 0.15).clamp(1.3, 3.0);
        if (reps == 0) {
          interval = 3;
          reps = 1;
        } else if (reps == 1) {
          interval = 7;
          reps = 2;
        } else {
          interval = (interval * ease * 1.3).round().clamp(1, 3650);
          reps += 1;
        }
        status = interval >= 30 ? SrsStatus.mastered : SrsStatus.review;
        break;
    }

    if (interval >= 30 && reps >= 4 && grade != ReviewGrade.again) {
      status = SrsStatus.mastered;
    }

    return item.copyWith(
      easeFactor: ease,
      repetitions: reps,
      intervalDays: interval,
      lapses: lapses,
      srsStatus: status,
      nextReviewAt: now.add(Duration(days: interval == 0 ? 0 : interval)),
      lastReviewedAt: now,
    );
  }
}
