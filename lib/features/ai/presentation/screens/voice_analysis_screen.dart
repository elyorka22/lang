import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/learning_stats.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/ai_controller.dart';

class VoiceAnalysisScreen extends ConsumerStatefulWidget {
  const VoiceAnalysisScreen({super.key});

  @override
  ConsumerState<VoiceAnalysisScreen> createState() =>
      _VoiceAnalysisScreenState();
}

class _VoiceAnalysisScreenState extends ConsumerState<VoiceAnalysisScreen> {
  bool _recording = false;
  bool _analyzing = false;
  VoiceAnalysisResult? _result;

  Future<void> _run() async {
    setState(() {
      _recording = false;
      _analyzing = true;
      _result = null;
    });
    final result =
        await ref.read(aiControllerProvider.notifier).analyzeVoice();
    setState(() {
      _analyzing = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice analysis')),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
          Text(
            'Record a short phrase. AI returns pronunciation, fluency, accent, and coaching tips.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: GestureDetector(
              onTap: _analyzing
                  ? null
                  : () async {
                      if (!_recording) {
                        setState(() => _recording = true);
                      } else {
                        await _run();
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _recording
                      ? AppColors.error
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_recording ? AppColors.error : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _recording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _analyzing
                ? 'Analyzing…'
                : _recording
                    ? 'Listening… tap to stop'
                    : 'Tap to record',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium,
          ),
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _score('Pronunciation', _result!.pronunciationScore / 100),
            _score('Fluency', _result!.fluency / 100),
            _score('Naturalness', _result!.naturalness / 100),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Accent'),
              trailing: Text(_result!.accent),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Speaking speed'),
              trailing: Text('${_result!.speakingSpeed.round()} wpm'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Mispronounced', style: context.textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: _result!.mispronouncedWords
                  .map((w) => Chip(label: Text(w)))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Suggestions', style: context.textTheme.titleSmall),
            ..._result!.suggestions.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline,
                    color: AppColors.primary),
                title: Text(s),
              ),
            ),
            LinguaButton(
              label: 'Try again',
              onPressed: () => setState(() => _result = null),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _score(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('${(value * 100).round()}'),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: value,
            barRadius: const Radius.circular(8),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
