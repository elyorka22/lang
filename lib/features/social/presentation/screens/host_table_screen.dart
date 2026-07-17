import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/social_controller.dart';

class HostTableScreen extends ConsumerStatefulWidget {
  const HostTableScreen({super.key, this.initialTopic});

  final RoomTopic? initialTopic;

  @override
  ConsumerState<HostTableScreen> createState() => _HostTableScreenState();
}

class _HostTableScreenState extends ConsumerState<HostTableScreen> {
  final _title = TextEditingController();
  late RoomTopic _topic;
  String _language = 'English';
  String _level = 'A2–B2';
  var _creating = false;

  static const _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Portuguese',
    'Japanese',
  ];

  static const _levels = ['A1–A2', 'A2–B1', 'A2–B2', 'B1–C1', 'Any'];

  @override
  void initState() {
    super.initState();
    _topic = widget.initialTopic ?? RoomTopic.social;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      context.showSnack('Add a table topic', isError: true);
      return;
    }
    setState(() => _creating = true);
    final table = await ref.read(socialControllerProvider.notifier).hostTable(
          title: _title.text,
          topic: _topic,
          language: _language,
          levelHint: _level,
        );
    if (!mounted) return;
    context.showSnack('Table hosted · 30 min · 4 seats');
    context.go('/social');
    // keep reference for lints
    assert(table.id.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host a table')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Club format: 30 minutes, max 4 people, one clear topic.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Table title',
                hintText: 'e.g. Ordering food at a café',
              ),
            ),
            const SizedBox(height: 16),
            Text('Room', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RoomTopic.values.map((t) {
                final selected = _topic == t;
                return ChoiceChip(
                  label: Text('${t.emoji} ${t.label}'),
                  selected: selected,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() => _topic = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Language', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _languages.map((l) {
                return ChoiceChip(
                  label: Text(l),
                  selected: _language == l,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() => _language = l),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Level', style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _levels.map((l) {
                return ChoiceChip(
                  label: Text(l),
                  selected: _level == l,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() => _level = l),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Duration'),
              trailing: Text('30 min', style: context.textTheme.titleSmall),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Seats'),
              trailing: Text('4 people', style: context.textTheme.titleSmall),
            ),
            const SizedBox(height: 16),
            LinguaButton(
              label: 'Open table',
              isLoading: _creating,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
