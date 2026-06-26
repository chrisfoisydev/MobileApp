import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/surface_card.dart';
import 'manage_cards_screen.dart';
import 'move_money_screen.dart';

/// The "More" hub reached from the bottom navigation: secondary services
/// grouped into a top list plus collapsible "Manage" and "Personalization"
/// sections.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _manageExpanded = true;
  bool _personalizationExpanded = true;

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _onNavSelect(int index, String label) {
    switch (index) {
      case 0:
        Navigator.of(context).popUntil(ModalRoute.withName('/accounts'));
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MoveMoneyScreen()),
        );
      case 3:
        break; // already here
      default:
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
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('More', style: TextStyle(fontSize: 18)),
                    ),
                    IconButton(
                      onPressed: () => _notice('Notifications'),
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
                _MoreRow(
                  label: 'Statements & Documents',
                  onTap: () => _notice('Statements & Documents'),
                ),
                const SizedBox(height: 12),
                _MoreRow(
                  label: 'Fraud Claims & Disputes',
                  onTap: () => _notice('Fraud Claims & Disputes'),
                ),
                const SizedBox(height: 12),
                _MoreRow(
                  label: 'Manage Cards',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ManageCardsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MoreRow(
                  label: 'Stop Checks',
                  onTap: () => _notice('Stop Checks'),
                ),
                const SizedBox(height: 12),
                _MoreRow(
                  label: 'BECU Locations',
                  trailing: const Icon(Icons.place_outlined,
                      color: AppColors.teal, size: 20),
                  onTap: () => _notice('BECU Locations'),
                ),
                const SizedBox(height: 12),
                _MoreRow(
                  label: 'Call BECU',
                  trailing:
                      const Icon(Icons.phone, color: AppColors.teal, size: 20),
                  onTap: () => _notice('Call BECU'),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Manage',
                  expanded: _manageExpanded,
                  onToggle: () =>
                      setState(() => _manageExpanded = !_manageExpanded),
                ),
                if (_manageExpanded) ...[
                  _MoreRow(
                    label: 'Contacts',
                    onTap: () => _notice('Contacts'),
                  ),
                  const SizedBox(height: 12),
                  _MoreRow(
                    label: 'Linked Accounts',
                    onTap: () => _notice('Linked Accounts'),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Personalization',
                  expanded: _personalizationExpanded,
                  onToggle: () => setState(
                      () => _personalizationExpanded = !_personalizationExpanded),
                ),
                if (_personalizationExpanded) ...[
                  _MoreRow(
                    label: 'Theme',
                    trailing: _ValueEdit(value: 'Light'),
                    onTap: () => _notice('Theme'),
                  ),
                  const SizedBox(height: 12),
                  _MoreRow(
                    label: 'Text Size',
                    trailing: _ValueEdit(value: 'Standard'),
                    onTap: () => _notice('Text Size'),
                  ),
                ],
              ],
            ),
          ),
          AppBottomNav(currentIndex: 3, onSelect: _onNavSelect),
        ],
      ),
    );
  }
}

/// A single white row: a label on the left and a trailing widget (a teal
/// chevron by default).
class _MoreRow extends StatelessWidget {
  const _MoreRow({required this.label, required this.onTap, this.trailing});

  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          trailing ??
              const Icon(Icons.chevron_right, color: AppColors.teal),
        ],
      ),
    );
  }
}

class _ValueEdit extends StatelessWidget {
  const _ValueEdit({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teal),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.edit_outlined, color: AppColors.teal, size: 18),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.sectionLabel)),
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
                expanded ? Icons.expand_less : Icons.expand_more,
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
