import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/surface_card.dart';

/// My Profile: member identity, contact information, account activity and
/// security settings.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('My Profile', style: TextStyle(fontSize: 18)),
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle_outlined,
                        size: 56, color: AppColors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'John Smith',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text('Username1234',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.slate)),
                          SizedBox(height: 2),
                          Text('Last Login: May 01, 2025 at 10:30am',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.slate)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Contact Information'),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _ProfileRow(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: 'john.smith@email.com',
                      ),
                      _ProfileRow(
                        icon: Icons.smartphone_outlined,
                        label: 'Mobile number',
                        value: '+1 (918) 987-6543',
                      ),
                      _ProfileRow(
                        icon: Icons.push_pin_outlined,
                        label: 'Address',
                        value: '10880 Malibu Point #100b, Malibu, CA, '
                            '90265, US',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Account Activity'),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: const [
                      _ProfileRow(
                        icon: Icons.history,
                        label: 'Last log in',
                        value: 'May 01, 2025',
                      ),
                      _ProfileRow(
                        icon: Icons.person_outline,
                        label: 'Member since',
                        value: 'March 2019',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Security'),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileRow(
                        icon: Icons.fingerprint,
                        label: 'Biometric Login',
                        value: 'On',
                        showChevron: true,
                        onTap: () => _notice(context, 'Biometric settings'),
                      ),
                      _ProfileRow(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        showChevron: true,
                        showDivider: false,
                        onTap: () => _notice(context, 'Changing your password'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            currentIndex: -1,
            onSelect: (index, label) {
              if (index == 0) {
                Navigator.of(context).maybePop();
              } else {
                _notice(context, label);
              }
            },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.sectionLabel),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    this.value,
    this.showChevron = false,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool showChevron;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.teal),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, color: AppColors.navy),
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppColors.slate),
                ],
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
