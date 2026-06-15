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
    return Row(
      children: [
        for (final (index, label) in tabs.indexed)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Container(
                height: 48,
                alignment: Alignment.center,
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
                    bottom: BorderSide(
                      color: index == selectedIndex
                          ? Colors.transparent
                          : AppColors.borderSubtle,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: index == selectedIndex
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
