import 'dart:convert';
import 'settings_model.dart';

enum WebsiteCategory {
  landingPage(
    displayName: 'Landing Page',
    description: 'Single high-converting page',
    multiplier: 1.0,
    baseHours: 18,
  ),
  business(
    displayName: 'Business / Corporate',
    description: 'Multi-page standard company site',
    multiplier: 1.4,
    baseHours: 32,
  ),
  ecommerce(
    displayName: 'E-Commerce Store',
    description: 'Product catalog, cart & payments',
    multiplier: 2.2,
    baseHours: 60,
  ),
  webApp(
    displayName: 'Custom Web App / SaaS MVP',
    description: 'Portals, auth & dashboards',
    multiplier: 2.8,
    baseHours: 85,
  ),
  blog(
    displayName: 'Blog / Media Portal',
    description: 'Publishing & articles',
    multiplier: 1.2,
    baseHours: 26,
  );

  final String displayName;
  final String description;
  final double multiplier;
  final int baseHours;

  const WebsiteCategory({
    required this.displayName,
    required this.description,
    required this.multiplier,
    required this.baseHours,
  });

  static WebsiteCategory fromName(String name) {
    return WebsiteCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => WebsiteCategory.business,
    );
  }
}

class FeatureAddon {
  final String id;
  final String name;
  final String description;
  final double priceINR;
  final int devHours;

  const FeatureAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.priceINR,
    required this.devHours,
  });

  static const List<FeatureAddon> allAddons = [
    FeatureAddon(
      id: 'seo',
      name: 'On-Page SEO & Meta Tags',
      description: 'Search engine keyword optimization, meta tags, OpenGraph & sitemap',
      priceINR: 2500,
      devHours: 4,
    ),
    FeatureAddon(
      id: 'responsive',
      name: '100% Mobile Responsive Layout',
      description: 'Pixel-perfect UX on smartphones, foldables, tablets & monitors',
      priceINR: 1500,
      devHours: 3,
    ),
    FeatureAddon(
      id: 'whatsapp_leads',
      name: 'WhatsApp & Direct Lead Capture',
      description: 'Floating click-to-chat CTA & automated inquiry alerts',
      priceINR: 1000,
      devHours: 2,
    ),
    FeatureAddon(
      id: 'payment_gateway',
      name: 'Payment Gateway Setup (Razorpay/Stripe/UPI)',
      description: 'Secure checkout integration with webhook callbacks & receipts',
      priceINR: 3500,
      devHours: 6,
    ),
    FeatureAddon(
      id: 'speed_optimization',
      name: 'Speed & Cache Optimization (Sub-2s load)',
      description: 'Gzip compression, CDN edge assets, next-gen WebP images',
      priceINR: 2000,
      devHours: 3,
    ),
    FeatureAddon(
      id: 'admin_dashboard',
      name: 'Custom Admin / CMS Dashboard',
      description: 'Intuitive management portal to edit text, media & blogs effortlessly',
      priceINR: 4000,
      devHours: 8,
    ),
    FeatureAddon(
      id: 'ssl_security',
      name: 'SSL & Security Hardening',
      description: 'HTTPS enforcement, DDoS shields, CSP & anti-spam form defense',
      priceINR: 1500,
      devHours: 2,
    ),
    FeatureAddon(
      id: 'post_launch_support',
      name: '30-Day Post-Launch Support & Bug Warranty',
      description: 'Dedicated priority bug fixing, minor copy changes & peace of mind',
      priceINR: 2500,
      devHours: 4,
    ),
  ];
}

enum ClientBudgetSensitivity {
  competitive(
    title: 'Competitive / Price-Sensitive',
    subtitle: 'Lowest safe price (0.88x) to win against rivals',
    multiplier: 0.88,
  ),
  balanced(
    title: 'Balanced (Recommended)',
    subtitle: 'Optimal value and healthy profit margin (1.0x)',
    multiplier: 1.0,
  ),
  premium(
    title: 'Premium / Corporate',
    subtitle: 'Enterprise margin & white-glove delivery (1.25x)',
    multiplier: 1.25,
  );

  final String title;
  final String subtitle;
  final double multiplier;

  const ClientBudgetSensitivity({
    required this.title,
    required this.subtitle,
    required this.multiplier,
  });

  static ClientBudgetSensitivity fromName(String name) {
    return ClientBudgetSensitivity.values.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => ClientBudgetSensitivity.balanced,
    );
  }
}

enum DeliveryUrgency {
  standard(
    title: 'Standard Timeline (10–14 days)',
    multiplier: 1.0,
    workingDays: 12,
  ),
  rush(
    title: 'Rush Priority (5–7 days) [+25%]',
    multiplier: 1.25,
    workingDays: 6,
  ),
  flexible(
    title: 'Flexible (3–4 weeks) [-5%]',
    multiplier: 0.95,
    workingDays: 21,
  );

  final String title;
  final double multiplier;
  final int workingDays;

  const DeliveryUrgency({
    required this.title,
    required this.multiplier,
    required this.workingDays,
  });

  static DeliveryUrgency fromName(String name) {
    return DeliveryUrgency.values.firstWhere(
      (u) => u.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DeliveryUrgency.standard,
    );
  }
}

