import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-verse highlight colours as hex strings in SharedPreferences.
///
/// Key format: "bookName|chapter|verseNumber"
/// Value: either a plain hex colour string (legacy) or a JSON object with
/// a color and optional selected text.
class HighlightService {
  static const String _primaryKey = 'highlights';
  static const String _legacyKey = 'user_highlights';

  // ---------------------------------------------------------------------------
  // Key helper
  // ---------------------------------------------------------------------------

  static String makeKey(String bookName, int chapter, int verseNumber) =>
      '$bookName|$chapter|$verseNumber';

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns the full highlights map: { verseKey -> hexColorString }.
  static Future<Map<String, String>> getHighlights() async {
    final prefs = await SharedPreferences.getInstance();

    final primaryRaw = prefs.getString(_primaryKey);
    if (primaryRaw != null) {
      return _decodeHighlights(primaryRaw);
    }

    final legacyRaw = prefs.getString(_legacyKey);
    if (legacyRaw != null) {
      final migrated = _decodeHighlights(legacyRaw);
      if (migrated.isNotEmpty) {
        await prefs.setString(_primaryKey, jsonEncode(migrated));
        await prefs.remove(_legacyKey);
      }
      return migrated;
    }

    return {};
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  static Future<void> saveHighlight(
    String bookName,
    int chapter,
    int verseNumber,
    String hexColor, {
    String? selectedText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final highlights = await getHighlights();
    final payload = <String, dynamic>{
      'color': hexColor,
      if (selectedText != null && selectedText.trim().isNotEmpty) 'text': selectedText.trim(),
    };
    highlights[makeKey(bookName, chapter, verseNumber)] = jsonEncode(payload);
    await prefs.setString(_primaryKey, jsonEncode(highlights));
    await prefs.remove(_legacyKey);
  }

  static Future<void> removeHighlight(
    String bookName,
    int chapter,
    int verseNumber,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final highlights = await getHighlights();
    highlights.remove(makeKey(bookName, chapter, verseNumber));
    await prefs.setString(_primaryKey, jsonEncode(highlights));
    await prefs.remove(_legacyKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryKey);
    await prefs.remove(_legacyKey);
  }

  static Future<Map<String, String>> getHighlightTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryRaw = prefs.getString(_primaryKey);
    if (primaryRaw == null) {
      return {};
    }

    final decoded = jsonDecode(primaryRaw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }

    final result = <String, String>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is String) {
        try {
          final payload = jsonDecode(value);
          if (payload is Map<String, dynamic>) {
            final text = payload['text']?.toString();
            if (text != null && text.isNotEmpty) {
              result[entry.key] = text;
            }
          }
        } catch (_) {
          // Ignore malformed payloads.
        }
      }
    }
    return result;
  }

  static Map<String, String> _decodeHighlights(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }

    return decoded.map((key, value) {
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.startsWith('{')) {
          try {
            final payload = jsonDecode(trimmed);
            if (payload is Map<String, dynamic>) {
              final color = payload['color']?.toString();
              return MapEntry(key, color ?? '');
            }
          } catch (_) {
            // Fall back to the raw string.
          }
        }
        return MapEntry(key, trimmed);
      }

      if (value is Map<String, dynamic>) {
        final color = value['color']?.toString();
        return MapEntry(key, color ?? '');
      }

      return MapEntry(key, value.toString());
    });
  }
}