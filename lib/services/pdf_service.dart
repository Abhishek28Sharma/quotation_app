import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/quote_model.dart';
import '../models/settings_model.dart';
import 'pricing_engine.dart';

class PdfService {
  // Brand Colors matching agency theme
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF0284C7); // Sky / Navy Blue
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF0369A1);
  static const PdfColor accentGreen = PdfColor.fromInt(0xFF10B981); // Emerald
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor tableHeaderBg = PdfColor.fromInt(0xFFF1F5F9);
  static const PdfColor textDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE2E8F0);

  static Future<Uint8List> generateProposalPdf({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) async {
    final pdf = pw.Document(
      title: 'Commercial Proposal - ${quote.clientName}',
      author: settings.founderName,
    );

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontMedium = await PdfGoogleFonts.interMedium();
    final fontBold = await PdfGoogleFonts.interBold();

    final dateFormatted = DateFormat('dd MMM yyyy').format(quote.createdAt);
    final validityFormatted = DateFormat('dd MMM yyyy')
        .format(quote.createdAt.add(const Duration(days: 14)));

    final currency = quote.calculation.currency;
    final targetPriceFormatted = PricingEngine.formatAmount(quote.calculation.targetPrice, currency);
    final starterPriceFormatted = PricingEngine.formatAmount(quote.calculation.starterPrice, currency);
    final enterprisePriceFormatted = PricingEngine.formatAmount(quote.calculation.enterprisePrice, currency);

    // Filter selected add-ons
    final selectedAddons = FeatureAddon.allAddons
        .where((a) => quote.selectedAddonIds.contains(a.id))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          fontFallback: [fontMedium],
        ),
        build: (pw.Context context) {
          return [
            // 1. HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        settings.agencyName.toUpperCase(),
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          color: primaryColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        settings.tagline,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Text(
                        'COMMERCIAL QUOTATION',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 11,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Ref: ${quote.refCode}',
                        style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark)),
                    pw.Text('Date: $dateFormatted',
                        style: pw.TextStyle(font: fontRegular, fontSize: 9, color: textMuted)),
                    pw.Text('Valid Until: $validityFormatted (14 Days)',
                        style: pw.TextStyle(font: fontMedium, fontSize: 8.5, color: accentGreen)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Divider(thickness: 1, color: borderColor),
            pw.SizedBox(height: 12),

            // 2. CLIENT & PROJECT OVERVIEW BOX
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PROPOSAL PREPARED FOR',
                            style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: textMuted)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          quote.clientName.trim().isEmpty ? 'Valued Client' : quote.clientName,
                          style: pw.TextStyle(font: fontBold, fontSize: 13, color: textDark),
                        ),
                        if (quote.clientPhone.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text('Contact: ${quote.clientPhone}',
                              style: pw.TextStyle(font: fontRegular, fontSize: 9, color: textMuted)),
                        ],
                        if (quote.clientEmail.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text('Email: ${quote.clientEmail}',
                              style: pw.TextStyle(font: fontRegular, fontSize: 9, color: textMuted)),
                        ],
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 50, color: borderColor),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PROJECT SCOPE & TIMELINE',
                            style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: textMuted)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${quote.category.displayName} (${quote.pageCount} Pages)',
                          style: pw.TextStyle(font: fontBold, fontSize: 11, color: primaryDark),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Estimated Delivery: ${quote.calculation.deliveryDays} Working Days (${quote.urgency.title})',
                          style: pw.TextStyle(font: fontRegular, fontSize: 9, color: textDark),
                        ),
                        pw.Text(
                          'Target Effort: ~${quote.calculation.totalDevHours} Dedicated Dev Hours',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // 3. DELIVERABLES BREAKDOWN TABLE
            pw.Text(
              'Itemized Deliverables & Scope',
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark),
            ),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.8),
              columnWidths: {
                0: const pw.FlexColumnWidth(4.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(2.0),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: tableHeaderBg),
                  children: [
                    _tableCell('Scope / Deliverable Description', fontBold, isHeader: true),
                    _tableCell('Est. Hours', fontBold, isHeader: true, align: pw.TextAlign.center),
                    _tableCell('Included Status', fontBold, isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Core Item
                pw.TableRow(
                  children: [
                    _tableCell(
                      '${quote.category.displayName} - Core Architecture\n'
                      'Architecture setup, responsive layout, semantic navigation, and deployment (${quote.pageCount} Pages)',
                      fontRegular,
                    ),
                    _tableCell('${quote.category.baseHours} hrs', fontRegular, align: pw.TextAlign.center),
                    _tableCell('Core Base', fontMedium, align: pw.TextAlign.right),
                  ],
                ),
                // Add-ons
                ...selectedAddons.map(
                  (addon) => pw.TableRow(
                    children: [
                      _tableCell('${addon.name}\n${addon.description}', fontRegular),
                      _tableCell('${addon.devHours} hrs', fontRegular, align: pw.TextAlign.center),
                      _tableCell('Included Add-on', fontMedium, align: pw.TextAlign.right),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 12),

            // 4. TOTAL INVESTMENT HIGHLIGHT
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFECFDF5), // Light green tint
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: accentGreen, width: 1.2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RECOMMENDED PROFESSIONAL INVESTMENT',
                        style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Guaranteed complete delivery with full code ownership & warranty',
                        style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: textMuted),
                      ),
                    ],
                  ),
                  pw.Text(
                    targetPriceFormatted,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      color: accentGreen,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // 5. 3-TIER INVESTMENT OPTIONS TABLE
            pw.Text(
              'Commercial Tier Packages (Choose Your Best Fit)',
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark),
            ),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.8),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(3.8),
                2: const pw.FlexColumnWidth(1.8),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: tableHeaderBg),
                  children: [
                    _tableCell('Package Tier', fontBold, isHeader: true),
                    _tableCell('Features & Coverage', fontBold, isHeader: true),
                    _tableCell('Investment', fontBold, isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell('1. Essential (Floor)\nCost-Effective Launch', fontMedium),
                    _tableCell('Standard turnaround, core responsive website, basic SEO setup.', fontRegular),
                    _tableCell(starterPriceFormatted, fontBold, align: pw.TextAlign.right),
                  ],
                ),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0FDF4)),
                  children: [
                    _tableCell('2. Professional\n★ RECOMMENDED', fontBold, color: primaryDark),
                    _tableCell('Full selected scope, priority QA, speed optimization, 30-day support warranty.', fontRegular),
                    _tableCell(targetPriceFormatted, fontBold, align: pw.TextAlign.right, color: accentGreen),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell('3. Enterprise Suite\nVIP Acceleration', fontMedium),
                    _tableCell('Express rush turnaround, VIP maintenance, security hardening, dedicated Slack/WhatsApp sync.', fontRegular),
                    _tableCell(enterprisePriceFormatted, fontBold, align: pw.TextAlign.right),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // 6. PAYMENT MILESTONES & TERMS
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PAYMENT MILESTONES & COMMERCIAL TERMS',
                      style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: textDark)),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _milestoneItem('40% Kickoff', 'Advance to book sprint & begin UI architecture', fontMedium, fontRegular),
                      _milestoneItem('40% Demo Milestone', 'Upon staging link approval & feature demo', fontMedium, fontRegular),
                      _milestoneItem('20% Final Launch', 'Live domain handover & production launch', fontMedium, fontRegular),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // 7. AUTHORIZED SIGNATURE
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Terms & Notes:',
                        style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: textDark)),
                    pw.Text('• Quote is valid for 14 days from issue date.',
                        style: pw.TextStyle(font: fontRegular, fontSize: 8, color: textMuted)),
                    pw.Text('• Complete source code & IP ownership transferred upon final payment.',
                        style: pw.TextStyle(font: fontRegular, fontSize: 8, color: textMuted)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 140,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: textDark, width: 1.0)),
                      ),
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      alignment: pw.Alignment.bottomRight,
                      child: pw.Text(
                        settings.founderName,
                        style: pw.TextStyle(font: fontBold, fontSize: 11, color: primaryDark),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('Authorized Lead / Founder',
                        style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: textMuted)),
                    pw.Text(settings.agencyName,
                        style: pw.TextStyle(font: fontMedium, fontSize: 8.5, color: textDark)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _tableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 8.5 : 8,
          color: color ?? (isHeader ? textDark : textDark),
        ),
      ),
    );
  }

  static pw.Widget _milestoneItem(
    String title,
    String description,
    pw.Font fontTitle,
    pw.Font fontDesc,
  ) {
    return pw.Expanded(
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(font: fontTitle, fontSize: 8.5, color: primaryDark)),
            pw.SizedBox(height: 1),
            pw.Text(description, style: pw.TextStyle(font: fontDesc, fontSize: 7.5, color: textMuted)),
          ],
        ),
      ),
    );
  }

  static Future<void> printOrPreviewProposal({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async =>
          await generateProposalPdf(quote: quote, settings: settings),
      name: 'Proposal_${quote.clientName.replaceAll(' ', '_')}_${quote.refCode}.pdf',
    );
  }

  static Future<void> shareProposalPdf({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) async {
    final bytes = await generateProposalPdf(quote: quote, settings: settings);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Proposal_${quote.clientName.replaceAll(' ', '_')}_${quote.refCode}.pdf',
    );
  }
}
