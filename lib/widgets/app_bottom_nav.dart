import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The app's bottom navigation bar, shared across top-level screens.
/// [currentIndex] marks the active item; [onSelect] fires for every tap
/// (including the active item) with the tapped index and its label.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final void Function(int index, String label) onSelect;

  // (icon, label, showsNotificationBadge)
  static const items = <(IconData, String, bool)>[
    (Icons.account_balance_wallet_outlined, 'ACCOUNTS', false),
    (Icons.swap_horiz, 'MOVE MONEY', false),
    (Icons.chat_bubble_outline, 'CONTACT', true),
    (Icons.menu, 'MORE', false),
  ];

  /// Pale-teal wash behind the selected tab.
  static const _selectedFill = Color(0xFFEAF4F6);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (index, item) in items.indexed)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect(index, item.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    // Selected tab: pale-teal fill + a teal top rule + teal
                    // icon/label — applied uniformly to every footer item.
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? _selectedFill
                          : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: index == currentIndex
                              ? AppColors.teal
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavIcon(
                          icon: item.$1,
                          badge: item.$3,
                          selected: index == currentIndex,
                          badgeBorder: index == currentIndex
                              ? _selectedFill
                              : Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: index == currentIndex
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: index == currentIndex
                                ? AppColors.teal
                                : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A footer icon, optionally with a red notification dot (e.g. Contact).
class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.badge,
    required this.selected,
    required this.badgeBorder,
  });

  final IconData icon;
  final bool badge;
  final bool selected;
  final Color badgeBorder;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,
      size: 24,
      color: selected ? AppColors.teal : AppColors.ink,
    );
    if (!badge) return glyph;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        glyph,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.becuRed,
              shape: BoxShape.circle,
              border: Border.all(color: badgeBorder, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
