import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/app_language.dart';
import '../../../../shared/widgets/lingua_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  String? _native;
  String? _level;
  final _interests = <String>{};

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const _interestOptions = [
    'Travel',
    'Business',
    'Technology',
    'Food',
    'Medical',
    'Animals',
    'General',
  ];

  Future<void> _finish() async {
    await ref.read(localStorageProvider).setOnboardingSeen();
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _index
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _langStep(
                    title: 'What language do you speak natively?',
                    selected: _native,
                    onSelect: (v) => setState(() => _native = v),
                  ),
                  _levelStep(),
                  _interestsStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LinguaButton(
                label: _index == 2 ? 'Start learning' : 'Continue',
                onPressed: () {
                  if (_index == 0 && _native == null) return;
                  if (_index == 1 && _level == null) return;
                  if (_index < 2) {
                    _page.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langStep({
    required String title,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppLanguages.all.map((lang) {
            final active = selected == lang.name;
            return ChoiceChip(
              label: Text('${lang.flag} ${lang.name}'),
              selected: active,
              onSelected: (_) => onSelect(lang.name),
              selectedColor: AppColors.primarySurface,
              labelStyle: TextStyle(
                color: active ? AppColors.primaryDark : null,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _levelStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'You are learning English — pick your level',
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _levels.map((l) {
            final active = _level == l;
            return ChoiceChip(
              label: Text(l),
              selected: active,
              onSelected: (_) => setState(() => _level = l),
              selectedColor: AppColors.primarySurface,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _interestsStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Which word topics interest you?',
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We will prioritize these categories in your deck',
          style: context.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestOptions.map((item) {
            final active = _interests.contains(item);
            return FilterChip(
              label: Text(item),
              selected: active,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _interests.add(item);
                  } else {
                    _interests.remove(item);
                  }
                });
              },
              selectedColor: AppColors.primarySurface,
            );
          }).toList(),
        ),
      ],
    );
  }
}
