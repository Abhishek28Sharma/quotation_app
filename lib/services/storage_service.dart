import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';
import '../models/settings_model.dart';

class StorageService {
  static const String _settingsKey = 'quotecraft_agency_settings';
  static const String _quotesKey = 'quotecraft_saved_quotes';
  static const String _quoteCounterKey = 'quotecraft_quote_counter';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Settings
  static Future<AgencySettings> loadSettings() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        return AgencySettings.fromJson(jsonString);
      } catch (e) {
        // Fallback to default
      }
    }
    return const AgencySettings();
  }

  static Future<bool> saveSettings(AgencySettings settings) async {
    final prefs = await _getPrefs();
    return await prefs.setString(_settingsKey, settings.toJson());
  }

  // Quote History
  static Future<List<QuoteRecord>> loadQuotes() async {
    final prefs = await _getPrefs();
    final jsonListString = prefs.getString(_quotesKey);
    if (jsonListString == null || jsonListString.isEmpty) {
      return [];
    }
    try {
      final List decoded = json.decode(jsonListString) as List;
      final quotes = decoded
          .map((item) => QuoteRecord.fromMap(item as Map<String, dynamic>))
          .toList();
      // Sort newest first
      quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return quotes;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveQuote(QuoteRecord quote) async {
    final prefs = await _getPrefs();
    final quotes = await loadQuotes();
    // Replace if existing with same id, or prepend
    final existingIndex = quotes.indexWhere((q) => q.id == quote.id);
    if (existingIndex >= 0) {
      quotes[existingIndex] = quote;
    } else {
      quotes.insert(0, quote);
    }

    final encoded = json.encode(quotes.map((q) => q.toMap()).toList());
    return await prefs.setString(_quotesKey, encoded);
  }

  static Future<bool> deleteQuote(String id) async {
    final prefs = await _getPrefs();
    final quotes = await loadQuotes();
    quotes.removeWhere((q) => q.id == id);
    final encoded = json.encode(quotes.map((q) => q.toMap()).toList());
    return await prefs.setString(_quotesKey, encoded);
  }

  static Future<String> generateNextRefCode() async {
    final prefs = await _getPrefs();
    final int current = prefs.getInt(_quoteCounterKey) ?? 100;
    final int next = current + 1;
    await prefs.setInt(_quoteCounterKey, next);
    final year = DateTime.now().year;
    return 'QC-$year-$next';
  }
}
