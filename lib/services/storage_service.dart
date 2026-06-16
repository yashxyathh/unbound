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

  // Convert to JSON to store in SharedPreferences
  Map<String, dynamic> toJson() => {
        'inputText':  inputText,
        'outputText': outputText,
        'fromLang':   fromLang,
        'toLang':     toLang,
        'timestamp':  timestamp.toIso8601String(),
      };

  // Convert from JSON when reading back
  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        inputText:  json['inputText']  as String,
        outputText: json['outputText'] as String,
        fromLang:   json['fromLang']   as String,
        toLang:     json['toLang']     as String,
        timestamp:  DateTime.parse(json['timestamp'] as String),
      );
}

// ── Storage service ───────────────────────────────────────────────────────────
class StorageService {
  static const String _historyKey = 'translation_history';
  static const int    _maxHistory = 50; // keep last 50 translations

  // ── Save a new translation to history ────────────────────────────────────
  static Future<void> saveToHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await getHistory();

    // Add new item at the top
    list.insert(0, item);

    // Keep only last 50
    if (list.length > _maxHistory) {
      list.removeRange(_maxHistory, list.length);
    }

    // Encode and save
    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  // ── Read all history items ────────────────────────────────────────────────
  static Future<List<HistoryItem>> getHistory() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_historyKey) ?? [];
    return encoded
        .map((e) => HistoryItem.fromJson(jsonDecode(e)))
        .toList();
  }

  // ── Delete a single item by index ─────────────────────────────────────────
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
}