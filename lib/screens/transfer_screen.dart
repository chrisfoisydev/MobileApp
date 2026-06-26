import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/formatting.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import '../widgets/detail_row.dart';
import 'payment_success_screen.dart';
import '../widgets/payment_flow_widgets.dart';
import '../widgets/surface_card.dart';

/// Transfer flow with four steps tracked across the top:
/// To → From → Amount → Date. Each selection is recorded under its step
/// in the tracker and carried into the next.
class TransferScreen extends StatefulWidget {
  const TransferScreen({
    super.key,
    this.initialStep = 0,
    this.initialToAccount,
    this.initialFromAccount,
    this.initialAmountCents = 0,
    this.initialSelectedDay,
    this.initialNote = '',
    this.initialKeypadOpen = false,
  });

  final int initialStep;
  final Account? initialToAccount;
  final Account? initialFromAccount;
  final int initialAmountCents;
  final int? initialSelectedDay;
  final String initialNote;
  final bool initialKeypadOpen;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  late int _step = widget.initialStep;
  // Direction of the last step change; drives the slide direction of the
  // animated transition between steps.
  bool _forward = true;
  late Account? _toAccount = widget.initialToAccount;
  late Account? _fromAccount = widget.initialFromAccount;
  late int _amountCents = widget.initialAmountCents;
  late int? _selectedDay = widget.initialSelectedDay;
  late bool _keypadVisible = widget.initialKeypadOpen;
  final FocusNode _amountFocus = FocusNode();
  late final TextEditingController _noteController =
      TextEditingController(text: widget.initialNote);

  /// Fixed "today" marker shown as an open circle on the calendar.
  static const _todayDay = 8;

  bool _becuExpanded = true;
  bool _externalExpanded = true;

  @override
  void dispose() {
    _amountFocus.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _openKeypad() {
    setState(() => _keypadVisible = true);
    _amountFocus.requestFocus();
  }

  void _notice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  /// Moves to [next], recording the direction so the body transition slides
  /// the right way (forward → in from the right, back → in from the left).
  void _goToStep(int next) => setState(() {
        _forward = next >= _step;
        _step = next;
      });

  void _selectTo(Account account) {
    _toAccount = account;
    _goToStep(1);
  }

  void _selectFrom(Account account) {
    _fromAccount = account;
    _goToStep(2);
  }

  void _tapDigit(int d) => setState(() {
        _amountCents = (_amountCents * 10 + d).clamp(0, 99999999);
      });

  void _backspace() => setState(() => _amountCents ~/= 10);

  /// Lets a physical keyboard (web/desktop) drive the amount alongside the
  /// on-screen keypad.
  KeyEventResult _handleAmountKey(FocusNode node, KeyEvent event) {
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

  void _back() {
    if (_step > 0) {
      _goToStep(_step - 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _toReview() => _goToStep(4);

  void _editStep(int step) => _goToStep(step);

  void _confirm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: formatCurrency(_amountCents / 100),
          fromLabel: _fromAccount?.displayName ?? '',
          toLabel: _toAccount?.displayName ?? '',
          dateLabel: 'June ${_selectedDay ?? _todayDay}, 2026',
          // Done returns to the account summary.
          onDone: () =>
              Navigator.of(context).popUntil(ModalRoute.withName('/accounts')),
        ),
      ),
    );
  }

  String get _title => switch (_step) {
        0 => 'Where is the money going?',
        1 => 'Where is the money from?',
        2 => 'How much would you like to transfer to '
            '${_toAccount?.nickname ?? 'your account'}?',
        3 => 'Almost done, John!\nWhen do you want to transfer?',
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
                      "Let's get the details for your transfer",
                      style: TextStyle(fontSize: 16, color: AppColors.navy),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FlowStepTracker(
                    activeStep: _step > 3 ? 3 : _step,
                    subLabels: [
                      _toAccount?.displayName,
                      _fromAccount?.displayName,
                      _step >= 3 ? formatCurrency(_amountCents / 100) : null,
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
                  // Incoming step slides toward center; on the way out a step
                  // slides off the opposite edge (animation runs in reverse),
                  // so the two read as one continuous push.
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FlowSectionHeader(
          title: 'My BECU Accounts',
          expanded: _becuExpanded,
          onToggle: () => setState(() => _becuExpanded = !_becuExpanded),
        ),
        if (_becuExpanded)
          for (final account in checkingAndSavings)
            FlowAccountCard(account: account, onTap: () => _selectTo(account)),
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
            onTap: () => _notice('External transfers'),
          ),
          FlowExternalCard(
            name: 'Chase Savings ...0012',
            onTap: () => _notice('External transfers'),
          ),
        ],
        const SizedBox(height: 4),
        const FlowSectionHeader(title: 'People & Organizations'),
        SurfaceCard(
          onTap: () => _notice('Adding a recipient'),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.north_east, color: AppColors.slate, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send money to a Person or Organization',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
    final fromAccounts =
        checkingAndSavings.where((a) => a.last4 != _toAccount?.last4).toList();
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
          for (final account in fromAccounts)
            FlowAccountCard(
              account: account,
              onTap: () => _selectFrom(account),
            ),
      ],
    );
  }

  Widget _buildAmountStep() {
    final from = _fromAccount;
    return Focus(
      focusNode: _amountFocus,
      onKeyEvent: _handleAmountKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available to transfer from account',
                    style: TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                  const SizedBox(height: 8),
                  if (from != null)
                    SurfaceCard(
                      elevated: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const BecuBadge(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(from.displayName,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          Text(
                            formatCurrency(from.availableBalance),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Amount',
                    style: TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    onTap: _openKeypad,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8, right: 4),
                            child: Text('\$',
                                style: TextStyle(
                                    fontSize: 26, color: AppColors.navy)),
                          ),
                          Text(
                            formatCurrency(_amountCents / 100).substring(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w500,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
          ),
          if (_keypadVisible)
            FlowKeypad(onDigit: _tapDigit, onBackspace: _backspace),
        ],
      ),
    );
  }

  Widget _buildDateStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FlowCalendarCard(
          todayDay: _todayDay,
          selectedDay: _selectedDay,
          onSelect: (day) => setState(() => _selectedDay = day),
          onMonthChange: () => _notice('Changing the month'),
        ),
        const SizedBox(height: 16),
        const Text('Note (Optional)',
            style: TextStyle(fontSize: 12, color: AppColors.slate)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'What is this for?',
            hintStyle: const TextStyle(color: AppColors.slate),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.fieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedDay != null ? _toReview : null,
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
          onTap: () => _editStep(step),
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
                    ),
                    DetailRow(
                      label: 'Note',
                      value: _noteController.text.isEmpty
                          ? 'None'
                          : _noteController.text,
                      trailing: editIcon(3),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Funds are typically available in 1–2 business days.',
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
