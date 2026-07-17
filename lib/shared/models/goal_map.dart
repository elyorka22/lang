/// Long-term level goal with a deadline and daily check-ins ("Goal Map").
class GoalMapPlan {
  const GoalMapPlan({
    required this.id,
    required this.title,
    required this.startLevel,
    required this.targetLevel,
    required this.startDate,
    required this.deadline,
    this.language = 'English',
    this.dailyLogs = const {},
    this.isActive = true,
  });

  final String id;
  final String title;
  final int startLevel;
  final int targetLevel;
  final DateTime startDate;
  final DateTime deadline;
  final String language;

  /// Key: yyyy-MM-dd → whether that day was completed toward the goal.
  final Map<String, GoalDayLog> dailyLogs;
  final bool isActive;

  int get levelsToGain {
    final n = targetLevel - startLevel;
    return n < 1 ? 1 : n;
  }

  int get totalDays {
    final d = deadline.difference(dateOnly(startDate)).inDays + 1;
    return d < 1 ? 1 : d;
  }

  int get daysLeft {
    final left = dateOnly(deadline).difference(dateOnly(DateTime.now())).inDays;
    return left < 0 ? 0 : left;
  }

  int get daysPassed {
    final p = dateOnly(DateTime.now()).difference(dateOnly(startDate)).inDays;
    if (p < 0) return 0;
    if (p > totalDays) return totalDays;
    return p;
  }

  int get completedDays =>
      dailyLogs.values.where((l) => l.completed).length;

  /// Estimated XP still needed (mock formula: ~120 XP per level).
  int get estimatedXpNeeded => levelsToGain * 120;

  int get xpEarned =>
      dailyLogs.values.fold(0, (sum, l) => sum + l.xpEarned);

  double get levelProgress {
    if (estimatedXpNeeded <= 0) return 1;
    return (xpEarned / estimatedXpNeeded).clamp(0.0, 1.0);
  }

  double get timeProgress => (daysPassed / totalDays).clamp(0.0, 1.0);

  bool get isOnTrack => levelProgress >= timeProgress - 0.05;

  bool get isCompleted =>
      levelProgress >= 1.0 || DateTime.now().isAfter(deadline.add(const Duration(days: 1)));

  bool get todayDone {
    final key = dateKey(DateTime.now());
    return dailyLogs[key]?.completed ?? false;
  }

  int get suggestedXpToday {
    final leftDays = daysLeft + (todayDone ? 0 : 1);
    final leftXp = estimatedXpNeeded - xpEarned;
    if (leftXp <= 0) return 0;
    if (leftDays <= 0) return leftXp;
    final per = (leftXp / leftDays).ceil();
    return per.clamp(10, 200);
  }

  GoalMapPlan copyWith({
    String? title,
    int? startLevel,
    int? targetLevel,
    DateTime? startDate,
    DateTime? deadline,
    String? language,
    Map<String, GoalDayLog>? dailyLogs,
    bool? isActive,
  }) {
    return GoalMapPlan(
      id: id,
      title: title ?? this.title,
      startLevel: startLevel ?? this.startLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      language: language ?? this.language,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startLevel': startLevel,
        'targetLevel': targetLevel,
        'startDate': startDate.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'language': language,
        'isActive': isActive,
        'dailyLogs': {
          for (final e in dailyLogs.entries) e.key: e.value.toJson(),
        },
      };

  factory GoalMapPlan.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['dailyLogs'];
    final logs = <String, GoalDayLog>{};
    if (rawLogs is Map) {
      rawLogs.forEach((key, value) {
        if (value is Map) {
          logs['$key'] = GoalDayLog.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }
    return GoalMapPlan(
      id: json['id'] as String? ?? 'goal',
      title: json['title'] as String? ?? 'Level goal',
      startLevel: json['startLevel'] as int? ?? 1,
      targetLevel: json['targetLevel'] as int? ?? 5,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      language: json['language'] as String? ?? 'English',
      isActive: json['isActive'] as bool? ?? true,
      dailyLogs: logs,
    );
  }

  static String dateKey(DateTime d) {
    final x = dateOnly(d);
    final m = x.month.toString().padLeft(2, '0');
    final day = x.day.toString().padLeft(2, '0');
    return '${x.year}-$m-$day';
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Day nodes for the visual map (capped for UI).
  List<GoalMapNode> buildNodes({int maxNodes = 21}) {
    final nodes = <GoalMapNode>[];
    final total = totalDays;
    final step = total <= maxNodes ? 1 : (total / maxNodes).ceil();
    var dayIndex = 0;
    while (dayIndex < total) {
      final date = dateOnly(startDate).add(Duration(days: dayIndex));
      final key = dateKey(date);
      final log = dailyLogs[key];
      final isToday = dateKey(DateTime.now()) == key;
      final isPast = date.isBefore(dateOnly(DateTime.now()));
      nodes.add(
        GoalMapNode(
          date: date,
          dayNumber: dayIndex + 1,
          completed: log?.completed ?? false,
          isToday: isToday,
          isPast: isPast && !isToday,
          xpEarned: log?.xpEarned ?? 0,
        ),
      );
      dayIndex += step;
    }
    final lastKey = dateKey(deadline);
    if (nodes.isEmpty || dateKey(nodes.last.date) != lastKey) {
      final log = dailyLogs[lastKey];
      nodes.add(
        GoalMapNode(
          date: dateOnly(deadline),
          dayNumber: total,
          completed: log?.completed ?? false,
          isToday: dateKey(DateTime.now()) == lastKey,
          isPast: dateOnly(deadline).isBefore(dateOnly(DateTime.now())),
          xpEarned: log?.xpEarned ?? 0,
          isDeadline: true,
        ),
      );
    } else {
      nodes[nodes.length - 1] = GoalMapNode(
        date: nodes.last.date,
        dayNumber: nodes.last.dayNumber,
        completed: nodes.last.completed,
        isToday: nodes.last.isToday,
        isPast: nodes.last.isPast,
        xpEarned: nodes.last.xpEarned,
        isDeadline: true,
      );
    }
    return nodes;
  }
}

class GoalDayLog {
  const GoalDayLog({
    required this.dateKey,
    this.completed = false,
    this.xpEarned = 0,
    this.note = '',
  });

  final String dateKey;
  final bool completed;
  final int xpEarned;
  final String note;

  GoalDayLog copyWith({
    bool? completed,
    int? xpEarned,
    String? note,
  }) {
    return GoalDayLog(
      dateKey: dateKey,
      completed: completed ?? this.completed,
      xpEarned: xpEarned ?? this.xpEarned,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'completed': completed,
        'xpEarned': xpEarned,
        'note': note,
      };

  factory GoalDayLog.fromJson(Map<String, dynamic> json) {
    return GoalDayLog(
      dateKey: json['dateKey'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      xpEarned: json['xpEarned'] as int? ?? 0,
      note: json['note'] as String? ?? '',
    );
  }
}

class GoalMapNode {
  const GoalMapNode({
    required this.date,
    required this.dayNumber,
    required this.completed,
    required this.isToday,
    required this.isPast,
    this.xpEarned = 0,
    this.isDeadline = false,
  });

  final DateTime date;
  final int dayNumber;
  final bool completed;
  final bool isToday;
  final bool isPast;
  final int xpEarned;
  final bool isDeadline;
}
