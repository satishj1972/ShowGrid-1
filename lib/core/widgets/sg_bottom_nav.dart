// lib/core/widgets/sg_bottom_nav.dart
// ShowGrid Bottom Navigation - Matches HTML template exactly
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/sg_colors.dart';

class SGBottomNav extends StatelessWidget {
  final int currentIndex;

  const SGBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: SGColors.bottomNavBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SGColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, '🏠', 'Home', '/home'),
            _buildNavItem(context, 1, '🔍', 'Discover', '/discover'),
            _buildNavItem(context, 2, '⚡', 'Powerboard', '/powerboard'),
            _buildNavItem(context, 3, '👤', 'Profile', '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String icon, String label, String route) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                color: isActive ? SGColors.bottomNavActive : SGColors.bottomNavInactive,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
