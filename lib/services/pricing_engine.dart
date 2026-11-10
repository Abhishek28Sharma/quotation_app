import '../models/quote_model.dart';
import '../models/settings_model.dart';

class PricingEngine {
  static const double perAdditionalPageINR = 1200.0;
  static const double subFivePageDiscountINR = 2000.0;
  static const int baselinePages = 5;

  static QuoteCalculationResult calculate({
    required double baseRateINR,
    required WebsiteCategory category,
    required int pageCount,
    required List<String> selectedAddonIds,
    required ClientBudgetSensitivity sensitivity,
    required DeliveryUrgency urgency,
    required Currency currency,
  }) {
    // 1. Category adjusted base
    final double categoryAdjustedBase = baseRateINR * category.multiplier;

    // 2. Page scaling
    double pageAdjustment = 0.0;
    if (pageCount > baselinePages) {
      pageAdjustment = (pageCount - baselinePages) * perAdditionalPageINR;
    } else if (pageCount < baselinePages) {
      pageAdjustment = -subFivePageDiscountINR;
    }

    // 3. Add-on features
    double addOnsTotal = 0.0;
    int addOnsHours = 0;
    for (final addon in FeatureAddon.allAddons) {
      if (selectedAddonIds.contains(addon.id)) {
        addOnsTotal += addon.priceINR;
        addOnsHours += addon.devHours;
      }
    }

    // 4. Raw Subtotal before strategy & urgency
    double rawSubtotal = categoryAdjustedBase + pageAdjustment + addOnsTotal;
    if (rawSubtotal < 5000) {
      rawSubtotal = 5000; // Safeguard floor
    }

    // 5. Apply Strategy and Urgency multipliers
    final double combinedMultiplier = sensitivity.multiplier * urgency.multiplier;
    final double targetPriceINR = rawSubtotal * combinedMultiplier;
    final double starterPriceINR = targetPriceINR * 0.80; // 80% safety floor
    final double enterprisePriceINR = targetPriceINR * 1.32; // 132% upsell suite

    // 6. Currency Conversion
    final double targetPrice = _roundCurrency(targetPriceINR * currency.multiplier, currency);
    final double starterPrice = _roundCurrency(starterPriceINR * currency.multiplier, currency);
    final double enterprisePrice = _roundCurrency(enterprisePriceINR * currency.multiplier, currency);

    // 7. Dev Hours & Delivery days calculation
    int pageDevHours = 0;
    if (pageCount > baselinePages) {
      pageDevHours = ((pageCount - baselinePages) * 1.5).round();
    }
    final int totalDevHours = category.baseHours + pageDevHours + addOnsHours;

    int estimatedDays = urgency.workingDays;
    if (pageCount > 10) {
      estimatedDays += ((pageCount - 10) * 0.5).round();
    }
    if (addOnsHours > 15) {
      estimatedDays += 3;
    }

    return QuoteCalculationResult(
      baseRateINR: baseRateINR,
      categoryAdjustedBaseINR: categoryAdjustedBase,
      pageAdjustmentINR: pageAdjustment,
      addOnsTotalINR: addOnsTotal,
      rawSubtotalINR: rawSubtotal,
      targetPriceINR: targetPriceINR,
      starterPriceINR: starterPriceINR,
      enterprisePriceINR: enterprisePriceINR,
      targetPrice: targetPrice,
      starterPrice: starterPrice,
      enterprisePrice: enterprisePrice,
      totalDevHours: totalDevHours,
      deliveryDays: estimatedDays,
      currency: currency,
    );
  }

  static double _roundCurrency(double value, Currency currency) {
    if (currency == Currency.inr) {
      // Round to nearest 50 for clean professional quotes
      return (value / 50).round() * 50.0;
    } else {
      // For foreign currencies round to nearest integer or 5
      return value.roundToDouble();
    }
  }

  static String formatAmount(double amount, Currency currency) {
    final int intVal = amount.round();
    final String sign = currency.symbol;
    if (currency == Currency.inr) {
      // Indian numbering format (e.g. 25,000)
      return '$sign${_formatIndianNumber(intVal)}';
    } else {
      return '$sign${_formatStandardNumber(intVal)}';
    }
  }

  static String _formatIndianNumber(int number) {
    final str = number.abs().toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    final result = '$formattedRest,$lastThree';
    return number < 0 ? '-$result' : result;
  }

  static String _formatStandardNumber(int number) {
    final str = number.abs().toString();
    final reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return number < 0 ? '-$formatted' : formatted;
  }
}
