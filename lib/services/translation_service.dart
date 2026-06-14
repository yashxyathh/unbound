import 'dart:convert';
import 'package:http/http.dart' as http;

// ── Language name → language code map ────────────────────────────────────────
// Must match the names used in language_selector_screen.dart
const Map<String, String> kLangCodes = {
  'Afrikaans': 'af',
  'Arabic': 'ar',
  'Bengali': 'bn',
  'Bulgarian': 'bg',
  'Chinese': 'zh',
  'Croatian': 'hr',
  'Czech': 'cs',
  'Danish': 'da',
  'Dutch': 'nl',
  'English': 'en',
  'Finnish': 'fi',
  'French': 'fr',
  'German': 'de',
  'Greek': 'el',
  'Gujarati': 'gu',
  'Hebrew': 'he',
  'Hindi': 'hi',
  'Hungarian': 'hu',
  'Indonesian': 'id',
  'Italian': 'it',
  'Japanese': 'ja',
  'Kannada': 'kn',
  'Korean': 'ko',
  'Malay': 'ms',
  'Malayalam': 'ml',
  'Marathi': 'mr',
  'Nepali': 'ne',
  'Norwegian': 'no',
  'Odia': 'or',
  'Persian': 'fa',
  'Polish': 'pl',
  'Portuguese': 'pt',
  'Punjabi': 'pa',
  'Romanian': 'ro',
  'Russian': 'ru',
  'Sanskrit': 'sa',
  'Serbian': 'sr',
  'Sinhala': 'si',
  'Slovak': 'sk',
  'Spanish': 'es',
  'Swahili': 'sw',
  'Swedish': 'sv',
  'Tamil': 'ta',
  'Telugu': 'te',
  'Thai': 'th',
  'Turkish': 'tr',
  'Ukrainian': 'uk',
  'Urdu': 'ur',
  'Vietnamese': 'vi',
};

// ── Result model ──────────────────────────────────────────────────────────────
class TranslationResult {
  final String translatedText;
  final String? errorMessage;

  const TranslationResult({required this.translatedText, this.errorMessage});

  bool get hasError => errorMessage != null;
}

// ── Service class ─────────────────────────────────────────────────────────────
class TranslationService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  /// Translates [text] from [fromLang] to [toLang].
  /// [fromLang] and [toLang] are full language names e.g. "English", "Tamil"
  static Future<TranslationResult> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    // Guard: empty text
    if (text.trim().isEmpty) {
      return const TranslationResult(translatedText: '');
    }

    // Guard: unknown language
    final fromCode = fromLang == 'Auto Detect' ? 'en' : kLangCodes[fromLang];
    final toCode = kLangCodes[toLang];

    if (fromCode == null || toCode == null) {
      return TranslationResult(
        translatedText: '',
        errorMessage:
            'Language not supported: ${fromCode == null ? fromLang : toLang}',
      );
    }

    // Guard: same language
    if (fromCode == toCode) {
      return TranslationResult(translatedText: text);
    }

    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'q': text, 'langpair': '$fromCode|$toCode'});

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return TranslationResult(
          translatedText: '',
          errorMessage: 'Server error (${response.statusCode}). Try again.',
        );
      }

      final body = jsonDecode(response.body);

      // MyMemory returns responseStatus 200 on success
      final status = body['responseStatus'];
      if (status != 200) {
        return TranslationResult(
          translatedText: '',
          errorMessage: 'Translation failed. Check your connection.',
        );
      }

      final translated = body['responseData']['translatedText'] as String;

      // MyMemory sometimes echoes the original on failure
      if (translated.toLowerCase() == text.toLowerCase()) {
        return TranslationResult(
          translatedText: translated,
          errorMessage:
              'Could not translate. Language pair may not be supported.',
        );
      }

      return TranslationResult(translatedText: translated);
    } on Exception catch (e) {
      return TranslationResult(
        translatedText: '',
        errorMessage: 'No internet connection. Please try again.',
      );
    }
  }
}
