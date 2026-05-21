import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/sale.dart';
import '../../data/models/store_settings.dart';
import '../../shared/currency.dart';

/// 80mm thermal receipt — narrow, monospace-friendly.
Future<pw.Document> buildReceiptPdf(Sale sale, StoreSettings settings) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 8),
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Center(
              child: pw.Text(
                settings.storeName,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (settings.address != null)
              pw.Center(child: pw.Text(settings.address!, style: const pw.TextStyle(fontSize: 8))),
            if (settings.phone != null)
              pw.Center(child: pw.Text(settings.phone!, style: const pw.TextStyle(fontSize: 8))),
            pw.SizedBox(height: 6),
            _divider(),
            pw.SizedBox(height: 4),
            _kv('Receipt #', sale.transactionId.substring(0, 8).toUpperCase()),
            _kv('Date', _formatDateTime(sale.timestamp)),
            if (sale.customerName != null) _kv('Customer', sale.customerName!),
            pw.SizedBox(height: 6),
            _divider(),
            ...sale.cart.map((item) => _itemRow(item, settings)),
            _divider(),
            _totalLine('Subtotal', sale.subtotal, settings),
            if (sale.discount > 0) _totalLine('Discount', -sale.discount, settings),
            if (sale.tax > 0) _totalLine('Tax', sale.tax, settings),
            if (sale.storeCreditUsed > 0) _totalLine('Store credit', -sale.storeCreditUsed, settings),
            pw.SizedBox(height: 2),
            _totalLine('TOTAL', sale.total, settings, bold: true, size: 12),
            pw.SizedBox(height: 6),
            if (sale.payments.isNotEmpty)
              ...sale.payments.map((p) =>
                  _kv(p.method, formatCurrency(p.amount, settings), small: true)),
            if (sale.cashReceived != null)
              _kv('Cash received', formatCurrency(sale.cashReceived!, settings), small: true),
            if (sale.changeDue != null && sale.changeDue! > 0)
              _kv('Change', formatCurrency(sale.changeDue!, settings), small: true),
            pw.SizedBox(height: 10),
            _divider(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                settings.receiptFooter ?? 'Thank you for your business!',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc;
}

pw.Widget _divider() => pw.Container(height: 0.5, color: PdfColors.black);

pw.Widget _kv(String k, String v, {bool small = false}) {
  final size = small ? 8.0 : 9.0;
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(k, style: pw.TextStyle(fontSize: size)),
        pw.Text(v, style: pw.TextStyle(fontSize: size)),
      ],
    ),
  );
}

pw.Widget _itemRow(CartItem item, StoreSettings settings) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(item.name, style: const pw.TextStyle(fontSize: 9)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${formatQuantity(item.quantity, isWeighed: item.isWeighed)} × ${formatCurrency(item.price, settings)}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(formatCurrency(item.lineTotal, settings), style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _totalLine(String label, double amount, StoreSettings settings,
    {bool bold = false, double size = 9}) {
  final style = pw.TextStyle(
    fontSize: size,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(formatCurrency(amount, settings), style: style),
      ],
    ),
  );
}

String _formatDateTime(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  } catch (_) {
    return iso;
  }
}
