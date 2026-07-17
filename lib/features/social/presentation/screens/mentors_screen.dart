import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/social_controller.dart';

class MentorsScreen extends ConsumerWidget {
  const MentorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final social = ref.watch(socialControllerProvider);
    final mentors = social.mentors;

    return Scaffold(
      appBar: AppBar(title: const Text('Mentors & karma')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Helpful corrections earn karma. Reach $mentorKarmaThreshold karma to unlock the Mentor badge.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your karma: ${social.myKarma}'
              '${social.iAmMentor ? ' · Mentor ✓' : ''}',
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...mentors.map((m) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => context.push('/users/${m.user.id}'),
                leading: AppAvatar(
                  name: m.user.displayName,
                  url: m.user.avatarUrl,
                  status: m.user.status,
                  showStatus: true,
                ),
                title: Row(
                  children: [
                    Flexible(child: Text(m.user.displayName)),
                    if (m.isMentor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Mentor',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${m.karma} karma · ${m.correctionsHelped} corrections · ${m.user.nativeLanguage}',
                ),
                trailing: Text(
                  '#${mentors.indexOf(m) + 1}',
                  style: context.textTheme.titleSmall,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
