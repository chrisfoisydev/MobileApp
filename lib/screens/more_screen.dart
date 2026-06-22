import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/surface_card.dart';
import 'move_money_screen.dart';
import 'payment_success_screen.dart';
import 'welcome_screen.dart';

/// The "More" hub reached from the bottom navigation: secondary options
/// including a preview of the payment-success celebration.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void _notice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _previewSuccess(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: r'$2,500.00',
          fromLabel: 'Joint Checking ...4567',
          toLabel: 'Mortgage Loan ...2345',
          dateLabel: 'June 14, 2026',
          onDone: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  void _onNavSelect(BuildContext context, int index, String label) {
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((r) => r.isFirst);
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MoveMoneyScreen()),
        );
      case 4:
        break; // already here
      default:
        _notice(context, label);
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
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text('More', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _Tile(
                  icon: Icons.celebration_outlined,
                  title: 'Payment success animation',
                  subtitle: 'Preview the celebration',
                  onTap: () => _previewSuccess(context),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Profile, security & preferences',
                  onTap: () => _notice(context, 'Settings'),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs and contact options',
                  onTap: () => _notice(context, 'Help & Support'),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.place_outlined,
                  title: 'Find a Branch or ATM',
                  subtitle: 'Locations near you',
                  onTap: () => _notice(context, 'Find a Branch or ATM'),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.gavel_outlined,
                  title: 'Legal & Privacy',
                  subtitle: 'Disclosures and policies',
                  onTap: () => _notice(context, 'Legal & Privacy'),
                ),
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.logout,
                  iconColor: AppColors.becuRed,
                  title: 'Log Out',
                  subtitle: 'Sign out of your account',
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            currentIndex: 4,
            onSelect: (i, label) => _onNavSelect(context, i, label),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AppColors.teal,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

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
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
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
