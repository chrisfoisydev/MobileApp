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
        const Text(
          'Manage Cards',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
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
              const Divider(height: 1, thickness: 4),
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
                showDivider: false,
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
    this.showDivider = true,
  });

  final String label;
  final Color labelColor;
  final Widget trailing;
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
                  style: TextStyle(fontSize: 16, color: labelColor),
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _DebitCardArt extends StatelessWidget {
  const _DebitCardArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 343 / 176,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ChipArt(),
                        const SizedBox(height: 10),
                        const Text(
                          '5444 4812 3456 7891',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'LEE M. CARDHOLDER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'debit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      _MastercardMark(),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipArt extends StatelessWidget {
  const _ChipArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
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

class _MastercardMark extends StatelessWidget {
  const _MastercardMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: SizedBox(
        width: 34,
        height: 20,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFEB001B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
