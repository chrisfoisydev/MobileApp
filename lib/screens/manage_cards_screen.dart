import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/surface_card.dart';

/// A card shown in the Manage Cards list.
class _CardEntry {
  const _CardEntry(this.name, this.status, this.statusColor, this.colors);
  final String name;
  final String status;
  final Color statusColor;
  final List<Color> colors;
}

/// Manage Cards hub (reached from More → Manage Cards): the member's cards
/// with their status, plus common card actions.
class ManageCardsScreen extends StatelessWidget {
  const ManageCardsScreen({super.key});

  static const _green = Color(0xFF1E7B4D);
  static const _amber = Color(0xFFD98A1F);

  static const _cards = <_CardEntry>[
    _CardEntry('Credit Card ****9009', 'Needs to be activated', AppColors.teal,
        [Color(0xFF1B2A4A), Color(0xFF31497E)]),
    _CardEntry('Debit Card ****4344', 'Active', _green,
        [Color(0xFFA01B21), Color(0xFFD02A30)]),
    _CardEntry('Credit Card ****3222', 'Active', _green,
        [Color(0xFF1565C0), Color(0xFF2E7CF6)]),
    _CardEntry('Debit Card ****2112', 'In Transit', _amber,
        [Color(0xFF2B2B2B), Color(0xFF4A4A4A)]),
    _CardEntry('Debit Card ****1288', 'Cancelled', AppColors.becuRed,
        [Color(0xFF0A4A52), Color(0xFF007C89)]),
  ];

  void _notice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
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
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 18, color: AppColors.teal),
                      ),
                    ),
                    const Expanded(
                      child: Text('Manage Cards',
                          style: TextStyle(fontSize: 18)),
                    ),
                    IconButton(
                      onPressed: () => _notice(context, 'Notifications'),
                      icon: const Icon(Icons.notifications_none,
                          color: AppColors.navy),
                    ),
                    const ProfileMenuButton(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _Label('Cards'),
                for (final card in _cards) ...[
                  _CardRow(
                    card: card,
                    onTap: () => _notice(context, card.name),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                const _Label('Common actions'),
                _ActionRow(
                  icon: Icons.lock_outline,
                  label: 'Lock or unlock a card',
                  onTap: () => _notice(context, 'Lock or unlock a card'),
                ),
                const SizedBox(height: 12),
                _ActionRow(
                  icon: Icons.add_card_outlined,
                  label: 'Activate a new card',
                  onTap: () => _notice(context, 'Activate a new card'),
                ),
                const SizedBox(height: 12),
                _ActionRow(
                  icon: Icons.cached,
                  label: 'Replace a card',
                  onTap: () => _notice(context, 'Replace a card'),
                ),
                const SizedBox(height: 12),
                _ActionRow(
                  icon: Icons.dialpad,
                  label: 'Change PIN',
                  onTap: () => _notice(context, 'Change PIN'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.sectionLabel),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.onTap});

  final _CardEntry card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _CardThumb(colors: card.colors),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: card.statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      card.status,
                      style: TextStyle(fontSize: 13, color: card.statusColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.teal),
        ],
      ),
    );
  }
}

class _CardThumb extends StatelessWidget {
  const _CardThumb({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(7),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 12,
          height: 9,
          decoration: BoxDecoration(
            color: const Color(0xFFE7C76C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          const Icon(Icons.chevron_right, color: AppColors.teal),
        ],
      ),
    );
  }
}
