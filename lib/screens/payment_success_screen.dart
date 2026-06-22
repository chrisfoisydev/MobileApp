import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_theme.dart';
import '../widgets/surface_card.dart';

/// Celebratory confirmation shown after a transfer/payment is submitted.
/// Plays the BECU-colored "payment successful" Lottie once, then shows a
/// summary and a Done action.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.fromLabel,
    required this.toLabel,
    required this.dateLabel,
    this.onDone,
  });

  final String amount;
  final String fromLabel;
  final String toLabel;
  final String dateLabel;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      height: 180,
                      child: Lottie.asset(
                        'assets/lottie/payment_success.json',
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transfer is scheduled for $dateLabel.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.slate),
                    ),
                    const SizedBox(height: 24),
                    SurfaceCard(
                      child: Column(
                        children: [
                          _SuccessRow(
                            icon: Icons.attach_money,
                            label: 'Amount',
                            value: amount,
                          ),
                          _SuccessRow(
                            icon: Icons.south,
                            label: 'From',
                            value: fromLabel,
                          ),
                          _SuccessRow(
                            icon: Icons.north_east,
                            label: 'To',
                            value: toLabel,
                          ),
                          _SuccessRow(
                            icon: Icons.event_outlined,
                            label: 'Sending On',
                            value: dateLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Soft BECU-teal footer echoing the success wave.
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          onDone ?? () => Navigator.of(context).maybePop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.slate),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
