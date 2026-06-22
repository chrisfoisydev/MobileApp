import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/detail_row.dart';
import '../widgets/payment_flow_widgets.dart';
import '../widgets/surface_card.dart';
import 'payment_success_screen.dart';

/// A payment option on the Amount step (a preset balance or "Other Amount").
class _PayOption {
  const _PayOption(this.label, this.subtitle, this.cents);
  final String label;
  final String subtitle;

  /// Fixed amount in cents; null means "Other Amount" (typed via the keypad).
  final int? cents;
}

/// Make a Payment flow: To → From → Amount → Date, then a review. Mirrors the
/// transfer stepper but lets you pay a preset balance (statement / minimum /
/// current) on a credit card, and surfaces the payment due date.
class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({
    super.key,
    this.initialStep = 0,
    this.initialToAccount,
    this.initialFromAccount,
    this.initialOption,
    this.initialOtherCents = 0,
    this.initialSelectedDay,
    this.initialKeypadOpen = false,
  });

  final int initialStep;
  final Account? initialToAccount;
  final Account? initialFromAccount;
  final int? initialOption;
  final int initialOtherCents;
  final int? initialSelectedDay;
  final bool initialKeypadOpen;

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  late int _step = widget.initialStep;
  bool _forward = true;
  late Account? _toAccount = widget.initialToAccount;
  late Account? _fromAccount = widget.initialFromAccount;
  late int? _selectedOption = widget.initialOption;
  late int _otherCents = widget.initialOtherCents;
  late int? _selectedDay = widget.initialSelectedDay;
  late bool _keypadVisible = widget.initialKeypadOpen;
  final FocusNode _amountFocus = FocusNode();

  static const _todayDay = 8;

  bool _becuExpanded = true;
  bool _externalExpanded = true;

  @override
  void dispose() {
    _amountFocus.dispose();
    super.dispose();
  }

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  void _goToStep(int next) => setState(() {
        _forward = next >= _step;
        _step = next;
      });

  void _selectTo(Account account) {
    _toAccount = account;
    _selectedOption = null;
    _goToStep(1);
  }

  void _selectFrom(Account account) {
    _fromAccount = account;
    _goToStep(2);
  }

  // --- Amount options ---------------------------------------------------

  List<_PayOption> _options() {
    final to = _toAccount;
    if (to == null) return const [];
    final current = (to.availableBalance * 100).round();
    if (to.kind == AccountKind.creditCard) {
      final statement = (to.postedBalance * 100).round();
      final minDue = to.creditInfo?.minimumPaymentDue ?? 0;
      final minCents = minDue > 0
          ? (minDue * 100).round()
          : (to.availableBalance * 0.02 * 100).round().clamp(2500, current);
      return [
        _PayOption(
          'Statement Balance',
          'Avoid late charges on purchases included in your last statement.',
          statement,
        ),
        _PayOption(
          'Minimum Payment',
          'Avoid late fees. You may continue to accrue interest.',
          minCents,
        ),
        _PayOption(
          'Current Balance',
          'Pay your balance in full. Your ${to.nickname} balance will be '
              '\$0.00.',
          current,
        ),
        const _PayOption('Other Amount', '', null),
      ];
    }
    return [
      _PayOption('Current Balance', 'Pay your remaining balance.', current),
      const _PayOption('Other Amount', '', null),
    ];
  }

  int get _amountCents {
    final opts = _options();
    final sel = _selectedOption;
    if (sel == null || sel >= opts.length) return 0;
    return opts[sel].cents ?? _otherCents;
  }

  bool get _optionIsOther {
    final opts = _options();
    final sel = _selectedOption;
    return sel != null && sel < opts.length && opts[sel].cents == null;
  }

  void _selectOption(int i) {
    setState(() {
      _selectedOption = i;
      _keypadVisible = _options()[i].cents == null;
    });
    if (_keypadVisible) _amountFocus.requestFocus();
  }

  void _tapDigit(int d) =>
      setState(() => _otherCents = (_otherCents * 10 + d).clamp(0, 99999999));

  void _backspace() => setState(() => _otherCents ~/= 10);

  KeyEventResult _handleAmountKey(FocusNode node, KeyEvent event) {
    if (!_optionIsOther) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final ch = event.character;
    if (ch != null && ch.length == 1) {
      final code = ch.codeUnitAt(0);
      if (code >= 0x30 && code <= 0x39) {
        _tapDigit(code - 0x30);
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // --- Due date ---------------------------------------------------------

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  ({String label, int? juneDay}) get _due {
    final raw = _toAccount?.creditInfo?.nextPaymentDue; // MM/DD/YYYY
    if (raw == null) return (label: 'the due date', juneDay: null);
    final parts = raw.split('/');
    if (parts.length != 3) return (label: raw, juneDay: null);
    final m = int.tryParse(parts[0]) ?? 1;
    final d = int.tryParse(parts[1]) ?? 1;
    final y = parts[2];
    return (
      label: '${_months[(m - 1).clamp(0, 11)]} $d, $y',
      juneDay: m == 6 ? d : null,
    );
  }

  void _back() {
    if (_step > 0) {
      _goToStep(_step - 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _confirm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: formatCurrency(_amountCents / 100),
          fromLabel: _fromAccount?.displayName ?? '',
          toLabel: _toAccount?.displayName ?? '',
          dateLabel: 'June ${_selectedDay ?? _todayDay}, 2026',
          onDone: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }

  String get _title => switch (_step) {
        0 => 'Where is the money going?',
        1 => 'Where is the money from?',
        2 => 'How much would you like to pay on your '
            '${_toAccount?.nickname ?? 'account'}?',
        3 => 'Almost done, John!\nWhen do you want to pay?',
        _ => "Let's confirm everything looks good to you.",
      };

  @override
  Widget build(BuildContext context) {
    final showSubtitle = _step <= 1;
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
                      if (_step > 0)
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _title,
                      key: ValueKey(_title),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 4),
                    const Text(
                      "Let's get the details for your payment",
                      style: TextStyle(fontSize: 16, color: AppColors.navy),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FlowStepTracker(
                    activeStep: _step > 3 ? 3 : _step,
                    subLabels: [
                      _toAccount?.displayName,
                      _fromAccount?.displayName,
                      _step >= 3 && _amountCents > 0
                          ? formatCurrency(_amountCents / 100)
                          : null,
                      _step >= 4 && _selectedDay != null
                          ? 'June $_selectedDay, 2026'
                          : null,
                    ],
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 20),
                    FlowSearchField(onTap: () => _notice('Search')),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.pageBackground,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = _forward
                      ? const Offset(0.08, 0)
                      : const Offset(-0.08, 0);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: slide, end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step > 4 ? 4 : _step),
                  child: switch (_step) {
                    0 => _buildToList(),
                    1 => _buildFromList(),
                    2 => _buildAmountStep(),
                    3 => _buildDateStep(),
                    _ => _buildReviewStep(),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToList() {
    final payees = [...creditCards, ...loans];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FlowSectionHeader(
          title: 'My BECU Accounts',
          expanded: _becuExpanded,
          onToggle: () => setState(() => _becuExpanded = !_becuExpanded),
        ),
        if (_becuExpanded)
          for (final account in payees)
            FlowAccountCard(
              account: account,
              note: account.kind == AccountKind.creditCard
                  ? 'Minimum payment of '
                      '${formatCurrency(_minFor(account))} is due '
                      '${_dueFor(account)}.'
                  : null,
              onTap: () => _selectTo(account),
            ),
        const SizedBox(height: 4),
        FlowSectionHeader(
          title: 'My External Accounts',
          expanded: _externalExpanded,
          onToggle: () =>
              setState(() => _externalExpanded = !_externalExpanded),
        ),
        if (_externalExpanded) ...[
          FlowExternalCard(
            name: 'Chase Checking ...9534',
            onTap: () => _notice('External payees'),
          ),
          FlowExternalCard(
            name: 'Chase Savings ...0012',
            onTap: () => _notice('External payees'),
          ),
        ],
      ],
    );
  }

  double _minFor(Account a) {
    final due = a.creditInfo?.minimumPaymentDue ?? 0;
    if (due > 0) return due;
    return (a.availableBalance * 0.02).clamp(25, a.availableBalance);
  }

  String _dueFor(Account a) {
    final raw = a.creditInfo?.nextPaymentDue;
    if (raw == null) return 'soon';
    final p = raw.split('/');
    if (p.length != 3) return raw;
    final m = int.tryParse(p[0]) ?? 1;
    return '${_months[(m - 1).clamp(0, 11)]} ${int.tryParse(p[1]) ?? 1}';
  }

  Widget _buildFromList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const FdicNotice(),
        const SizedBox(height: 20),
        FlowSectionHeader(
          title: 'My BECU Accounts',
          expanded: _becuExpanded,
          onToggle: () => setState(() => _becuExpanded = !_becuExpanded),
        ),
        if (_becuExpanded)
          for (final account in checkingAndSavings)
            FlowAccountCard(
              account: account,
              onTap: () => _selectFrom(account),
            ),
      ],
    );
  }

  Widget _buildAmountStep() {
    final opts = _options();
    return Focus(
      focusNode: _amountFocus,
      onKeyEvent: _handleAmountKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                for (var i = 0; i < opts.length; i++) ...[
                  _OptionCard(
                    option: opts[i],
                    selected: _selectedOption == i,
                    otherCents: _otherCents,
                    onTap: () => _selectOption(i),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _amountCents > 0 ? () => _goToStep(3) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      disabledBackgroundColor: AppColors.monthBar,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_optionIsOther && _keypadVisible)
            FlowKeypad(onDigit: _tapDigit, onBackspace: _backspace),
        ],
      ),
    );
  }

  Widget _buildDateStep() {
    final due = _due;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: AppColors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Payment Due: ${due.label}.',
                  style: const TextStyle(fontSize: 14, color: AppColors.navy),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FlowCalendarCard(
          todayDay: _todayDay,
          selectedDay: _selectedDay,
          dueDay: due.juneDay,
          onSelect: (day) => setState(() => _selectedDay = day),
          onMonthChange: () => _notice('Changing the month'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedDay != null ? () => _goToStep(4) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              disabledBackgroundColor: AppColors.monthBar,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Set Date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    Widget editIcon(int step) => InkWell(
          onTap: () => _goToStep(step),
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.edit_outlined, size: 20, color: AppColors.teal),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              SurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    DetailRow(
                      label: 'To',
                      value: _toAccount?.displayName ?? '',
                      trailing: editIcon(0),
                    ),
                    DetailRow(
                      label: 'From',
                      value: _fromAccount?.displayName ?? '',
                      trailing: editIcon(1),
                    ),
                    DetailRow(
                      label: 'Amount',
                      value: formatCurrency(_amountCents / 100),
                      trailing: editIcon(2),
                    ),
                    DetailRow(
                      label: 'Date',
                      value: 'June ${_selectedDay ?? _todayDay}, 2026',
                      trailing: editIcon(3),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payments are typically posted in 1–2 business days.',
                style: TextStyle(fontSize: 13, color: AppColors.slate),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm',
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
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.otherCents,
    required this.onTap,
  });

  final _PayOption option;
  final bool selected;
  final int otherCents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOther = option.cents == null;
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (isOther)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: selected ? AppColors.teal : AppColors.fieldBorder,
                        width: selected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('\$', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          formatCurrency(otherCents / 100).substring(1),
                          style: TextStyle(
                            fontSize: 18,
                            color: otherCents > 0
                                ? AppColors.navy
                                : AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    formatCurrency(option.cents! / 100),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  if (option.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.slate),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _Radio(selected: selected),
          ),
        ],
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.teal : AppColors.fieldBorder,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
              ),
            )
          : null,
    );
  }
}
