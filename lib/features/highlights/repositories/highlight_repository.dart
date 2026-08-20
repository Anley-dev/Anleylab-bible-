import 'dart:convert';
import 'package:amharic_catholic_bible/features/highlights/models/highlight.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';

/// Repository for [Highlight] objects, persisted to SharedPreferences.
class HighlightRepository {
  static final HighlightRepository _instance = HighlightRepository._internal();
  factory HighlightRepository() => _instance;

  final List<Highlight> _highlights = [];
  static const String _storageKey = 'user_highlights';

  HighlightRepository._internal() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final String? data = StorageService.getString(_storageKey);
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _highlights.clear();
        for (var item in jsonList) {
          _highlights.add(Highlight(
            book: item['book'],
            chapter: item['chapter'],
            verseNumber: item['verseNumber'],
            colorHex: item['colorHex'],
          ));
        }
      } catch (e) {
        // Handle error quietly
      }
    }
  }

  void _saveToStorage() {
    final List<Map<String, dynamic>> jsonList = _highlights.map((h) => {
      'book': h.book,
      'chapter': h.chapter,
      'verseNumber': h.verseNumber,
      'colorHex': h.colorHex,
    }).toList();
    StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Returns an immutable list of all stored highlights.
  List<Highlight> getAll() => List.unmodifiable(_highlights);

  /// Async version used by UI
  Future<List<Highlight>> getHighlights() async => getAll();

  /// Save a new highlight
  Future<void> saveHighlight(Highlight h) async {
    remove(h); // Ensure no duplicates for same verse
    _highlights.add(h);
    _saveToStorage();
  }

  /// Remove a specific highlight by book/chapter/verse
  Future<void> removeHighlight(String book, int chapter, int verse) async {
    _highlights.removeWhere((h) => h.book == book && h.chapter == chapter && h.verseNumber == verse);
    _saveToStorage();
  }

  /// Removes a highlight.
  void remove(Highlight highlight) {
    _highlights.removeWhere((h) => h.book == highlight.book && h.chapter == highlight.chapter && h.verseNumber == highlight.verseNumber);
    _saveToStorage();
  }

  /// Clears all highlights.
  void clear() {
    _highlights.clear();
    StorageService.remove(_storageKey);
  }
}
