import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../models/user_profile.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.name = '',
    this.size = 48,
    this.status,
    this.showStatus = false,
  });

  final String? url;
  final String name;
  final double size;
  final OnlineStatus? status;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: url != null && url!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: url!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _fallback(isDark),
                    errorWidget: (_, __, ___) => _fallback(isDark),
                  )
                : _fallback(isDark),
          ),
          if (showStatus && status != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: _statusColor(status!),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(bool isDark) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.primarySurface,
      child: Text(
        name.initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Color _statusColor(OnlineStatus s) {
    switch (s) {
      case OnlineStatus.online:
        return AppColors.online;
      case OnlineStatus.away:
        return AppColors.away;
      case OnlineStatus.offline:
        return AppColors.offline;
    }
  }
}
