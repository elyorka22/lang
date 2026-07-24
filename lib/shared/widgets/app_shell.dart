import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/locale_provider.dart';

/// Bottom navigation — Home · Words · Practice · Games · Profile.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final index = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.border,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _onTap,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 420),
            destinations: [
              _dest(
                selected: index == 0,
                label: s.navHome,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
              ),
              _dest(
                selected: index == 1,
                label: s.navWords,
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book_rounded,
              ),
              _dest(
                selected: index == 2,
                label: s.navPractice,
                icon: Icons.style_outlined,
                selectedIcon: Icons.style_rounded,
              ),
              _dest(
                selected: index == 3,
                label: s.navGames,
                icon: Icons.sports_esports_outlined,
                selectedIcon: Icons.sports_esports_rounded,
              ),
              _dest(
                selected: index == 4,
                label: s.navProfile,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _dest({
    required bool selected,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    return NavigationDestination(
      label: label,
      icon: AnimatedScale(
        scale: selected ? 1.0 : 0.92,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Icon(icon),
      ),
      selectedIcon: AnimatedScale(
        scale: selected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: Icon(selectedIcon, color: AppColors.primary),
      ),
    );
  }
}
