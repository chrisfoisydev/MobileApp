import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

/// Goal detail, shown as a bottom sheet when a goal bucket is tapped:
/// progress, quick actions, contribution/target details and a projected
/// completion date.
class GoalDetailSheet extends StatelessWidget {
  const GoalDetailSheet({super.key, required this.bucket});

  final SavingsBucket bucket;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static Future<void> show(BuildContext context, SavingsBucket bucket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalDetailSheet(bucket: bucket),
    );
  }

  void _notice(BuildContext context, String feature) {
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  /// Projected completion as "Month Year", from June 2026 at the current
  /// monthly contribution.
  String get _reachBy {
    final monthly = bucket.monthlyContribution ?? 0;
    final remaining = (bucket.goal ?? 0) - bucket.saved;
    if (monthly <= 0 || remaining <= 0) return '—';
    final months = (remaining / monthly).ceil();
    final index = (6 - 1) + months; // June 2026 baseline
    final year = 2026 + index ~/ 12;
    return '${_months[index % 12]} $year';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (bucket.progress * 100).round();
    final toGo = (bucket.goal ?? 0) - bucket.saved;
    final monthly = bucket.monthlyContribution;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bucket.emoji ?? '🎯',
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bucket.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          if (bucket.daysLeft != null)
                            Text(
                              bucket.daysLeft!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.slate),
                            ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: AppColors.teal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatCurrency(bucket.saved),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E2150),
                      ),
                    ),
                    Text(
                      ' / ${formatCurrency(bucket.goal ?? 0)}',
                      style:
                          const TextStyle(fontSize: 16, color: AppColors.slate),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: bucket.progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFD7CCEE),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF2E2150)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$pct% saved',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formatCurrency(toGo)} to go',
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.slate),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _ActionCard(
                      icon: Icons.add,
                      label: 'Add Funds',
                      color: AppColors.teal,
                      onTap: () => _notice(context, 'Adding funds'),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.edit_outlined,
                      label: 'Edit Goal',
                      color: AppColors.teal,
                      onTap: () => _notice(context, 'Editing the goal'),
                    ),
                    const SizedBox(width: 12),
                    _ActionCard(
                      icon: Icons.delete_outline,
                      label: 'Remove',
                      color: AppColors.becuRed,
                      onTap: () => _notice(context, 'Removing the goal'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Monthly Contribution',
                        value: monthly == null
                            ? '—'
                            : '${formatCurrency(monthly)}/mo',
                      ),
                      _DetailRow(
                        label: 'On track to reach goal',
                        value: _reachBy,
                      ),
                      _DetailRow(
                        label: 'Target Amount',
                        value: formatCurrency(bucket.goal ?? 0),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                if (monthly != null && _reachBy != '—') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A4A52),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "At ${formatCurrency(monthly)}/mo you'll reach "
                          'your goal by',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _reachBy,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, color: AppColors.slate),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
