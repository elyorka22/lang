import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/safe_body.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockData.notifications;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeBody(
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = items[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primarySurface,
                child: Icon(
                  _icon(n.type),
                  color: AppColors.primaryDark,
                ),
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
              subtitle: Text(n.body),
              trailing: Text(
                n.createdAt.timeAgo,
                style: context.textTheme.labelSmall,
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add_alt_1;
      case 'daily_goal':
        return Icons.flag_outlined;
      case 'vocabulary':
        return Icons.menu_book_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
