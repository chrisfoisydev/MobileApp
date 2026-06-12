import 'package:flutter/material.dart';

import '../../data/formatting.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/surface_card.dart';
import '../transaction_detail_screen.dart';

/// Transactions tab: search, pending list and completed history grouped
/// by month.
class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildSearchRow(),
        const SizedBox(height: 20),
        Text(
          'Pending (${pendingTransactions.length})',
          style: AppTextStyles.sectionLabel,
        ),
        const SizedBox(height: 12),
        for (final tx in pendingTransactions)
          _TransactionTile(transaction: tx, account: account),
        const SizedBox(height: 8),
        const Text('Completed', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 12),
        for (final group in completedGroups) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.monthBar,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              group.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
          for (final tx in group.transactions)
            _TransactionTile(transaction: tx, account: account),
        ],
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(color: AppColors.slate, fontSize: 16),
              suffixIcon: const Icon(Icons.search, color: AppColors.teal),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.tune, color: AppColors.teal),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.account});

  final BankTransaction transaction;
  final Account account;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              TransactionDetailScreen(transaction: tx, account: account),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tx.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(tx.icon, size: 22, color: tx.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.dateLabel,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.slate),
                ),
                const SizedBox(height: 2),
                Text(tx.title, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  tx.method,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 16),
              Text(
                formatCurrency(tx.amount, showPlus: true),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (tx.runningBalance != null) ...[
                const SizedBox(height: 4),
                Text(
                  formatCurrency(tx.runningBalance!),
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.slate),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