class QuoteCalculationResult {
  final double baseRateINR;
  final double categoryAdjustedBaseINR;
  final double pageAdjustmentINR;
  final double addOnsTotalINR;
  final double rawSubtotalINR;
  final double targetPriceINR;
  final double starterPriceINR;
  final double enterprisePriceINR;
  final double targetPrice;
  final double starterPrice;
  final double enterprisePrice;
  final int totalDevHours;
  final int deliveryDays;
  final Currency currency;

  const QuoteCalculationResult({
    required this.baseRateINR,
    required this.categoryAdjustedBaseINR,
    required this.pageAdjustmentINR,
    required this.addOnsTotalINR,
    required this.rawSubtotalINR,
    required this.targetPriceINR,
    required this.starterPriceINR,
    required this.enterprisePriceINR,
    required this.targetPrice,
    required this.starterPrice,
    required this.enterprisePrice,
    required this.totalDevHours,
    required this.deliveryDays,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseRateINR': baseRateINR,
      'categoryAdjustedBaseINR': categoryAdjustedBaseINR,
      'pageAdjustmentINR': pageAdjustmentINR,
      'addOnsTotalINR': addOnsTotalINR,
      'rawSubtotalINR': rawSubtotalINR,
      'targetPriceINR': targetPriceINR,
      'starterPriceINR': starterPriceINR,
      'enterprisePriceINR': enterprisePriceINR,
      'targetPrice': targetPrice,
      'starterPrice': starterPrice,
      'enterprisePrice': enterprisePrice,
      'totalDevHours': totalDevHours,
      'deliveryDays': deliveryDays,
      'currency': currency.code,
    };
  }

  factory QuoteCalculationResult.fromMap(Map<String, dynamic> map) {
    return QuoteCalculationResult(
      baseRateINR: (map['baseRateINR'] as num?)?.toDouble() ?? 15000.0,
      categoryAdjustedBaseINR: (map['categoryAdjustedBaseINR'] as num?)?.toDouble() ?? 15000.0,
      pageAdjustmentINR: (map['pageAdjustmentINR'] as num?)?.toDouble() ?? 0.0,
      addOnsTotalINR: (map['addOnsTotalINR'] as num?)?.toDouble() ?? 0.0,
      rawSubtotalINR: (map['rawSubtotalINR'] as num?)?.toDouble() ?? 15000.0,
      targetPriceINR: (map['targetPriceINR'] as num?)?.toDouble() ?? 15000.0,
      starterPriceINR: (map['starterPriceINR'] as num?)?.toDouble() ?? 12000.0,
      enterprisePriceINR: (map['enterprisePriceINR'] as num?)?.toDouble() ?? 19800.0,
      targetPrice: (map['targetPrice'] as num?)?.toDouble() ?? 15000.0,
      starterPrice: (map['starterPrice'] as num?)?.toDouble() ?? 12000.0,
      enterprisePrice: (map['enterprisePrice'] as num?)?.toDouble() ?? 19800.0,
      totalDevHours: (map['totalDevHours'] as num?)?.toInt() ?? 30,
      deliveryDays: (map['deliveryDays'] as num?)?.toInt() ?? 12,
      currency: Currency.fromCode(map['currency'] as String? ?? 'INR'),
    );
  }
}

class QuoteRecord {
  final String id;
  final String refCode;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final WebsiteCategory category;
  final int pageCount;
  final List<String> selectedAddonIds;
  final ClientBudgetSensitivity sensitivity;
  final DeliveryUrgency urgency;
  final QuoteCalculationResult calculation;
  final DateTime createdAt;

  const QuoteRecord({
    required this.id,
    required this.refCode,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.category,
    required this.pageCount,
    required this.selectedAddonIds,
    required this.sensitivity,
    required this.urgency,
    required this.calculation,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'refCode': refCode,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientEmail': clientEmail,
      'category': category.name,
      'pageCount': pageCount,
      'selectedAddonIds': selectedAddonIds,
      'sensitivity': sensitivity.name,
      'urgency': urgency.name,
      'calculation': calculation.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuoteRecord.fromMap(Map<String, dynamic> map) {
    return QuoteRecord(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      refCode: map['refCode'] as String? ?? 'QC-001',
      clientName: map['clientName'] as String? ?? 'Valued Client',
      clientPhone: map['clientPhone'] as String? ?? '',
      clientEmail: map['clientEmail'] as String? ?? '',
      category: WebsiteCategory.fromName(map['category'] as String? ?? 'business'),
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 5,
      selectedAddonIds: List<String>.from(map['selectedAddonIds'] as List? ?? []),
      sensitivity: ClientBudgetSensitivity.fromName(map['sensitivity'] as String? ?? 'balanced'),
      urgency: DeliveryUrgency.fromName(map['urgency'] as String? ?? 'standard'),
      calculation: QuoteCalculationResult.fromMap(map['calculation'] as Map<String, dynamic>),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuoteRecord.fromJson(String source) =>
      QuoteRecord.fromMap(json.decode(source) as Map<String, dynamic>);
}
