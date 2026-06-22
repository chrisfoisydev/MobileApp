import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/becu_logo.dart';
import '../../widgets/surface_card.dart';

/// Manage Card tab: debit card artwork and the card controls list.
class ManageCardTab extends StatefulWidget {
  const ManageCardTab({super.key});

  @override
  State<ManageCardTab> createState() => _ManageCardTabState();
}

class _ManageCardTabState extends State<ManageCardTab> {
  bool _cardLocked = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        const _DebitCardArt(),
        const SizedBox(height: 24),
        const Text('Manage Cards', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          // Rows are not separated by per-row rules; a single divider sets
          // the card-identity rows apart from the controls (matching the
          // BECU design).
          child: Column(
            children: [
              const _ManageRow(
                label: 'John Smith',
                labelColor: AppColors.navy,
                trailing: Text(
                  '*5904',
                  style: TextStyle(fontSize: 14, color: AppColors.slate),
                ),
              ),
              const _ManageRow(
                label: 'Debit',
                labelColor: AppColors.slate,
                trailing: Text('Exp 03/29', style: TextStyle(fontSize: 15)),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.borderSubtle,
              ),
              _ManageRow(
                label: 'Card Lock',
                labelColor: AppColors.navy,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cardLocked ? 'Locked' : 'Unlocked',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.slate),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: _cardLocked,
                      activeTrackColor: AppColors.teal,
                      onChanged: (value) =>
                          setState(() => _cardLocked = value),
                    ),
                  ],
                ),
              ),
              const _ManageRow(
                label: 'Change PIN',
                labelColor: AppColors.navy,
                trailing:
                    Icon(Icons.edit_outlined, size: 20, color: AppColors.teal),
              ),
              const _ManageRow(
                label: 'Daily Access Limits',
                labelColor: AppColors.navy,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(r'$5,000', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.edit_outlined, size: 20, color: AppColors.teal),
                  ],
                ),
              ),
              const _ManageRow(
                label: 'Travel Notifications',
                labelColor: AppColors.navy,
                trailing: Icon(Icons.chevron_right, color: AppColors.teal),
              ),
              const _ManageRow(
                label: 'Download Statements',
                labelColor: AppColors.navy,
                trailing: Icon(Icons.chevron_right, color: AppColors.teal),
              ),
              const _ManageRow(
                label: 'Report Lost or Stolen',
                labelColor: AppColors.navy,
                trailing: Icon(Icons.chevron_right, color: AppColors.teal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.label,
    required this.labelColor,
    required this.trailing,
  });

  final String label;
  final Color labelColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: labelColor),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// The debit card hero. Uses the bundled BECU card image when present
/// (assets/images/becu_debit_card.png), falling back to a painted replica.
class _DebitCardArt extends StatelessWidget {
  const _DebitCardArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Standard payment-card proportions, matching the BECU card art.
      aspectRatio: 1.586,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/becu_debit_card.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const _PaintedDebitCard(),
        ),
      ),
    );
  }
}

class _PaintedDebitCard extends StatelessWidget {
  const _PaintedDebitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFA01B21),
            Color(0xFFA01B21),
            Color(0xFFD02A30),
            Color(0xFFD02A30),
          ],
          stops: [0.0, 0.32, 0.32, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: BecuLogo(height: 30, outlined: true),
          ),
          const Spacer(),
          const _ChipArt(),
          const SizedBox(height: 12),
          const Text(
            '5444 4812 3456 7891',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'VALID\nTHRU',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '03/26',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Text(
                'debit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'LEE M. CARDHOLDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const _MastercardMark(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipArt extends StatelessWidget {
  const _ChipArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7C76C), Color(0xFFC9A24B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9C7C35)),
      ),
    );
  }
}

/// The Mastercard mark — two overlapping circles directly on the card
/// (no white background), matching the BECU card art.
class _MastercardMark extends StatelessWidget {
  const _MastercardMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 28,
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: _Circle(color: Color(0xFFEB001B)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _Circle(color: const Color(0xFFF79E1B).withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
