import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import 'becu_logo.dart';
import 'surface_card.dart';

/// Shared building blocks for the stepper money-movement flows (Transfer and
/// Make a Payment): the To→From→Amount→Date tracker, account cards, the
/// amount keypad, and the calendar.

class FlowStepTracker extends StatelessWidget {
  const FlowStepTracker({
    super.key,
    required this.activeStep,
    required this.subLabels,
  });

  final int activeStep;
  final List<String?> subLabels;

  static const _labels = ['To', 'From', 'Amount', 'Date'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stepWidth = constraints.maxWidth / _labels.length;
        return Stack(
          children: [
            Positioned(
              left: stepWidth / 2,
              right: stepWidth / 2,
              top: 14,
              child: Row(
                children: [
                  for (var i = 0; i < _labels.length - 1; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                i <= activeStep ? AppColors.teal : Colors.white,
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
                        if (subLabels[i] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: Text(
                              subLabels[i]!,
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

class FlowAccountCard extends StatelessWidget {
  const FlowAccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.note,
  });

  final Account account;
  final VoidCallback onTap;

  /// Optional highlighted note shown under the account (e.g. a credit card's
  /// minimum-payment reminder).
  final String? note;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BecuBadge(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(account.displayName,
                    style: const TextStyle(fontSize: 16)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(account.availableBalance),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    account.kind == AccountKind.creditCard
                        ? 'Current Balance'
                        : 'Available Balance',
                    style: const TextStyle(fontSize: 13, color: AppColors.slate),
                  ),
                ],
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                note!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FlowSearchField extends StatelessWidget {
  const FlowSearchField({
    super.key,
    required this.onTap,
    this.hint = 'Search Accounts & People',
  });

  final VoidCallback onTap;
  final String hint;

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
          border: Border.all(color: AppColors.fieldBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(fontSize: 16, color: AppColors.slate),
              ),
            ),
            const Icon(Icons.search, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}

class FlowSectionHeader extends StatelessWidget {
  const FlowSectionHeader({
    super.key,
    required this.title,
    this.expanded,
    this.onToggle,
  });

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

class FlowExternalCard extends StatelessWidget {
  const FlowExternalCard({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.north_east, color: AppColors.slate, size: 20),
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

class FdicNotice extends StatelessWidget {
  const FdicNotice({super.key});

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

class FlowKeypad extends StatelessWidget {
  const FlowKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final void Function(int) onDigit;
  final VoidCallback onBackspace;

  static const _letters = {
    2: 'ABC',
    3: 'DEF',
    4: 'GHI',
    5: 'JKL',
    6: 'MNO',
    7: 'PQRS',
    8: 'TUV',
    9: 'WXYZ',
  };

  @override
  Widget build(BuildContext context) {
    Widget digit(int d) => _KeypadKey(
          onTap: () => onDigit(d),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$d',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w400, height: 1.1)),
              if (_letters[d] != null)
                Text(
                  _letters[d]!,
                  style: const TextStyle(
                      fontSize: 8,
                      height: 1.1,
                      letterSpacing: 1.5,
                      color: AppColors.support),
                ),
            ],
          ),
        );

    return Container(
      color: const Color(0xFFD3D9DE),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(children: [digit(1), digit(2), digit(3)]),
            Row(children: [digit(4), digit(5), digit(6)]),
            Row(children: [digit(7), digit(8), digit(9)]),
            Row(
              children: [
                const _KeypadKey(
                    child: Text('+ * #', style: TextStyle(fontSize: 20))),
                digit(0),
                _KeypadKey(
                  onTap: onBackspace,
                  filled: false,
                  child: const Icon(Icons.backspace_outlined, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({required this.child, this.onTap, this.filled = true});

  final Widget child;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(height: 54, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

class FlowCalendarCard extends StatelessWidget {
  const FlowCalendarCard({
    super.key,
    required this.todayDay,
    required this.selectedDay,
    required this.onSelect,
    required this.onMonthChange,
    this.dueDay,
  });

  final int todayDay;
  final int? selectedDay;

  /// Optional payment-due day to highlight on the calendar.
  final int? dueDay;
  final ValueChanged<int> onSelect;
  final VoidCallback onMonthChange;

  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(2026, 6, 1);
    final daysInMonth = DateTime(2026, 7, 0).day; // 30
    final prevDays = DateTime(2026, 6, 0).day; // 31 (May)
    final leading = first.weekday % 7; // Sun == 0

    final cells = <(int day, bool inMonth)>[];
    for (var k = 0; k < 42; k++) {
      if (k < leading) {
        cells.add((prevDays - leading + 1 + k, false));
      } else if (k < leading + daysInMonth) {
        cells.add((k - leading + 1, true));
      } else {
        cells.add((k - leading - daysInMonth + 1, false));
      }
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('June 2026',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              InkWell(
                onTap: onMonthChange,
                child: const Icon(Icons.chevron_left, color: AppColors.teal),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onMonthChange,
                child: const Icon(Icons.chevron_right, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.slate),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < 6; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      cell: cells[row * 7 + col],
                      selected: cells[row * 7 + col].$2 &&
                          cells[row * 7 + col].$1 == selectedDay,
                      isToday: cells[row * 7 + col].$2 &&
                          cells[row * 7 + col].$1 == todayDay,
                      isDue: dueDay != null &&
                          cells[row * 7 + col].$2 &&
                          cells[row * 7 + col].$1 == dueDay,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.cell,
    required this.selected,
    required this.isToday,
    required this.onSelect,
    this.isDue = false,
  });

  final (int, bool) cell;
  final bool selected;
  final bool isToday;
  final bool isDue;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final day = cell.$1;
    final inMonth = cell.$2;
    final BoxDecoration? decoration = selected
        ? BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(10),
          )
        : isToday
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal, width: 1.5),
              )
            : isDue
                ? BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  )
                : null;
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: inMonth && !isToday ? () => onSelect(day) : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: decoration,
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 16,
                color: selected
                    ? Colors.white
                    : (inMonth ? AppColors.navy : const Color(0xFFC4CDD5)),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
