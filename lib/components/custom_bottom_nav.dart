import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/screens/home/home_screen.dart';
import 'package:mindmesh/themes/app_theme.dart';

class CustomBottomNav extends ConsumerWidget {
  const CustomBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
                selectedIndex: selectedTab,
                onTap: () => ref.read(selectedTabProvider.notifier).state = 0,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.lightbulb_outline,
                activeIcon: Icons.lightbulb,
                label: 'Thoughts',
                index: 1,
                selectedIndex: selectedTab,
                onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.bubble_chart_outlined,
                activeIcon: Icons.bubble_chart,
                label: 'Mind Map',
                index: 2,
                selectedIndex: selectedTab,
                onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                selectedIndex: selectedTab,
                onTap: () => ref.read(selectedTabProvider.notifier).state = 3,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final isSelected = index == selectedIndex;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? isDarkMode
                ? AppColors.primaryDark.withOpacity(0.2)
                : AppColors.primaryLight.withOpacity(0.15)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected 
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}