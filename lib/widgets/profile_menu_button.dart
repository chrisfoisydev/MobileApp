import 'package:flutter/material.dart';

import '../screens/my_profile_screen.dart';
import '../screens/welcome_screen.dart';
import '../theme/app_theme.dart';

/// The profile icon with its dropdown menu (My Profile, Messages, Approval
/// Requests, Security Center, Logout), anchored beneath the icon.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  static const _labels = {
    'messages': 'Messages',
    'approvals': 'Approval Requests',
    'alerts': 'Alerts & Notifications',
  };

  void _handle(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyProfileScreen()),
        );
      case 'logout':
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '${_labels[value] ?? value} is not part of this prototype.',
              ),
            ),
          );
    }
  }

  PopupMenuItem<String> _item(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: SizedBox(
        width: 220,
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.teal),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline, color: AppColors.navy),
      color: Colors.white,
      elevation: 8,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handle(context, value),
      itemBuilder: (context) => [
        _item('profile', 'My Profile'),
        const PopupMenuDivider(),
        _item('messages', 'Messages (2)'),
        const PopupMenuDivider(),
        _item('approvals', 'Approval Requests (2)'),
        const PopupMenuDivider(),
        _item('alerts', 'Alerts & Notifications'),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          height: 48,
          child: Center(
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.teal,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
