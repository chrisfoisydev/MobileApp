/// Formats [value] as a US dollar amount, e.g. -12.21 -> "-$12.21",
/// 8122.1 -> "$8,122.10". Set [showPlus] to prefix positive values with "+".
String formatCurrency(double value, {bool showPlus = false}) {
  final sign = value < 0 ? '-' : (showPlus ? '+' : '');
  final digits = value.abs().toStringAsFixed(2);
  final withCommas = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$sign\$$withCommas';
}
