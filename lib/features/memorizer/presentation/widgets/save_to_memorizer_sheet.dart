import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../application/memorizer_controller.dart';

Future<void> showSaveToMemorizerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String text,
  String? conversationId,
  String? messageId,
  String contextSentence = '',
}) async {
  final clipped = text.trim();
  if (clipped.isEmpty) {
    context.showSnack('Select a word or phrase first', isError: true);
    return;
  }

  final translation = TextEditingController();
  final note = TextEditingController();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Save to Запоминалка', style: ctx.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                clipped,
                style: ctx.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: translation,
                decoration: const InputDecoration(
                  labelText: 'Translation (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (saved != true) return;

  final item = await ref.read(memorizerProvider.notifier).saveFromChat(
        text: clipped,
        conversationId: conversationId,
        messageId: messageId,
        contextSentence: contextSentence,
        translation: translation.text,
        note: note.text,
      );

  if (!context.mounted) return;
  if (item == null) {
    context.showSnack('Nothing to save', isError: true);
    return;
  }
  context.showSnack('Saved to Запоминалка');
}
