import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/generated/app_localizations.dart';
import '../models/bill_result.dart';

/// Builds a printable PDF for a calculated borewell bill, optionally
/// addressed to a named client, in the app's current language.
///
/// Amounts are rendered as "Rs. 1,50,000" rather than "₹1,50,000": the
/// `pdf` package's built-in fonts don't include the ₹ glyph, so using it
/// would render as a missing-character box. A bundled Noto Sans Kannada
/// font is registered as a fallback so Kannada labels and client names
/// (typed in Kannada script) render correctly regardless of language.
class PdfService {
  static pw.Font? _kannadaFontCache;

  static Future<pw.Font> _loadKannadaFont() async {
    if (_kannadaFontCache != null) return _kannadaFontCache!;
    final data = await rootBundle.load('assets/fonts/NotoSansKannada-Regular.ttf');
    _kannadaFontCache = pw.Font.ttf(data);
    return _kannadaFontCache!;
  }

  static Future<Uint8List> generateBillPdf({
    required BillResult result,
    required Locale locale,
    String? clientName,
    String? clientPhone,
    String? clientAddress,
  }) async {
    final l10n = await AppLocalizations.delegate.load(locale);
    final kannadaFont = await _loadKannadaFont();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(fontFallback: [kannadaFont]),
    );
    final generatedOn =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final hasClient = clientName != null && clientName.trim().isNotEmpty;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                l10n.pdfTitle,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                l10n.pdfGeneratedOn(generatedOn),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),
              if (hasClient) ...[
                pw.Text(
                  l10n.pdfBillTo,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  clientName.trim(),
                  style:
                      pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                if (clientPhone != null && clientPhone.trim().isNotEmpty)
                  pw.Text(clientPhone.trim(), style: const pw.TextStyle(fontSize: 11)),
                if (clientAddress != null && clientAddress.trim().isNotEmpty)
                  pw.Text(clientAddress.trim(), style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 20),
              ],
              pw.Text(
                l10n.pdfTotalDepth(result.totalDepth),
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1.3),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell(l10n.pdfDepthRange, bold: true),
                      _cell(l10n.pdfFeet, bold: true),
                      _cell(l10n.pdfRatePerFt, bold: true),
                      _cell(l10n.pdfAmount, bold: true),
                    ],
                  ),
                  for (final item in result.items)
                    pw.TableRow(children: [
                      _cell(item.rangeLabel),
                      _cell('${item.units}'),
                      _cell(_money(item.rate)),
                      _cell(_money(item.amount)),
                    ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      l10n.pdfTotalAmount,
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _money(result.totalAmount),
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _money(num amount) {
    final formatted = NumberFormat.decimalPattern('en_IN').format(amount.round());
    return 'Rs. $formatted';
  }
}
