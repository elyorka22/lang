import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
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
  String? _learning;
  String? _level;
  final _interests = <String>{};

  static const _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Portuguese',
    'Italian',
    'Korean',
    'Chinese',
    'Arabic',
  ];

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const _interestOptions = [
    'Travel',
    'Music',
    'Movies',
    'Sports',
    'Tech',
    'Food',
    'Art',
    'Books',
    'Business',
    'Gaming',
  ];

  Future<void> _finish() async {
    await ref.read(localStorageProvider).setOnboardingSeen();
    if (mounted) context.go('/home');
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
                    title: 'What is your native language?',
                    selected: _native,
                    onSelect: (v) => setState(() => _native = v),
                  ),
                  _langStep(
                    title: 'Which language are you learning?',
                    selected: _learning,
                    onSelect: (v) => setState(() => _learning = v),
                    showLevels: true,
                  ),
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
                  if (_index == 1 && (_learning == null || _level == null)) {
                    return;
                  }
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
    bool showLevels = false,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languages.map((lang) {
            final active = selected == lang;
            return ChoiceChip(
              label: Text(lang),
              selected: active,
              onSelected: (_) => onSelect(lang),
              selectedColor: AppColors.primarySurface,
              labelStyle: TextStyle(
                color: active ? AppColors.primaryDark : null,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
        if (showLevels) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Your level', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
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
      ],
    );
  }

  Widget _interestsStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('What are you into?', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We will recommend better language partners',
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
