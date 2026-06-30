import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/product.dart';
import '../../data/models/store_settings.dart';
import '../../shared/currency.dart';

/// Builds a printable PDF report of products that are at-or-below their
/// reorder point (low) and out-of-stock. Designed for A4 portrait so it
/// works on any office printer / save-as-PDF dialog.
///
/// Why both categories together: a "low stock" report that excludes
/// out-of-stock items is misleading — anything with 0 inventory is even
/// more urgent than something flirting with the reorder point. We list
/// out-of-stock first, then low.
Future<pw.Document> buildLowStockReportPdf({
  required List<Product> allProducts,
  required StoreSettings settings,
}) async {
  final outOfStock = <Product>[];
  final lowStock = <Product>[];
  for (final p in allProducts) {
    if (!p.isActive) continue;
    if (p.stock <= 0) {
      outOfStock.add(p);
    } else if (p.reorderPoint != null && p.stock <= p.reorderPoint!) {
      lowStock.add(p);
    }
  }
  outOfStock.sort((a, b) => a.name.compareTo(b.name));
  lowStock.sort((a, b) => a.name.compareTo(b.name));

  final generatedAt = DateTime.now();
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 36),
      header: (ctx) => ctx.pageNumber == 1
          ? _header(settings, generatedAt, outOfStock.length, lowStock.length)
          : pw.SizedBox(),
      footer: (ctx) => _footer(ctx),
      build: (ctx) => [
        if (outOfStock.isEmpty && lowStock.isEmpty)
          _emptyState()
        else ...[
          if (outOfStock.isNotEmpty) ...[
            _sectionTitle('Out of stock', outOfStock.length, _danger),
            pw.SizedBox(height: 8),
            _table(outOfStock, settings, isOutOfStock: true),
            pw.SizedBox(height: 24),
          ],
          if (lowStock.isNotEmpty) ...[
            _sectionTitle('Low stock', lowStock.length, _warning),
            pw.SizedBox(height: 8),
            _table(lowStock, settings, isOutOfStock: false),
          ],
        ],
      ],
    ),
  );

  return doc;
}

// ─── Theme constants ────────────────────────────────────────────────────
const _primary = PdfColor.fromInt(0xFF4F46E5);
const _warning = PdfColor.fromInt(0xFFF59E0B);
const _danger = PdfColor.fromInt(0xFFEF4444);
const _ink = PdfColor.fromInt(0xFF0F172A);
const _muted = PdfColor.fromInt(0xFF64748B);
const _faint = PdfColor.fromInt(0xFFE6E9EF);

// ─── Header (page 1) ────────────────────────────────────────────────────
pw.Widget _header(
  StoreSettings settings,
  DateTime generatedAt,
  int outOfStock,
  int lowStock,
) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 18),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STOCK REPORT',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _muted,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Items needing attention',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  settings.storeName,
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: _muted,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: _muted,
                    letterSpacing: 0.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _formatDate(generatedAt),
                  style: pw.TextStyle(fontSize: 11, color: _ink),
                ),
                pw.Text(
                  _formatTime(generatedAt),
                  style: pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        // Summary chips
        pw.Row(
          children: [
            _summaryChip(
              label: 'OUT OF STOCK',
              value: outOfStock.toString(),
              color: _danger,
            ),
            pw.SizedBox(width: 8),
            _summaryChip(
              label: 'LOW STOCK',
              value: lowStock.toString(),
              color: _warning,
            ),
            pw.SizedBox(width: 8),
            _summaryChip(
              label: 'NEEDS REORDER',
              value: (outOfStock + lowStock).toString(),
              color: _primary,
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _summaryChip({
  required String label,
  required String value,
  required PdfColor color,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: pw.BoxDecoration(
      color: PdfColor(color.red, color.green, color.blue, 0.08),
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(
        color: PdfColor(color.red, color.green, color.blue, 0.25),
        width: 0.5,
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7,
            color: color,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ─── Section title ──────────────────────────────────────────────────────
pw.Widget _sectionTitle(String text, int count, PdfColor color) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Container(width: 3, height: 14, color: color),
      pw.SizedBox(width: 8),
      pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: _ink,
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: pw.BoxDecoration(
          color: PdfColor(color.red, color.green, color.blue, 0.12),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          '$count',
          style: pw.TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

// ─── Product table ──────────────────────────────────────────────────────
pw.Widget _table(
  List<Product> products,
  StoreSettings settings, {
  required bool isOutOfStock,
}) {
  return pw.TableHelper.fromTextArray(
    cellAlignment: pw.Alignment.centerLeft,
    cellAlignments: {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
    },
    headerAlignment: pw.Alignment.centerLeft,
    headerAlignments: {
      2: pw.Alignment.centerRight,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
    },
    headerStyle: pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: _muted,
      letterSpacing: 0.6,
    ),
    headerDecoration: const pw.BoxDecoration(color: _faint),
    headerHeight: 22,
    cellHeight: 22,
    cellStyle: pw.TextStyle(fontSize: 9.5, color: _ink),
    columnWidths: const {
      0: pw.FlexColumnWidth(3.2),
      1: pw.FlexColumnWidth(1.6),
      2: pw.FlexColumnWidth(1),
      3: pw.FlexColumnWidth(1),
      4: pw.FlexColumnWidth(1.2),
      5: pw.FlexColumnWidth(1.5),
    },
    border: pw.TableBorder(
      horizontalInside: pw.BorderSide(color: _faint, width: 0.5),
    ),
    headers: const ['PRODUCT', 'SKU', 'STOCK', 'REORDER AT', 'SUGGESTED', 'EST. COST'],
    data: products.map((p) {
      // "Suggested" = how much to order to get back to (reorderPoint × 2).
      // If reorderPoint is null, default to ordering 10 units.
      final reorder = p.reorderPoint ?? 0;
      final target = reorder > 0 ? reorder * 2 : 10.0;
      final suggested = (target - p.stock).clamp(0, double.infinity);
      final estCost = (p.costPrice ?? p.price) * suggested;
      return [
        p.name,
        p.sku,
        _fmt(p.stock),
        p.reorderPoint == null ? '—' : _fmt(p.reorderPoint!),
        _fmt(suggested.toDouble()),
        formatCurrency(estCost, settings),
      ];
    }).toList(),
  );
}

// ─── Empty state ────────────────────────────────────────────────────────
pw.Widget _emptyState() {
  return pw.Container(
    padding: const pw.EdgeInsets.all(36),
    alignment: pw.Alignment.center,
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'All stocked up.',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Nothing is below its reorder point right now.',
          style: pw.TextStyle(fontSize: 11, color: _muted),
        ),
      ],
    ),
  );
}

// ─── Footer with page number ────────────────────────────────────────────
pw.Widget _footer(pw.Context ctx) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _faint, width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'SalePilot · Stock Report',
          style: pw.TextStyle(fontSize: 8, color: _muted),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ],
    ),
  );
}

// ─── Formatting helpers ─────────────────────────────────────────────────
String _fmt(double v) {
  if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

String _formatDate(DateTime dt) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
