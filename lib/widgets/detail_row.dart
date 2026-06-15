import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A label/value row inside a [SurfaceCard], with an optional trailing
/// action and a divider below. Shared by the account and credit detail tabs.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: AppColors.slate),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

/// The right-aligned teal link that closes a detail card
/// (e.g. "View Statements", "Set Up Autopay").
class DetailCardLink extends StatelessWidget {
  const DetailCardLink(this.label, {super.key, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onTap,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.teal,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
