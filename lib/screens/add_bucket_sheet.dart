import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';

/// Two-step "Set up your bucket" flow presented as a bottom sheet.
/// Step 1 picks an icon, name and save type; step 2 collects the target
/// date, auto-transfer and contribution. Returns the created
/// [SavingsBucket], or null if cancelled.
class AddBucketSheet extends StatefulWidget {
  const AddBucketSheet({super.key, this.initialStep = 0});

  final int initialStep;

  static Future<SavingsBucket?> show(BuildContext context) {
    return showModalBottomSheet<SavingsBucket>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBucketSheet(),
    );
  }

  @override
  State<AddBucketSheet> createState() => _AddBucketSheetState();
}

enum _SaveType { target, savingUp }

class _AddBucketSheetState extends State<AddBucketSheet> {
  static const _emojis = [
    '🏡', '🚗', '🛡️', '✈️', '🎓', '💍', '🏖️', '📺', //
    '🎸', '🐶', '🌿', '🛒', '🍕', '🎮', '💻', '🚀', //
  ];
  static const _suggestions = [
    'Vacation',
    'New Home',
    'New Laptop',
    'Holiday Gifts',
    'Rainy Day',
  ];
  static const _targetDates = ['3 mo', '6 mo', '1 yr', '2 yr', '3 yr', '5 yr'];
  static const _targetDays = [90, 182, 365, 730, 1095, 1825];

  late int _step = widget.initialStep;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _contribution =
      TextEditingController(text: '\$1,200');
  int _emoji = 0;
  _SaveType _saveType = _SaveType.target;
  int? _targetDate = 1; // 6 mo
  bool _autoTransfer = true;
  bool _monthly = true;

  @override
  void dispose() {
    _name.dispose();
    _contribution.dispose();
    super.dispose();
  }

  void _createBucket() {
    final digits = _contribution.text.replaceAll(RegExp(r'[^0-9]'), '');
    final monthly = digits.isEmpty ? null : double.parse(digits);
    final isTarget = _saveType == _SaveType.target;
    final name = _name.text.trim().isEmpty ? 'New Bucket' : _name.text.trim();
    final bucket = SavingsBucket(
      name: name,
      saved: 0,
      goal: isTarget ? 50000 : null,
      emoji: _emojis[_emoji],
      autoTransfer: _autoTransfer,
      monthlyContribution: monthly,
      daysLeft: isTarget && _targetDate != null
          ? '${_targetDays[_targetDate!]} days left'
          : null,
    );
    Navigator.of(context).pop(bucket);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          _ProgressBar(step: _step),
          const SizedBox(height: 16),
          _Header(
            step: _step,
            title: _step == 0 ? 'Set up your bucket' : 'Saving details',
            onClose: () => Navigator.of(context).maybePop(),
          ),
          const Divider(height: 24),
          Flexible(
            child: _step == 0 ? _buildStep1() : _buildStep2(),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _step == 0 ? () => setState(() => _step = 1) : _createBucket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _step == 0 ? 'Continue' : 'Create Bucket',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (_step == 1) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.teal, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      children: [
        _label('ICON'),
        const SizedBox(height: 12),
        _EmojiGrid(
          emojis: _emojis,
          selected: _emoji,
          onSelect: (i) => setState(() => _emoji = i),
        ),
        const SizedBox(height: 20),
        _label('NAME'),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          decoration: _fieldDecoration('e.g. Vacation Fund'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _suggestions)
              _OutlineChip(
                label: s,
                onTap: () => setState(() {
                  _name.text = s;
                  _name.selection = TextSelection.collapsed(offset: s.length);
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _label('HOW DO YOU WANT TO SAVE?'),
        const SizedBox(height: 8),
        _SaveOption(
          emoji: '🎯',
          title: 'Hit a target amount',
          subtitle: 'I have a specific amount in mind',
          selected: _saveType == _SaveType.target,
          onTap: () => setState(() => _saveType = _SaveType.target),
        ),
        const SizedBox(height: 12),
        _SaveOption(
          emoji: '🫙',
          title: 'Just saving up',
          subtitle: "No specific target — I'll build as I go",
          selected: _saveType == _SaveType.savingUp,
          onTap: () => setState(() => _saveType = _SaveType.savingUp),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isTarget = _saveType == _SaveType.target;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(_emojis[_emoji], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _name.text.trim().isEmpty ? 'New Bucket' : _name.text.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              Text(isTarget ? '🎯' : '🫙',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                isTarget ? 'Target Savings' : 'Saving Up',
                style: const TextStyle(fontSize: 13, color: AppColors.slate),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _label('TARGET DATE'),
            const SizedBox(width: 6),
            const Text('(optional)',
                style: TextStyle(fontSize: 12, color: AppColors.slate)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _targetDates.length; i++)
              _OutlineChip(
                label: _targetDates[i],
                selected: _targetDate == i,
                onTap: () => setState(() => _targetDate = i),
              ),
            _OutlineChip(
              label: 'Select Date',
              icon: Icons.calendar_today_outlined,
              tealText: true,
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF5F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, size: 18, color: AppColors.slate),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-transfer',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                    SizedBox(height: 2),
                    Text('Move funds automatically each month',
                        style: TextStyle(fontSize: 13, color: AppColors.slate)),
                  ],
                ),
              ),
              Switch(
                value: _autoTransfer,
                activeTrackColor: AppColors.teal,
                onChanged: (v) => setState(() => _autoTransfer = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _label('CONTRIBUTION')),
            _FrequencyToggle(
              monthly: _monthly,
              onChanged: (m) => setState(() => _monthly = m),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _contribution,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration('\$0'),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.slate),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: border(AppColors.fieldBorder, 1),
      focusedBorder: border(AppColors.teal, 2),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.slate,
        ),
      );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const filled = Color(0xFF2E2150);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _seg(filled)),
          const SizedBox(width: 6),
          Expanded(child: _seg(step >= 1 ? filled : AppColors.borderSubtle)),
        ],
      ),
    );
  }

  Widget _seg(Color color) => Container(
        height: 4,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.title,
    required this.onClose,
  });

  final int step;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${step + 1} OF 2',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            customBorder: const CircleBorder(),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({
    required this.emojis,
    required this.selected,
    required this.onSelect,
  });

  final List<String> emojis;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (var i = 0; i < emojis.length; i++)
          InkWell(
            onTap: () => onSelect(i),
            customBorder: const CircleBorder(),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selected
                    ? const Color(0xFFD7CCEE)
                    : const Color(0xFFEFF5F6),
                shape: BoxShape.circle,
              ),
              child: Text(emojis[i], style: const TextStyle(fontSize: 16)),
            ),
          ),
      ],
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.tealText = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final bool tealText;

  @override
  Widget build(BuildContext context) {
    final color = tealText ? AppColors.teal : AppColors.navy;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F4F5) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: AppColors.teal),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyToggle extends StatelessWidget {
  const _FrequencyToggle({required this.monthly, required this.onChanged});

  final bool monthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.teal, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _seg('Monthly', monthly, () => onChanged(true)),
          _seg('Weekly', !monthly, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.navy,
          ),
        ),
      ),
    );
  }
}

class _SaveOption extends StatelessWidget {
  const _SaveOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F4F5) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF5F6),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.slate),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
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
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
