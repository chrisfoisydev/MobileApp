import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The segmented tab strip used by the account and credit card detail
/// screens: the selected tab reads as white with a red top rule.
class AccountTabBar extends StatelessWidget {
  const AccountTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final (index, label) in tabs.indexed)
            InkWell(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                // Tabs size to their label, with padding so longer labels
                // (e.g. "Savings Buckets (2)") aren't squished.
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? AppColors.pageBackground
                      : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: index == selectedIndex
                          ? AppColors.becuRed
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  // Inherit the themed font family, only overriding size /
                  // weight / color.
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 14,
                        fontWeight: index == selectedIndex
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: AppColors.navy,
                      ),
                  child: Text(label),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
