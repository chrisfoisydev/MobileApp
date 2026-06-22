import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/account_tab_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/surface_card.dart';
import 'transfer_screen.dart';

/// Move Money hub: a grouped launcher of payment/transfer actions plus a
/// compact scheduled-activity summary. Details for scheduled transfers live
/// on the "Scheduled & History" tab.
class MoveMoneyScreen extends StatefulWidget {
  const MoveMoneyScreen({super.key});

  @override
  State<MoveMoneyScreen> createState() => _MoveMoneyScreenState();
}

class _MoveMoneyScreenState extends State<MoveMoneyScreen> {
  int _tabIndex = 0;

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _openTransfer() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransferScreen()),
    );
  }

  void _onNavSelect(int index, String label) {
    if (index == 0) {
      Navigator.of(context).maybePop();
    } else if (index != 1) {
      _notice(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Move Money', style: TextStyle(fontSize: 18)),
                    ),
                    IconButton(
                      onPressed: () => _notice('Notifications'),
                      icon: const Icon(Icons.notifications_none,
                          color: AppColors.navy),
                    ),
                    IconButton(
                      onPressed: () => _notice('Profile'),
                      icon: const Icon(Icons.person_outline,
                          color: AppColors.navy),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AccountTabBar(
            tabs: const ['Move Money', 'Scheduled & History'],
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          Expanded(
            child: _tabIndex == 0
                ? _buildMoveMoneyTab()
                : _buildScheduledTab(),
          ),
          AppBottomNav(currentIndex: 1, onSelect: _onNavSelect),
        ],
      ),
    );
  }

  Widget _buildMoveMoneyTab() {
    final total = checkingAndSavings.fold<double>(
        0, (sum, a) => sum + a.availableBalance);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _AvailableCard(amount: total),
        const SizedBox(height: 20),
        const _SectionLabel('Pay & Send'),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.receipt_long,
          title: 'Make a Payment',
          subtitle: 'Pay loans, credit cards & more',
          onTap: () => _notice('Make a Payment'),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          iconWidget: const Text(
            'Z',
            style: TextStyle(
              color: AppColors.zellePurple,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          iconBackground: const Color(0xFFECDDFF),
          title: 'Send with Zelle®',
          subtitle: 'Send money in minutes',
          onTap: () => _notice('Send a Zelle'),
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.document_scanner_outlined,
          title: 'Deposit a Check',
          subtitle: 'Snap a photo to deposit',
          onTap: () => _notice('Deposit Check'),
        ),
        const SizedBox(height: 24),
        const _SectionLabel('Transfer & Accounts'),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.swap_horiz,
          title: 'Transfer Between Accounts',
          subtitle: 'Move money between your accounts',
          onTap: _openTransfer,
        ),
        const SizedBox(height: 10),
        _MenuTile(
          icon: Icons.account_balance,
          title: 'Manage Linked Accounts',
          subtitle: 'Add or update external banks',
          onTap: () => _notice('Manage Linked Accounts'),
        ),
        const SizedBox(height: 24),
        _ScheduledSummary(onTap: () => setState(() => _tabIndex = 1)),
      ],
    );
  }

  Widget _buildScheduledTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: const [
        _ComingUpCard(),
        SizedBox(height: 16),
        Text(
          'Full transfer history is not part of this prototype.',
          style: TextStyle(fontSize: 14, color: AppColors.slate),
        ),
      ],
    );
  }
}

/// Total available balance across the member's BECU accounts.
class _AvailableCard extends StatelessWidget {
  const _AvailableCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available to move',
                style: TextStyle(fontSize: 13, color: AppColors.slate),
              ),
              const SizedBox(height: 2),
              Text(
                formatCurrency(amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionLabel);
  }
}

/// A uniform, tappable action row: icon, title, one-line subtitle, chevron.
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    this.icon,
    this.iconWidget,
    this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground ?? AppColors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: iconWidget ?? Icon(icon, color: AppColors.teal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.slate),
        ],
      ),
    );
  }
}

/// Slim summary of upcoming scheduled activity; taps through to the
/// "Scheduled & History" tab.
class _ScheduledSummary extends StatelessWidget {
  const _ScheduledSummary({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_outlined,
                color: Color(0xFFD98A1F), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 transfer scheduled',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  '\$1,250.00 to Chase Bank · Jun 14',
                  style: TextStyle(fontSize: 13, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.slate),
        ],
      ),
    );
  }
}

class _ComingUpCard extends StatelessWidget {
  const _ComingUpCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coming up in the next 5 days',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.north_east,
                    color: Color(0xFFD98A1F), size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To Chase Bank ...6789',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 2),
                    Text(
                      'From Joint Checking ...4567',
                      style: TextStyle(fontSize: 14, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '-\$1,250.00',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAB2024),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Sends Jun 14',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' - External transfers take 1–3 business days '
                      'after being sent',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}
