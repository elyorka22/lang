import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.stats;
    return Scaffold(
      appBar: AppBar(title: const Text('Learning')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.surfaceElevatedDark
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.streakOrange, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${stats.currentStreak} day streak',
                          style: context.textTheme.titleLarge),
                      Text('Longest: ${stats.longestStreak} days'),
                    ],
                  ),
                ),
                Text('Lv ${stats.level}',
                    style: context.textTheme.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('This week (minutes)', style: context.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < stats.weeklyMinutes.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (stats.weeklyMinutes[i] / 30) * 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Total XP'),
            trailing: Text('${stats.totalXp}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Words learned'),
            trailing: Text('${stats.totalWords}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Messages sent'),
            trailing: Text('${stats.totalMessages}'),
          ),
          const SizedBox(height: 12),
          LinguaButton(
            label: 'View leaderboard',
            isOutlined: true,
            onPressed: () => context.showSnack('Leaderboard API: /learning/leaderboard'),
          ),
          const SizedBox(height: 8),
          LinguaButton(
            label: 'Upgrade for advanced stats',
            onPressed: () => context.push('/premium'),
          ),
        ],
        ),
      ),
    );
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lingua Premium')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.brandGradient,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock unlimited AI',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Voice analysis, roleplay, advanced grammar, and unlimited vocabulary.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...[
            'Unlimited AI requests',
            'Voice analysis',
            'Unlimited translation',
            'AI roleplay',
            'Advanced grammar',
            'Unlimited vocabulary',
            'Advanced statistics',
          ].map(
            (e) => ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.primary),
              title: Text(e),
            ),
          ),
          const SizedBox(height: 12),
          LinguaButton(
            label: 'Start Premium — \$7.99/mo',
            onPressed: () => context.showSnack('Connect StoreKit / Play Billing'),
          ),
        ],
        ),
      ),
    );
  }
}
