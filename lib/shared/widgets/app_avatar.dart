import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/user_profile.dart';

/// Telegram-style circular avatar: photo or colored initials disc.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.name = '',
    this.size = 48,
    this.status,
    this.showStatus = false,
    this.isGroup = false,
  });

  final String? url;
  final String name;
  final double size;
  final OnlineStatus? status;
  final bool showStatus;
  final bool isGroup;

  /// Telegram-like palette for placeholder discs.
  static const _palette = <Color>[
    Color(0xFFE17076),
    Color(0xFFFAA774),
    Color(0xFFE5C074),
    Color(0xFF7BC862),
    Color(0xFF6EC9CB),
    Color(0xFF65AADD),
    Color(0xFF7199E4),
    Color(0xFF8B7AE4),
    Color(0xFFD287BB),
    Color(0xFFE88A9A),
    Color(0xFFEE7AAE),
    Color(0xFF54B5E6),
    Color(0xFF40A7E3),
    Color(0xFF4FAE4E),
  ];

  static Color colorFor(String name) {
    if (name.isEmpty) return _palette.first;
    var hash = 0;
    for (final unit in name.codeUnits) {
      hash = 31 * hash + unit;
    }
    return _palette[hash.abs() % _palette.length];
  }

  /// Letters/digits only, 1–2 chars like Telegram.
  static String telegramInitials(String name, {bool isGroup = false}) {
    final buffer = StringBuffer();
    for (final rune in name.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r'[A-Za-zÀ-ÿА-Яа-яЁёЎўҚқҒғҲҳ0-9]').hasMatch(ch)) {
        buffer.write(ch);
      } else if (ch.trim().isEmpty && buffer.isNotEmpty) {
        buffer.write(' ');
      }
    }
    final cleaned = buffer.toString().trim();
    if (cleaned.isEmpty) return isGroup ? 'G' : '?';

    final parts =
        cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      final w = parts.first.toUpperCase();
      if (w.length >= 2) return w.substring(0, 2);
      return w;
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = colorFor(name.isEmpty ? '?' : name);
    final initials = telegramInitials(name, isGroup: isGroup);
    final hasPhoto = url != null && url!.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasPhoto ? Colors.transparent : bg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: url!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _initialsDisc(bg, initials),
                    errorWidget: (_, __, ___) => _initialsDisc(bg, initials),
                  )
                : _initialsDisc(bg, initials),
          ),
          if (showStatus && status != null && !isGroup)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: _statusColor(status!),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    width: size >= 48 ? 2.2 : 1.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initialsDisc(Color bg, String initials) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: bg,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1,
          letterSpacing: -0.4,
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
