import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/account_tab_bar.dart';
import '../widgets/becu_logo.dart';
import 'account_tabs/credit_details_tab.dart';
import 'account_tabs/transactions_tab.dart';

/// Credit card view: current balance, a single "Make A Payment" action and
/// the Transactions / Details tabs (Details carries payment terms and
/// credit limits rather than a routing number).
class CreditCardDetailScreen extends StatefulWidget {
  const CreditCardDetailScreen({
    super.key,
    required this.account,
    this.initialTab = 0,
  });

  final Account account;
  final int initialTab;

  @override
  State<CreditCardDetailScreen> createState() => _CreditCardDetailScreenState();
}

class _CreditCardDetailScreenState extends State<CreditCardDetailScreen> {
  static const _tabs = ['Transactions', 'Details'];

  late int _tabIndex = widget.initialTab;

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
                            account.officialName,
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
                    Text(
                      account.balanceLabel ?? 'Current Balance',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.slate),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Make A Payment is not part of this '
                                  'prototype.',
                                ),
                              ),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Make A Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
            child: _tabIndex == 0
                ? TransactionsTab(account: account)
                : CreditDetailsTab(account: account),
          ),
        ],
      ),
    );
  }
}
