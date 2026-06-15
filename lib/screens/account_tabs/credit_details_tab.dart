import 'package:flutter/material.dart';

import '../../data/formatting.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/detail_row.dart';
import '../../widgets/surface_card.dart';

/// Details tab for a credit card: identifiers, payment terms and credit
/// limits, plus balance-transfer / cash-advance requests.
class CreditDetailsTab extends StatefulWidget {
  const CreditDetailsTab({super.key, required this.account});

  final Account account;

  @override
  State<CreditDetailsTab> createState() => _CreditDetailsTabState();
}

class _CreditDetailsTabState extends State<CreditDetailsTab> {
  bool _showAccountNumber = false;

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final info = account.creditInfo!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text('Account Details', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DetailRow(label: 'Account Name', value: account.officialName),
              DetailRow(
                label: 'Nickname',
                value: account.nickname,
                trailing: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.teal),
              ),
              DetailRow(label: 'Account Type', value: account.typeLabel),
              DetailRow(
                label: 'Account Number',
                value: _showAccountNumber
                    ? '10528845${account.last4}'
                    : account.maskedNumber,
                showDivider: false,
                trailing: InkWell(
                  onTap: () => setState(() {
                    _showAccountNumber = !_showAccountNumber;
                  }),
                  child: Icon(
                    _showAccountNumber
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Payment Details', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DetailRow(
                label: 'Last Payment',
                value: formatCurrency(info.lastPayment),
              ),
              DetailRow(
                label: 'Amount Past Due',
                value: formatCurrency(info.amountPastDue),
              ),
              DetailRow(label: 'Next Payment Due', value: info.nextPaymentDue),
              DetailRow(
                label: 'Minimum Payment Due',
                value: formatCurrency(info.minimumPaymentDue),
              ),
              DetailRow(
                label: 'Autopay',
                value: formatCurrency(info.autopay),
                showDivider: false,
              ),
              DetailCardLink(
                'Set Up Autopay',
                onTap: () => _notice('Autopay setup'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Loan Info', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DetailRow(label: 'Interest Rate', value: info.interestRate),
              DetailRow(
                label: 'YTD Interest',
                value: formatCurrency(info.ytdInterest),
              ),
              DetailRow(
                label: 'Available Credit',
                value: formatCurrency(info.availableCredit),
              ),
              DetailRow(
                label: 'Credit Limit',
                value: formatCurrency(info.creditLimit),
                showDivider: false,
              ),
              DetailCardLink(
                'View Statements',
                onTap: () => _notice('Statements'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _RequestButton(
          label: 'Request Balance Transfer',
          onTap: () => _notice('Balance transfer'),
        ),
        const SizedBox(height: 12),
        _RequestButton(
          label: 'Request Cash Advance',
          onTap: () => _notice('Cash advance'),
        ),
      ],
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
