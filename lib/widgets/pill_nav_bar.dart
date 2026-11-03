import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PillNavItem {
  const PillNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Navigasi bawah berbentuk pill gelap yang "melayang".
class PillNavBar extends StatelessWidget {
  const PillNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33991E5A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Tooltip(
              message: items[i].label,
              child: InkWell(
                key: ValueKey('nav-$i'),
                customBorder: const CircleBorder(),
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == selectedIndex
                        ? AppColors.cherry
                        : const Color(0x1FFFFFFF),
                  ),
                  child: Icon(
                    items[i].icon,
                    color: i == selectedIndex ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
