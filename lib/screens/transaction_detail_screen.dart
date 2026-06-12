import 'package:flutter/material.dart';

import '../data/formatting.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/surface_card.dart';

/// Transaction description: amount and dates, editable category/notes,
/// transaction ID, merchant location and the support footer.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.account,
  });

  final BankTransaction transaction;
  final Account account;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.arrow_back_ios_new,
                                size: 18, color: AppColors.navy),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Transaction description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: tx.iconBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(tx.icon, size: 20, color: tx.iconColor),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tx.title,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.slate,
                            ),
                          ),
                        ),
                        Text(
                          formatCurrency(tx.amount, showPlus: true),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoLine(
                      label: 'Available Balance:',
                      value: formatCurrency(account.availableBalance),
                    ),
                    _InfoLine(label: 'Created:', value: tx.createdDate),
                    _InfoLine(label: 'Posted:', value: tx.postedDate),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _EditableRow(
                        label: 'Category',
                        value: tx.category,
                      ),
                      const Divider(height: 1),
                      const _EditableRow(label: 'Notes'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Transaction ID',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.slate),
                        ),
                      ),
                      Text(
                        tx.transactionId,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tx.addressLines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 170,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CustomPaint(painter: _MapPainter()),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        size: 44,
                                        color: AppColors.becuRed,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x40000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final line in tx.addressLines)
                          Text(
                            line,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.slate,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  "If you see something wrong with this transaction or don't "
                  'recognize it, please contact customer support at '
                  '(800) 555-5555',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.slate,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.slate),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 17))),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value!,
                style: const TextStyle(fontSize: 15, color: AppColors.teal),
              ),
            ),
          const Icon(Icons.edit_outlined, size: 20, color: AppColors.teal),
        ],
      ),
    );
  }
}

/// Simple street-map placeholder standing in for the embedded map image.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9E6DF),
    );

    final street = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    for (final x in [0.18, 0.42, 0.68, 0.88]) {
      canvas.drawLine(Offset(w * x, 0), Offset(w * x, h), street);
    }
    for (final y in [0.3, 0.58, 0.85]) {
      canvas.drawLine(Offset(0, h * y), Offset(w, h * y), street);
    }

    canvas.drawLine(
      Offset(0, h * 0.12),
      Offset(w, h * 0.12),
      Paint()
        ..color = const Color(0xFFF6D87C)
        ..strokeWidth = 9,
    );

    canvas.drawCircle(
      Offset(w * 0.9, h * 0.78),
      h * 0.18,
      Paint()..color = const Color(0xFFBEDFA3),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.84, h * 0.92),
        width: w * 0.14,
        height: h * 0.12,
      ),
      Paint()..color = const Color(0xFFA9D3DF),
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
