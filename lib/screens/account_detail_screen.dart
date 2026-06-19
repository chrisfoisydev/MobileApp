import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/account_tab_bar.dart';
import '../widgets/becu_logo.dart';
import '../widgets/tab_content_switcher.dart';
import 'account_tabs/details_tab.dart';
import 'account_tabs/manage_card_tab.dart';
import 'account_tabs/transactions_tab.dart';

/// Account view: balance header, action buttons and a tab switcher.
/// Checking/credit accounts show Transactions, Manage Card and Details;
/// savings accounts have no card to manage, so they show Transactions and
/// Details only.
class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({
    super.key,
    required this.account,
    this.initialTab = 0,
  });

  final Account account;
  final int initialTab;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late final bool _isSavings = widget.account.kind == AccountKind.savings;

  late final List<String> _tabs = _isSavings
      ? const ['Transactions', 'Details']
      : const ['Transactions', 'Manage Card', 'Details'];

  late int _tabIndex = widget.initialTab;

  Widget _tabContent(Account account) {
    // Savings: [Transactions, Details]. Others: [Transactions, Manage Card,
    // Details].
    if (_isSavings) {
      return _tabIndex == 0
          ? TransactionsTab(account: account)
          : DetailsTab(account: account);
    }
    return switch (_tabIndex) {
      0 => TransactionsTab(account: account),
      1 => const ManageCardTab(),
      _ => DetailsTab(account: account),
    };
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 18, color: AppColors.navy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const BecuBadge(size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            account.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      formatCurrency(account.availableBalance),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Available Balance',
                      style: TextStyle(fontSize: 16, color: AppColors.slate),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.swap_horiz,
                            label: 'Transfer Funds',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.grid_view,
                            label: 'Deposit Check',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AccountTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onChanged: (index) => setState(() => _tabIndex = index),
          ),
          Expanded(
            child: TabContentSwitcher(
              index: _tabIndex,
              child: _tabContent(account),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('$label is not part of this prototype.')),
            );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.teal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 20, color: AppColors.teal),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

