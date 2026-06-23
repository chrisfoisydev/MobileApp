import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/becu_logo.dart';
import '../widgets/cascade_in.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/surface_card.dart';
import 'account_detail_screen.dart';
import 'credit_card_detail_screen.dart';
import 'more_screen.dart';
import 'move_money_screen.dart';
import 'transfer_screen.dart';

/// Account summary: greeting header, quick actions, account groups and
/// the bottom navigation bar.
class AccountSummaryScreen extends StatefulWidget {
  const AccountSummaryScreen({super.key});

  @override
  State<AccountSummaryScreen> createState() => _AccountSummaryScreenState();
}

class _AccountSummaryScreenState extends State<AccountSummaryScreen> {
  bool _checkingExpanded = true;

  void _openAccount(Account account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => account.kind == AccountKind.creditCard
            ? CreditCardDetailScreen(account: account)
            : AccountDetailScreen(account: account),
      ),
    );
  }

  void _showPrototypeNotice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _openMoveMoney() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MoveMoneyScreen()),
    );
  }

  void _openTransfer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransferScreen()),
    );
  }

  void _onNavSelect(int index, String label) {
    if (index == 1) {
      _openMoveMoney();
    } else if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MoreScreen()),
      );
    } else if (index != 0) {
      _showPrototypeNotice(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                CascadeIn(
                  key: const ValueKey('quick-actions'),
                  index: 0,
                  child: _buildQuickActions(),
                ),
                const SizedBox(height: 24),
                CascadeIn(
                  key: const ValueKey('checking-header'),
                  index: 1,
                  child: _SectionHeader(
                    title:
                        'Checking & Savings (${checkingAndSavings.length})',
                    expanded: _checkingExpanded,
                    onToggle: () => setState(() {
                      _checkingExpanded = !_checkingExpanded;
                    }),
                  ),
                ),
                if (_checkingExpanded)
                  for (final (i, account) in checkingAndSavings.indexed)
                    CascadeIn(
                      key: ValueKey('cs-${account.last4}'),
                      index: 2 + i,
                      child: _LabeledBalanceCard(
                        account: account,
                        label: 'Available Balance',
                        onTap: () => _openAccount(account),
                      ),
                    ),
                const SizedBox(height: 12),
                CascadeIn(
                  key: const ValueKey('credit-header'),
                  index: 5,
                  child: _SectionHeader(
                      title: 'Credit Cards (${creditCards.length})'),
                ),
                for (final (i, account) in creditCards.indexed)
                  CascadeIn(
                    key: ValueKey('cc-${account.last4}'),
                    index: 6 + i,
                    child: _LabeledBalanceCard(
                      account: account,
                      label: account.balanceLabel ?? 'Current Balance',
                      onTap: () => _openAccount(account),
                    ),
                  ),
                const SizedBox(height: 12),
                CascadeIn(
                  key: const ValueKey('loans-header'),
                  index: 7 + creditCards.length,
                  child: _SectionHeader(title: 'Loans (${loans.length})'),
                ),
                for (final (i, account) in loans.indexed)
                  CascadeIn(
                    key: ValueKey('loan-${account.last4}'),
                    index: 8 + creditCards.length + i,
                    child: _LabeledBalanceCard(
                      account: account,
                      label: account.balanceLabel ?? 'Current Balance',
                      onTap: () => _openAccount(account),
                    ),
                  ),
              ],
            ),
          ),
          AppBottomNav(currentIndex: 0, onSelect: _onNavSelect),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
                  const Expanded(
                    child: Text('Accounts', style: TextStyle(fontSize: 18)),
                  ),
                  IconButton(
                    onPressed: () => _showPrototypeNotice('Notifications'),
                    icon: const Icon(Icons.notifications_none,
                        color: AppColors.navy),
                  ),
                  const ProfileMenuButton(),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Good Afternoon,\nJohn',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 36 / 28,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: BecuLogo(height: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickAction(
          label: 'Transfer',
          onTap: _openTransfer,
          child: const Icon(Icons.swap_horiz, color: AppColors.teal, size: 28),
        ),
        _QuickAction(
          label: 'Zelle',
          onTap: () => _showPrototypeNotice('Zelle'),
          child: const Text(
            'Z',
            style: TextStyle(
              color: AppColors.zellePurple,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _QuickAction(
          label: 'Pay Credit Card',
          onTap: () => _showPrototypeNotice('Pay Credit Card'),
          child:
              const Icon(Icons.credit_card, color: AppColors.teal, size: 26),
        ),
        _QuickAction(
          label: 'Add Actions',
          onTap: () => _showPrototypeNotice('Add Actions'),
          child: const Icon(Icons.add, color: AppColors.teal, size: 28),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.child,
    required this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.support),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.expanded, this.onToggle});

  final String title;
  final bool? expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.sectionLabel),
          ),
          if (onToggle != null)
            InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.teal, width: 1.5),
                ),
                child: Icon(
                  (expanded ?? true) ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.teal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card with the balance caption (e.g. "Current Balance") used by the
/// credit card and loan sections.
class _LabeledBalanceCard extends StatelessWidget {
  const _LabeledBalanceCard({
    required this.account,
    required this.label,
    required this.onTap,
  });

  final Account account;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          const BecuBadge(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              account.displayName,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(account.availableBalance),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.slate),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

