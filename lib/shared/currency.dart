import 'package:intl/intl.dart';

import '../data/models/store_settings.dart';

String formatCurrency(double amount, StoreSettings settings) {
  try {
    final fmt = NumberFormat.currency(
      symbol: settings.currencySymbol,
      decimalDigits: 2,
      name: settings.currencyCode,
    );
    return fmt.format(amount);
  } catch (_) {
    return '${settings.currencySymbol}${amount.toStringAsFixed(2)}';
  }
}

String formatQuantity(double qty, {bool isWeighed = false}) {
  if (!isWeighed && qty == qty.roundToDouble()) {
    return qty.toStringAsFixed(0);
  }
  return qty.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
