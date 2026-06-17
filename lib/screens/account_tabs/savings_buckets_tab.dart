import 'package:flutter/material.dart';

import '../../data/formatting.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../add_bucket_sheet.dart';
import '../goal_detail_sheet.dart';

/// Savings Buckets tab: a featured goal card (purple) plus a grid of
/// saving-up jars (blue) and add tiles.
class SavingsBucketsTab extends StatelessWidget {
  const SavingsBucketsTab({
    super.key,
    required this.buckets,
    required this.onAddBucket,
  });

  final List<SavingsBucket> buckets;
  final ValueChanged<SavingsBucket> onAddBucket;

  static const purpleBg = Color(0xFFEDE7F9);
  static const _purpleTrack = Color(0xFFD7CCEE);
  static const _purpleFill = Color(0xFF2E2150);
  static const _blueBg = Color(0xFFDCF0F3);

  void _notice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is not part of this prototype.')),
      );
  }

  Future<void> _addBucket(BuildContext context) async {
    final bucket = await AddBucketSheet.show(context);
    if (bucket != null) onAddBucket(bucket);
  }

  @override
  Widget build(BuildContext context) {
    final featured = buckets.where((b) => b.isGoal).toList();
    final rest = buckets.where((b) => !b.isGoal).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            const Text('Savings Buckets', style: AppTextStyles.sectionLabel),
            const SizedBox(width: 8),
            _CountBadge(buckets.length),
            const Spacer(),
            InkWell(
              onTap: () => _addBucket(context),
              child: const Row(
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.teal),
                  SizedBox(width: 4),
                  Text(
                    'New Bucket',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 16, color: AppColors.teal),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final bucket in featured) ...[
          _FeaturedBucketCard(
            bucket: bucket,
            onNotice: _notice,
            onTap: () => GoalDetailSheet.show(context, bucket),
          ),
          const SizedBox(height: 16),
        ],
        _BucketGrid(
          buckets: rest,
          onNotice: _notice,
          onAddBucket: () => _addBucket(context),
          onOpenBucket: (b) => GoalDetailSheet.show(context, b),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeaturedBucketCard extends StatelessWidget {
  const _FeaturedBucketCard({
    required this.bucket,
    required this.onNotice,
    required this.onTap,
  });

  final SavingsBucket bucket;
  final void Function(BuildContext, String) onNotice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pct = (bucket.progress * 100).round();
    final toGo = (bucket.goal ?? 0) - bucket.saved;
    return Material(
      color: SavingsBucketsTab.purpleBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bucket.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  _EditPill(onTap: onTap),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (bucket.daysLeft != null)
                    _Pill(
                      label: bucket.daysLeft!,
                      background: Colors.white,
                      textColor: AppColors.navy,
                    ),
                  if (bucket.daysLeft != null) const SizedBox(width: 8),
                  if (bucket.autoTransfer)
                    const _Pill(
                      label: 'Auto-transfer',
                      background: Color(0xFFD8F0F2),
                      textColor: AppColors.teal,
                      icon: Icons.bolt,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatCurrency(bucket.saved),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    ' / ${formatCurrency(bucket.goal ?? 0)}',
                    style:
                        const TextStyle(fontSize: 16, color: AppColors.slate),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: bucket.progress,
                  minHeight: 10,
                  backgroundColor: SavingsBucketsTab._purpleTrack,
                  valueColor: const AlwaysStoppedAnimation(
                      SavingsBucketsTab._purpleFill),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$pct% saved',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${formatCurrency(toGo)} to go',
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.slate),
                  ),
                ],
              ),
              if (bucket.monthlyContribution != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Monthly contribution',
                          style:
                              TextStyle(fontSize: 15, color: AppColors.slate),
                        ),
                      ),
                      Text(
                        '${formatCurrency(bucket.monthlyContribution!)}/mo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () =>
                            onNotice(context, 'Editing the contribution'),
                        child: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.teal),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BucketGrid extends StatelessWidget {
  const _BucketGrid({
    required this.buckets,
    required this.onNotice,
    required this.onAddBucket,
    required this.onOpenBucket,
  });

  final List<SavingsBucket> buckets;
  final void Function(BuildContext, String) onNotice;
  final VoidCallback onAddBucket;
  final ValueChanged<SavingsBucket> onOpenBucket;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final b in buckets)
        _SmallBucketCard(
          bucket: b,
          onNotice: onNotice,
          onEdit: () => onOpenBucket(b),
        ),
      _AddTile(
        label: 'Add bucket',
        dashed: true,
        onTap: onAddBucket,
      ),
      _AddTile(
        label: 'Add funds to a bucket',
        dashed: false,
        onTap: () => onNotice(context, 'Adding funds'),
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: 12),
                  if (i + 1 < tiles.length)
                    Expanded(child: tiles[i + 1])
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SmallBucketCard extends StatelessWidget {
  const _SmallBucketCard({
    required this.bucket,
    required this.onNotice,
    required this.onEdit,
  });

  final SavingsBucket bucket;
  final void Function(BuildContext, String) onNotice;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bucket.isGoal
            ? SavingsBucketsTab.purpleBg
            : SavingsBucketsTab._blueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bucket.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              if (bucket.autoTransfer)
                const Icon(Icons.bolt, size: 16, color: AppColors.teal),
              const SizedBox(width: 4),
              InkWell(
                onTap: onEdit,
                child: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.teal),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(bucket.saved),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          if (bucket.monthlyContribution != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: AppColors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${formatCurrency(bucket.monthlyContribution!)}/mo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => onNotice(context, 'Editing the contribution'),
                    child: const Icon(Icons.edit_outlined,
                        size: 14, color: AppColors.teal),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => onNotice(context, 'Auto-transfer setup'),
                child: const Text(
                  'Set up auto-transfer',
                  style: TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.teal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.label,
    required this.dashed,
    required this.onTap,
  });

  final String label;
  final bool dashed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = dashed ? AppColors.slate : AppColors.teal;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DottedBorderBox(
        dashed: dashed,
        color: dashed ? AppColors.borderSubtle : AppColors.teal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dashed
                      ? AppColors.borderSubtle.withValues(alpha: 0.5)
                      : AppColors.teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color background;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditPill extends StatelessWidget {
  const _EditPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: AppColors.navy),
            SizedBox(width: 4),
            Text('Edit', style: TextStyle(fontSize: 13, color: AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

/// A rounded box with either a dashed or solid border, used by the add tiles.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    required this.dashed,
  });

  final Widget child;
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BorderPainter(color: color, dashed: dashed),
      child: child,
    );
  }
}

class _BorderPainter extends CustomPainter {
  _BorderPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    if (!dashed) {
      canvas.drawRRect(rrect, paint);
      return;
    }
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, (d + dash).clamp(0, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}
