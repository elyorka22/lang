import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? AppColors.surfaceElevatedDark : AppColors.secondary;
    final highlight = context.isDark ? AppColors.borderDark : Colors.white;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(height: 28, width: 160, base: base),
                    const SizedBox(height: 10),
                    _block(height: 14, width: 120, base: base),
                  ],
                ),
              ),
              _block(height: 40, width: 40, base: base, radius: 20),
            ],
          ),
          const SizedBox(height: 20),
          _block(height: 110, base: base, radius: 22),
          const SizedBox(height: 14),
          _block(height: 56, base: base, radius: 22),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _block(height: 96, base: base, radius: 18)),
              const SizedBox(width: 10),
              Expanded(child: _block(height: 96, base: base, radius: 18)),
              const SizedBox(width: 10),
              Expanded(child: _block(height: 96, base: base, radius: 18)),
            ],
          ),
          const SizedBox(height: 24),
          _block(height: 18, width: 140, base: base),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) =>
                  _block(height: 58, width: 58, base: base, radius: 29),
            ),
          ),
          const SizedBox(height: 20),
          _block(height: 18, width: 180, base: base),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _block(height: 88, base: base, radius: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _block({
    required Color base,
    double? height,
    double? width,
    double radius = 16,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
