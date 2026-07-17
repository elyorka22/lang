import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeBody(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _sent
                    ? 'Check your inbox'
                    : 'Enter your email and we will send a reset link.',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!_sent) ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                LinguaButton(
                  label: 'Send reset link',
                  onPressed: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .forgotPassword(_email.text.trim());
                    setState(() => _sent = true);
                  },
                ),
              ] else ...[
                LinguaButton(
                  label: 'Back to sign in',
                  onPressed: () => context.go('/auth/login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
