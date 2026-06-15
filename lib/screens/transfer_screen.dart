import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import '../widgets/surface_card.dart';

/// Transfer flow, step 1 ("To"): pick where the money is going from BECU
/// accounts, external accounts, or people & organizations.
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  bool _becuExpanded = true;
  bool _externalExpanded = true;

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  @override
  Widget build(BuildContext context) {
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: AppColors.navy),
                      ),
                    ),
                  ),
                  const Text(
                    'Where is the money going?',
                    style: TextStyle(
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
                  const _StepTracker(activeStep: 0),
                  const SizedBox(height: 20),
                  _SearchField(onTap: () => _notice('Search')),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.pageBackground,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _SectionHeader(
                    title: 'My BECU Accounts',
                    expanded: _becuExpanded,
                    onToggle: () =>
                        setState(() => _becuExpanded = !_becuExpanded),
                  ),
                  if (_becuExpanded)
                    for (final account in checkingAndSavings)
                      SurfaceCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () => _notice('Selecting a destination'),
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
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.slate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 4),
                  _SectionHeader(
                    title: 'My External Accounts',
                    expanded: _externalExpanded,
                    onToggle: () => setState(
                        () => _externalExpanded = !_externalExpanded),
                  ),
                  if (_externalExpanded) ...[
                    _ExternalCard(
                      name: 'Chase Checking ...9534',
                      onTap: () => _notice('Selecting a destination'),
                    ),
                    _ExternalCard(
                      name: 'Chase Savings ...0012',
                      onTap: () => _notice('Selecting a destination'),
                    ),
                  ],
                  const SizedBox(height: 4),
                  const _SectionHeader(title: 'People & Organizations'),
                  SurfaceCard(
                    onTap: () => _notice('Adding a recipient'),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.north_east,
                            color: AppColors.teal, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Send money to a Person or Organization',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Get started by providing their account '
                                'information',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTracker extends StatelessWidget {
  const _StepTracker({required this.activeStep});

  final int activeStep;

  static const _labels = ['To', 'From', 'Amount', 'Date'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == activeStep ? AppColors.teal : Colors.white,
                  border: Border.all(
                    color: i == activeStep
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
                    color: i == activeStep ? Colors.white : AppColors.slate,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      i == activeStep ? FontWeight.w700 : FontWeight.w400,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          if (i < _labels.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(height: 1.5, color: AppColors.borderSubtle),
              ),
            ),
        ],
      ],
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
          Text(
            'External ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              '- $name',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
