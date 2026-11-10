import 'dart:convert';

enum Currency {
  inr(code: 'INR', symbol: '₹', multiplier: 1.0),
  usd(code: 'USD', symbol: '\$', multiplier: 0.012),
  eur(code: 'EUR', symbol: '€', multiplier: 0.011),
  gbp(code: 'GBP', symbol: '£', multiplier: 0.0095),
  aed(code: 'AED', symbol: 'AED ', multiplier: 0.044);

  final String code;
  final String symbol;
  final double multiplier;

  const Currency({
    required this.code,
    required this.symbol,
    required this.multiplier,
  });

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => Currency.inr,
    );
  }
}

class AgencySettings {
  final double baseRateINR;
  final Currency currency;
  final String agencyName;
  final String founderName;
  final String tagline;

  const AgencySettings({
    this.baseRateINR = 15000.0,
    this.currency = Currency.inr,
    this.agencyName = 'CraftStudio Digital',
    this.founderName = 'Alex Morgan',
    this.tagline = 'High-Performance Web Solutions & SaaS Architecture',
  });

  AgencySettings copyWith({
    double? baseRateINR,
    Currency? currency,
    String? agencyName,
    String? founderName,
    String? tagline,
  }) {
    return AgencySettings(
      baseRateINR: baseRateINR ?? this.baseRateINR,
      currency: currency ?? this.currency,
      agencyName: agencyName ?? this.agencyName,
      founderName: founderName ?? this.founderName,
      tagline: tagline ?? this.tagline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseRateINR': baseRateINR,
      'currency': currency.code,
      'agencyName': agencyName,
      'founderName': founderName,
      'tagline': tagline,
    };
  }

  factory AgencySettings.fromMap(Map<String, dynamic> map) {
    return AgencySettings(
      baseRateINR: (map['baseRateINR'] as num?)?.toDouble() ?? 15000.0,
      currency: Currency.fromCode(map['currency'] as String? ?? 'INR'),
      agencyName: map['agencyName'] as String? ?? 'CraftStudio Digital',
      founderName: map['founderName'] as String? ?? 'Alex Morgan',
      tagline: map['tagline'] as String? ?? 'High-Performance Web Solutions & SaaS Architecture',
    );
  }

  String toJson() => json.encode(toMap());

  factory AgencySettings.fromJson(String source) =>
      AgencySettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
