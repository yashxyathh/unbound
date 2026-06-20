import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ── Single history item model ─────────────────────────────────────────────────
class HistoryItem {
  final String inputText;
  final String outputText;
  final String fromLang;
  final String toLang;
  final DateTime timestamp;

  HistoryItem({
    required this.inputText,
    required this.outputText,
    required this.fromLang,
    required this.toLang,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'inputText':  inputText,
        'outputText': outputText,
        'fromLang':   fromLang,
        'toLang':     toLang,
        'timestamp':  timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        inputText:  json['inputText']  as String,
        outputText: json['outputText'] as String,
        fromLang:   json['fromLang']   as String,
        toLang:     json['toLang']     as String,
        timestamp:  DateTime.parse(json['timestamp'] as String),
      );
}

// ── Single saved (favourite) item model ───────────────────────────────────────
class SavedItem {
  final String inputText;
  final String outputText;
  final String fromLang;
  final String toLang;
  final DateTime timestamp;

  SavedItem({
    required this.inputText,
    required this.outputText,
    required this.fromLang,
    required this.toLang,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'inputText':  inputText,
        'outputText': outputText,
        'fromLang':   fromLang,
        'toLang':     toLang,
        'timestamp':  timestamp.toIso8601String(),
      };

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
        inputText:  json['inputText']  as String,
        outputText: json['outputText'] as String,
        fromLang:   json['fromLang']   as String,
        toLang:     json['toLang']     as String,
        timestamp:  DateTime.parse(json['timestamp'] as String),
      );

  // Unique key used to check duplicates / match for un-saving
  String get uniqueKey => '$inputText|$outputText|$fromLang|$toLang';
}

// ── Storage service ───────────────────────────────────────────────────────────
class StorageService {
  static const String _historyKey = 'translation_history';
  static const String _savedKey   = 'saved_translations';
  static const int    _maxHistory = 50; // keep last 50 translations

  // ── Save a new translation to history ────────────────────────────────────
  static Future<void> saveToHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getHistory();

    list.insert(0, item);
    if (list.length > _maxHistory) {
      list.removeRange(_maxHistory, list.length);
    }

    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  // ── Read all history items ────────────────────────────────────────────────
  static Future<List<HistoryItem>> getHistory() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_historyKey) ?? [];
    return encoded.map((e) => HistoryItem.fromJson(jsonDecode(e))).toList();
  }

  // ── Delete a single history item by index ─────────────────────────────────
  static Future<void> deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getHistory();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_historyKey, encoded);
    }
  }

  // ── Clear all history ─────────────────────────────────────────────────────
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Save an item to favourites ────────────────────────────────────────────
  static Future<void> saveToFavorites(SavedItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getFavorites();

    if (list.any((e) => e.uniqueKey == item.uniqueKey)) return; // no duplicates

    list.insert(0, item);
    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_savedKey, encoded);
  }

  // ── Read all favourites ───────────────────────────────────────────────────
  static Future<List<SavedItem>> getFavorites() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_savedKey) ?? [];
    return encoded.map((e) => SavedItem.fromJson(jsonDecode(e))).toList();
  }

  // ── Remove a favourite by its uniqueKey ───────────────────────────────────
  static Future<void> removeFavorite(String uniqueKey) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getFavorites();
    list.removeWhere((e) => e.uniqueKey == uniqueKey);
    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_savedKey, encoded);
  }

  // ── Check if an item is already favourited ────────────────────────────────
  static Future<bool> isFavorited(String uniqueKey) async {
    final list = await getFavorites();
    return list.any((e) => e.uniqueKey == uniqueKey);
  }
}