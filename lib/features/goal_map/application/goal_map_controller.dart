import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../shared/models/goal_map.dart';

class GoalMapState {
  const GoalMapState({
    this.plan,
    this.isLoading = false,
  });

  final GoalMapPlan? plan;
  final bool isLoading;

  GoalMapState copyWith({
    GoalMapPlan? plan,
    bool? isLoading,
    bool clearPlan = false,
  }) {
    return GoalMapState(
      plan: clearPlan ? null : (plan ?? this.plan),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final goalMapControllerProvider =
    StateNotifierProvider<GoalMapController, GoalMapState>((ref) {
  return GoalMapController(ref.read(localStorageProvider))..load();
});

class GoalMapController extends StateNotifier<GoalMapState> {
  GoalMapController(this._storage) : super(const GoalMapState(isLoading: true));

  final LocalStorageService _storage;
  final _uuid = const Uuid();

  void load() {
    final raw = _storage.goalMapJson;
    if (raw == null || raw.isEmpty) {
      state = const GoalMapState(isLoading: false);
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = GoalMapState(
        plan: GoalMapPlan.fromJson(map),
        isLoading: false,
      );
    } catch (_) {
      state = const GoalMapState(isLoading: false);
    }
  }

  Future<void> _persist(GoalMapPlan? plan) async {
    if (plan == null) {
      await _storage.setGoalMapJson(null);
      return;
    }
    await _storage.setGoalMapJson(jsonEncode(plan.toJson()));
  }

  Future<void> createPlan({
    required String description,
    required DateTime deadline,
    int startLevel = 1,
    String language = 'English',
  }) async {
    final start = DateTime.now();
    final text = description.trim();
    final title = text.isEmpty ? 'My learning goal' : text;
    var safeDeadline = GoalMapPlan.dateOnly(deadline);
    if (!safeDeadline.isAfter(GoalMapPlan.dateOnly(start))) {
      safeDeadline = GoalMapPlan.dateOnly(start).add(const Duration(days: 7));
    }

    // Soft XP track under the hood so daily check-ins still feel rewarding.
    final targetLevel = startLevel + 3;

    final plan = GoalMapPlan(
      id: _uuid.v4(),
      title: title,
      startLevel: startLevel,
      targetLevel: targetLevel,
      startDate: start,
      deadline: safeDeadline,
      language: language,
    );
    state = state.copyWith(plan: plan);
    await _persist(plan);
  }

  Future<void> createPlanInDays({
    required String description,
    required int days,
    int startLevel = 1,
    String language = 'English',
  }) {
    final d = days < 1 ? 1 : days;
    return createPlan(
      description: description,
      deadline: DateTime.now().add(Duration(days: d)),
      startLevel: startLevel,
      language: language,
    );
  }

  Future<void> markTodayComplete({int? xp}) async {
    final plan = state.plan;
    if (plan == null || !plan.isActive) return;

    final key = GoalMapPlan.dateKey(DateTime.now());
    final earn = xp ?? plan.suggestedXpToday;
    final logs = Map<String, GoalDayLog>.from(plan.dailyLogs);
    logs[key] = GoalDayLog(
      dateKey: key,
      completed: true,
      xpEarned: earn < 10 ? 10 : earn,
      note: 'Daily practice logged',
    );
    final next = plan.copyWith(dailyLogs: logs);
    state = state.copyWith(plan: next);
    await _persist(next);
  }

  Future<void> undoToday() async {
    final plan = state.plan;
    if (plan == null) return;
    final key = GoalMapPlan.dateKey(DateTime.now());
    final logs = Map<String, GoalDayLog>.from(plan.dailyLogs)..remove(key);
    final next = plan.copyWith(dailyLogs: logs);
    state = state.copyWith(plan: next);
    await _persist(next);
  }

  Future<void> clearPlan() async {
    state = state.copyWith(clearPlan: true);
    await _persist(null);
  }
}
