import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../application/auth_controller.dart';
// AppShadows lives in app_spacing.dart

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: AppLogo(size: 96))
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppConstants.appName,
                style: context.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppConstants.appTagline,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Meet native speakers, chat like Telegram,\nand learn with an AI tutor.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 260.ms),
              const Spacer(),
              LinguaButton(
                label: 'Get started',
                onPressed: () => context.push('/auth/register'),
              ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.sm),
              LinguaButton(
                label: 'I already have an account',
                isOutlined: true,
                onPressed: () => context.push('/auth/login'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final ok = await ref
                            .read(authControllerProvider.notifier)
                            .continueAsGuest();
                        if (ok && context.mounted) context.go('/home');
                      },
                child: const Text('Continue as guest'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
