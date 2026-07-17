import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/goal_map.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/goal_map_controller.dart';

class GoalMapScreen extends ConsumerStatefulWidget {
  const GoalMapScreen({super.key});

  @override
  ConsumerState<GoalMapScreen> createState() => _GoalMapScreenState();
}

class _GoalMapScreenState extends ConsumerState<GoalMapScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalMapControllerProvider);
    final plan = state.plan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Map'),
        actions: [
          if (plan != null)
            IconButton(
              tooltip: 'Clear goal',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear this goal?'),
                    content: const Text(
                      'Your map and daily check-ins will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(goalMapControllerProvider.notifier).clearPlan();
                }
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeBody(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : plan == null
                ? _EmptyGoal(onCreate: _openCreateSheet)
                : _ActiveGoalMap(
                    plan: plan,
                    onLogToday: () => ref
                        .read(goalMapControllerProvider.notifier)
                        .markTodayComplete(),
                    onUndoToday: () =>
                        ref.read(goalMapControllerProvider.notifier).undoToday(),
                    onEdit: _openCreateSheet,
                  ),
      ),
    );
  }

  Future<void> _openCreateSheet() async {
    final user = ref.read(authControllerProvider).user;
    final startLevel = user?.level ?? 1;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _CreateGoalSheet(
          startLevel: startLevel,
          onSubmit: (target, deadline) async {
            Navigator.pop(ctx);
            await ref.read(goalMapControllerProvider.notifier).createPlan(
                  startLevel: startLevel,
                  targetLevel: target,
                  deadline: deadline,
                );
          },
        );
      },
    );
  }
}

class _EmptyGoal extends StatelessWidget {
  const _EmptyGoal({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.map_outlined, size: 72, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Set your Goal Map',
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a target level and a date. Every day Lingua tracks whether you stayed on the path.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          LinguaButton(
            label: 'Create goal',
            icon: Icons.flag_outlined,
            onPressed: onCreate,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _CreateGoalSheet extends StatefulWidget {
  const _CreateGoalSheet({
    required this.startLevel,
    required this.onSubmit,
  });

  final int startLevel;
  final void Function(int targetLevel, DateTime deadline) onSubmit;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  late int _target;
  int? _quickDays = 30;
  DateTime? _calendarDate;

  static const _dayOptions = [7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _target = widget.startLevel + 2;
  }

  List<int> get _levelOptions {
    final list = <int>[];
    for (var i = widget.startLevel + 1; i <= widget.startLevel + 12; i++) {
      list.add(i);
    }
    return list;
  }

  DateTime get _deadline {
    if (_calendarDate != null) return _calendarDate!;
    final days = _quickDays ?? 30;
    return DateTime.now().add(Duration(days: days));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Goal Map',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Now level ${widget.startLevel} → choose where you want to be',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Target level', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _levelOptions.map((lvl) {
                return ChoiceChip(
                  label: Text('Lv $lvl'),
                  selected: _target == lvl,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() => _target = lvl),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Deadline', style: context.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'By days or pick a date on the calendar',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dayOptions.map((d) {
                final selected = _quickDays == d && _calendarDate == null;
                return ChoiceChip(
                  label: Text('$d days'),
                  selected: selected,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() {
                    _quickDays = d;
                    _calendarDate = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 30)),
                  firstDate: now.add(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                  helpText: 'Reach your level by',
                );
                if (picked != null) {
                  setState(() {
                    _calendarDate = picked;
                    _quickDays = null;
                  });
                }
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _calendarDate == null
                    ? 'Pick date from calendar'
                    : DateFormat.yMMMd().format(_calendarDate!),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Plan: level ${widget.startLevel} → $_target by ${DateFormat.MMMd().format(_deadline)}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            LinguaButton(
              label: 'Start Goal Map',
              onPressed: () => widget.onSubmit(_target, _deadline),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveGoalMap extends StatelessWidget {
  const _ActiveGoalMap({
    required this.plan,
    required this.onLogToday,
    required this.onUndoToday,
    required this.onEdit,
  });

  final GoalMapPlan plan;
  final VoidCallback onLogToday;
  final VoidCallback onUndoToday;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final nodes = plan.buildNodes();
    final fmt = DateFormat.MMMd();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.brandGradientSoft,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${plan.startLevel} → ${plan.targetLevel} · by ${fmt.format(plan.deadline)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              LinearPercentIndicator(
                lineHeight: 10,
                percent: plan.levelProgress,
                animation: true,
                barRadius: const Radius.circular(8),
                backgroundColor: Colors.white24,
                progressColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                '${(plan.levelProgress * 100).round()}% of path · ${plan.daysLeft} days left · ${plan.isOnTrack ? 'On track' : 'Behind — practice today'}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Today', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Material(
          color: context.isDark
              ? AppColors.surfaceElevatedDark
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.todayDone
                      ? 'Today’s check-in done · +${plan.dailyLogs[GoalMapPlan.dateKey(DateTime.now())]?.xpEarned ?? 0} XP'
                      : 'Suggested today: ~${plan.suggestedXpToday} XP toward level ${plan.targetLevel}',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinguaButton(
                        label: plan.todayDone ? 'Logged' : 'Mark today done',
                        icon: plan.todayDone
                            ? Icons.check_circle
                            : Icons.flag_outlined,
                        onPressed: plan.todayDone ? null : onLogToday,
                      ),
                    ),
                    if (plan.todayDone) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Undo',
                        onPressed: onUndoToday,
                        icon: const Icon(Icons.undo),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text('Your map', style: context.textTheme.titleMedium),
            const Spacer(),
            TextButton(onPressed: onEdit, child: const Text('New goal')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Each step is a day on the way to your deadline.',
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...nodes.map((n) => _MapStep(node: n, plan: plan)),
        const SizedBox(height: 12),
        Text(
          'Daily goal on Home opens this map. Log every day to stay on track.',
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _MapStep extends StatelessWidget {
  const _MapStep({required this.node, required this.plan});

  final GoalMapNode node;
  final GoalMapPlan plan;

  @override
  Widget build(BuildContext context) {
    Color dot;
    if (node.completed) {
      dot = AppColors.success;
    } else if (node.isToday) {
      dot = AppColors.primary;
    } else if (node.isPast) {
      dot = AppColors.warning.withOpacity(0.7);
    } else {
      dot = AppColors.border;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  border: node.isToday
                      ? Border.all(color: AppColors.primaryDark, width: 2)
                      : null,
                ),
                child: node.completed
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${node.dayNumber}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: node.isPast || node.isToday
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
              Container(
                width: 2,
                height: 28,
                color: AppColors.border,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.isDeadline
                        ? 'Finish · Level ${plan.targetLevel}'
                        : node.isToday
                            ? 'Today'
                            : DateFormat.MMMd().format(node.date),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: node.isToday ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    node.completed
                        ? 'Done · +${node.xpEarned} XP'
                        : node.isToday
                            ? 'Check in after practice'
                            : node.isPast
                                ? 'Missed'
                                : 'Upcoming',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
