import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatting.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/detail_row.dart';
import '../../widgets/surface_card.dart';

/// Details tab: account identifiers and balance breakdown.
class DetailsTab extends StatefulWidget {
  const DetailsTab({super.key, required this.account});

  final Account account;

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  bool _showAccountNumber = false;

  Future<void> _copyRoutingNumber() async {
    await Clipboard.setData(ClipboardData(text: widget.account.routingNumber));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Routing number copied.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text('Account Details', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DetailRow(
                label: 'Account Name',
                value: account.officialName,
              ),
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
              DetailRow(
                label: 'Routing Number',
                value: account.routingNumber,
                showDivider: false,
                trailing: InkWell(
                  onTap: _copyRoutingNumber,
                  child: const Icon(Icons.copy_outlined,
                      size: 20, color: AppColors.teal),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Balance Info', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DetailRow(
                label: 'Current Posted Balance',
                value: formatCurrency(account.postedBalance),
              ),
              DetailRow(
                label: 'Total Pending Transactions',
                value: formatCurrency(account.pendingTotal),
              ),
              DetailRow(
                label: 'Available Balance',
                value: formatCurrency(account.availableBalance),
                showDivider: false,
              ),
              const DetailCardLink('View Statements'),
            ],
          ),
        ),
      ],
    );
  }
}
