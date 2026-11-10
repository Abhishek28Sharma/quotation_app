import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote_model.dart';
import '../models/settings_model.dart';
import 'pricing_engine.dart';

class SharingService {
  static String formatWhatsAppMessage({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) {
    final currency = quote.calculation.currency;
    final recommendedFormatted = PricingEngine.formatAmount(quote.calculation.targetPrice, currency);
    final starterFormatted = PricingEngine.formatAmount(quote.calculation.starterPrice, currency);
    final enterpriseFormatted = PricingEngine.formatAmount(quote.calculation.enterprisePrice, currency);

    final clientName = quote.clientName.trim().isEmpty ? 'Valued Client' : quote.clientName.trim();
    final founder = settings.founderName.trim().isEmpty ? 'Our Team' : settings.founderName.trim();
    final agency = settings.agencyName.trim().isEmpty ? 'QuoteCraft Agency' : settings.agencyName.trim();

    // Collect key deliverables bullet points
    final List<String> bulletPoints = [
      '• Custom Responsive UI for phones, tablets & desktop',
    ];

    if (quote.selectedAddonIds.contains('seo')) {
      bulletPoints.add('• On-page SEO & Google search indexing');
    }
    if (quote.selectedAddonIds.contains('whatsapp_leads')) {
      bulletPoints.add('• WhatsApp & Direct Lead Capture integration');
    }
    if (quote.selectedAddonIds.contains('payment_gateway')) {
      bulletPoints.add('• Secure Payment Gateway checkout (Razorpay/Stripe/UPI)');
    }
    if (quote.selectedAddonIds.contains('admin_dashboard')) {
      bulletPoints.add('• Custom Admin / CMS Dashboard access');
    }
    if (quote.selectedAddonIds.contains('post_launch_support')) {
      bulletPoints.add('• 30-Day post-launch support & bug warranty');
    } else {
      bulletPoints.add('• 14-Day post-launch warranty & onboarding');
    }

    final bulletsText = bulletPoints.join('\n');

    return '''Hi $clientName,

Thank you for discussing your website requirement with us! Here is our proposal:

🚀 Project: ${quote.category.displayName} (${quote.pageCount} Pages)
⏱️ Delivery: ${quote.calculation.deliveryDays} Working Days

💰 Recommended Investment: $recommendedFormatted
$bulletsText

📊 Package Options:
1️⃣ Essential: $starterFormatted
2️⃣ Professional (Recommended): $recommendedFormatted
3️⃣ Enterprise Suite: $enterpriseFormatted

💳 Payment Terms:
• 40% Advance kickoff
• 40% Staging demo approval
• 20% Final launch & domain mapping

Let me know if you would like any adjustments to the scope!

Best regards,
$founder
$agency''';
  }

  static Future<bool> sendWhatsAppQuote({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) async {
    final message = formatWhatsAppMessage(quote: quote, settings: settings);
    final cleanPhone = quote.clientPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Encode message for URL
    final encodedText = Uri.encodeComponent(message);

    Uri directUri;
    if (cleanPhone.isNotEmpty) {
      directUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedText');
    } else {
      directUri = Uri.parse('whatsapp://send?text=$encodedText');
    }

    try {
      if (await canLaunchUrl(directUri)) {
        return await launchUrl(directUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback below
    }

    // Try web link if app scheme fails
    try {
      final webUri = cleanPhone.isNotEmpty
          ? Uri.parse('https://wa.me/$cleanPhone?text=$encodedText')
          : Uri.parse('https://api.whatsapp.com/send?text=$encodedText');
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback to share sheet
    }

    // Fallback to standard share sheet
    try {
      await Share.share(message, subject: 'Website Quotation - ${quote.category.displayName}');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> shareAsText({
    required QuoteRecord quote,
    required AgencySettings settings,
  }) async {
    final message = formatWhatsAppMessage(quote: quote, settings: settings);
    await Share.share(message, subject: 'Commercial Proposal - ${quote.clientName}');
  }
}
