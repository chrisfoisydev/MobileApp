import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import '../widgets/surface_card.dart';

/// Transfer flow. Step 1 ("To") picks the destination; selecting a BECU
/// account advances to step 2 ("From"), which records the destination under
/// the "To" step of the tracker and lists the remaining accounts to send
/// from.
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.initialToAccount});

  /// When set, the flow opens on the "From" step with this destination
  /// already chosen.
  final Account? initialToAccount;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late int _step = widget.initialToAccount == null ? 0 : 1;
  late Account? _toAccount = widget.initialToAccount;
  bool _becuExpanded = true;
  bool _externalExpanded = true;

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _selectTo(Account account) {
    setState(() {
      _toAccount = account;
      _step = 1;
    });
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step = 0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrom = _step == 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isFrom)
                        InkWell(
                          onTap: _back,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 18, color: AppColors.teal),
                          ),
                        ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, color: AppColors.navy),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isFrom
                        ? 'Where is the money from?'
                        : 'Where is the money going?',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Let's get the details for your transfer",
                    style: TextStyle(fontSize: 16, color: AppColors.navy),
                  ),
                  const SizedBox(height: 20),
                  _StepTracker(
                    activeStep: _step,
                    toLabel: _toAccount?.displayName,
                  ),
                  if (!isFrom) ...[
                    const SizedBox(height: 20),
                    _SearchField(onTap: () => _notice('Search')),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.pageBackground,
              child: isFrom ? _buildFromList() : _buildToList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SectionHeader(
          title: 'My BECU Accounts',
          expanded: _becuExpanded,
          onToggle: () => setState(() => _becuExpanded = !_becuExpanded),
        ),
        if (_becuExpanded)
          for (final account in checkingAndSavings)
            _AccountCard(account: account, onTap: () => _selectTo(account)),
        const SizedBox(height: 4),
        _SectionHeader(
          title: 'My External Accounts',
          expanded: _externalExpanded,
          onToggle: () =>
              setState(() => _externalExpanded = !_externalExpanded),
        ),
        if (_externalExpanded) ...[
          _ExternalCard(
            name: 'Chase Checking ...9534',
            onTap: () => _notice('External transfers'),
          ),
          _ExternalCard(
            name: 'Chase Savings ...0012',
            onTap: () => _notice('External transfers'),
          ),
        ],
        const SizedBox(height: 4),
        const _SectionHeader(title: 'People & Organizations'),
        SurfaceCard(
          onTap: () => _notice('Adding a recipient'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.north_east, color: AppColors.teal, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send money to a Person or Organization',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get started by providing their account information',
                      style: TextStyle(fontSize: 13, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFromList() {
    final fromAccounts = checkingAndSavings
        .where((a) => a.last4 != _toAccount?.last4)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _FdicNotice(),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'My BECU Accounts',
          expanded: _becuExpanded,
          onToggle: () => setState(() => _becuExpanded = !_becuExpanded),
        ),
        if (_becuExpanded)
          for (final account in fromAccounts)
            _AccountCard(
              account: account,
              onTap: () => _notice('Choosing an amount'),
            ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final Account account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          const BecuBadge(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              account.displayName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(account.availableBalance),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Available Balance',
                style: TextStyle(fontSize: 13, color: AppColors.slate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepTracker extends StatelessWidget {
  const _StepTracker({required this.activeStep, this.toLabel});

  final int activeStep;
  final String? toLabel;

  static const _labels = ['To', 'From', 'Amount', 'Date'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stepWidth = constraints.maxWidth / _labels.length;
        return Stack(
          children: [
            // Connector line behind the circles; teal up to the active step.
            Positioned(
              left: stepWidth / 2,
              right: stepWidth / 2,
              top: 14,
              child: Row(
                children: [
                  for (var i = 0; i < _labels.length - 1; i++)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: i < activeStep
                            ? AppColors.teal
                            : AppColors.borderSubtle,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _labels.length; i++)
                  SizedBox(
                    width: stepWidth,
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= activeStep
                                ? AppColors.teal
                                : Colors.white,
                            border: Border.all(
                              color: i <= activeStep
                                  ? AppColors.teal
                                  : AppColors.fieldBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: i <= activeStep
                                  ? Colors.white
                                  : AppColors.slate,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: i == activeStep
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: AppColors.navy,
                          ),
                        ),
                        if (i == 0 && toLabel != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: Text(
                              toLabel!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.teal,
                                height: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.teal, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Search Accounts & People',
                style: TextStyle(fontSize: 16, color: AppColors.slate),
              ),
            ),
            Icon(Icons.search, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}

class _FdicNotice extends StatelessWidget {
  const _FdicNotice();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: const [
          Text(
            'FDIC',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0A2E3C),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'FDIC-Insured - Backed by the full faith and credit of the '
              'U.S. Government',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.support,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.expanded, this.onToggle});

  final String title;
  final bool? expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.sectionLabel)),
          if (onToggle != null)
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
                  (expanded ?? true) ? Icons.expand_less : Icons.expand_more,
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

class _ExternalCard extends StatelessWidget {
  const _ExternalCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.north_east, color: AppColors.teal, size: 20),
          const SizedBox(width: 12),
          const Text(
            'External ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text('- $name', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
