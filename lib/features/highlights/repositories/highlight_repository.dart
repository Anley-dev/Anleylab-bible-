import 'package:amharic_catholic_bible/features/highlights/models/highlight.dart';

/// Simple in‑memory repository for [Highlight] objects.
class HighlightRepository {
  final List<Highlight> _highlights = [];

  /// Returns an immutable list of all stored highlights.
  List<Highlight> getAll() => List.unmodifiable(_highlights);

  /// Async version used by UI
  Future<List<Highlight>> getHighlights() async => getAll();

  /// Save a new highlight
  Future<void> saveHighlight(Highlight h) async => add(h);

  /// Remove a specific highlight by book/chapter/verse
  Future<void> removeHighlight(String book, int chapter, int verse) async {
    _highlights.removeWhere((h) => h.book == book && h.chapter == chapter && h.verseNumber == verse);
  }

  /// Adds a new highlight.
  void add(Highlight highlight) => _highlights.add(highlight);

  /// Removes a highlight.
  void remove(Highlight highlight) => _highlights.remove(highlight);

  /// Clears all highlights – useful for testing.
  void clear() => _highlights.clear();
}
