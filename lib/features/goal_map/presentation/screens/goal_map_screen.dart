import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/goal_map.dart';
import '../../../../shared/providers/locale_provider.dart';
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
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.goalMap),
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
    final existing = ref.read(goalMapControllerProvider).plan;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return _CreateGoalSheet(
          initialDescription: existing?.title ?? '',
          onSubmit: (description, deadline) async {
            Navigator.pop(ctx);
            await ref.read(goalMapControllerProvider.notifier).createPlan(
                  description: description,
                  deadline: deadline,
                  startLevel: startLevel,
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
            'Describe your own goal and pick a date. Every day Lingua tracks whether you stayed on the path.',
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
    required this.onSubmit,
    this.initialDescription = '',
  });

  final String initialDescription;
  final void Function(String description, DateTime deadline) onSubmit;

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  late final TextEditingController _goalCtrl;
  int? _quickDays = 30;
  DateTime? _calendarDate;

  static const _dayOptions = [7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _goalCtrl = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  DateTime get _deadline {
    if (_calendarDate != null) return _calendarDate!;
    final days = _quickDays ?? 30;
    return DateTime.now().add(Duration(days: days));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + keyboard + 16),
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
              'Write your goal in your own words',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Your goal', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _goalCtrl,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Hold a 10-minute conversation in Spanish about travel',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
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
                  initialDate: _calendarDate ?? now.add(const Duration(days: 30)),
                  firstDate: now.add(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                  helpText: 'Reach your goal by',
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
                _goalCtrl.text.trim().isEmpty
                    ? 'Deadline: ${DateFormat.MMMd().format(_deadline)}'
                    : '${_goalCtrl.text.trim()}\nby ${DateFormat.MMMd().format(_deadline)}',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            LinguaButton(
              label: 'Start Goal Map',
              onPressed: _goalCtrl.text.trim().isEmpty
                  ? null
                  : () => widget.onSubmit(_goalCtrl.text.trim(), _deadline),
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
            color: AppColors.primary,
            borderRadius: AppRadius.borderXl,
            boxShadow: AppShadows.primaryGlow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'by ${fmt.format(plan.deadline)} · ${plan.daysLeft} days left',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              LinearPercentIndicator(
                lineHeight: 10,
                percent: plan.displayProgress,
                animation: true,
                barRadius: const Radius.circular(8),
                backgroundColor: Colors.white24,
                progressColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                '${(plan.displayProgress * 100).round()}% · ${plan.completedDays} days logged · ${plan.isOnTrack ? 'On track' : 'Behind — practice today'}',
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
                      : 'Practice toward your goal today (~${plan.suggestedXpToday} XP)',
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
                        ? 'Finish · ${plan.title}'
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
