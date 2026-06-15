import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/account_tab_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/surface_card.dart';
import 'transfer_screen.dart';

/// Move Money hub: payment/transfer entry tiles, an upcoming-transfer
/// summary and a Quick Transfer panel.
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
                : _buildPlaceholderTab(),
          ),
          AppBottomNav(currentIndex: 1, onSelect: _onNavSelect),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Scheduled transfers and history are not part of this prototype.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.slate, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildMoveMoneyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ActionTile(
          icon: Icons.receipt_long,
          iconColor: AppColors.teal,
          iconBackground: AppColors.teal.withValues(alpha: 0.10),
          title: 'Make a Payment',
          subtitle: 'Pay loans, credit cards & more',
          onTap: () => _notice('Make a Payment'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CompactTile(
                icon: Icons.document_scanner_outlined,
                iconColor: const Color(0xFF1E7B4D),
                iconBackground: const Color(0xFFEAF9E6),
                label: 'Deposit Check',
                onTap: () => _notice('Deposit Check'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CompactTile(
                iconWidget: const Text(
                  'Z',
                  style: TextStyle(
                    color: AppColors.zellePurple,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                iconBackground: const Color(0xFFECDDFF),
                label: 'Send a Zelle',
                onTap: () => _notice('Send a Zelle'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ActionTile(
          icon: Icons.swap_horiz,
          iconColor: AppColors.becuRed,
          iconBackground: const Color(0xFFFBE1C3),
          title: 'Transfer Between Accounts',
          subtitle: 'Move funds between your BECU accounts instantly',
          onTap: _openTransfer,
        ),
        const SizedBox(height: 16),
        _ActionTile(
          icon: Icons.account_balance,
          iconColor: const Color(0xFF328ECD),
          iconBackground: const Color(0xFF328ECD).withValues(alpha: 0.10),
          title: 'Manage Linked Accounts',
          subtitle: 'Add or update accounts from other banks',
          onTap: () => _notice('Manage Linked Accounts'),
        ),
        const SizedBox(height: 24),
        const _ComingUpCard(),
        const SizedBox(height: 16),
        _QuickTransferCard(onNotice: _notice),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
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
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
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
                  style: const TextStyle(fontSize: 14, color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  const _CompactTile({
    this.icon,
    this.iconWidget,
    this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final Color iconBackground;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: iconWidget ?? Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
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

class _QuickTransferCard extends StatelessWidget {
  const _QuickTransferCard({required this.onNotice});

  final void Function(String) onNotice;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Transfer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _AccountSelector(
            label: 'From',
            iconColor: const Color(0xFF776F66),
            name: 'Joint Savings ...3456',
            balance: '\$34,145.89',
            onTap: () => onNotice('Account selection'),
          ),
          const SizedBox(height: 10),
          _AccountSelector(
            label: 'To',
            iconColor: AppColors.teal,
            name: 'Joint Checking ...4567',
            balance: '\$8,122.10',
            onTap: () => onNotice('Account selection'),
          ),
          const SizedBox(height: 12),
          const Text('Amount',
              style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 8),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.fieldBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('\$', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    '0.00',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16, color: AppColors.slate),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('When',
              style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 8),
          Row(
            children: [
              _WhenChip(label: 'Today', selected: true, onTap: () {}),
              const SizedBox(width: 8),
              _WhenChip(
                  label: 'Tomorrow',
                  selected: false,
                  onTap: () => onNotice('Scheduling')),
              const SizedBox(width: 8),
              _WhenChip(
                  label: 'Schedule',
                  selected: false,
                  onTap: () => onNotice('Scheduling')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => onNotice('Make Transfer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Make Transfer',
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
    );
  }
}

class _AccountSelector extends StatelessWidget {
  const _AccountSelector({
    required this.label,
    required this.iconColor,
    required this.name,
    required this.balance,
    required this.onTap,
  });

  final String label;
  final Color iconColor;
  final String name;
  final String balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sync_alt,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        balance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.slate),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WhenChip extends StatelessWidget {
  const _WhenChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: selected
            ? ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: AppColors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }
}
