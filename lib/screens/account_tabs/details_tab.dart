import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatting.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
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
        const Text(
          'Account Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(
                label: 'Account Name',
                value: account.officialName,
              ),
              _DetailRow(
                label: 'Nickname',
                value: account.nickname,
                trailing: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.teal),
              ),
              _DetailRow(label: 'Account Type', value: account.typeLabel),
              _DetailRow(
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
              _DetailRow(
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
        const Text(
          'Balance Info',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DetailRow(
                label: 'Current Posted Balance',
                value: formatCurrency(account.postedBalance),
              ),
              _DetailRow(
                label: 'Total Pending Transactions',
                value: formatCurrency(account.pendingTotal),
              ),
              _DetailRow(
                label: 'Available Balance',
                value: formatCurrency(account.availableBalance),
                showDivider: false,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'View Statements',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: AppColors.slate),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
