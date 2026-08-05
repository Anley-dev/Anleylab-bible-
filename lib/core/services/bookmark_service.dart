import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amharic_catholic_bible/data/models/bookmark_model.dart';

/// Handles persisting and retrieving [Bookmark] objects via SharedPreferences.
class BookmarkService {
  static const String _key = 'bookmarks';

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  static Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => Bookmark.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  /// Returns `true` if the given verse is already bookmarked.
  static Future<bool> isBookmarked({
    required String bookName,
    required int chapter,
    required int verseNumber,
  }) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (b) =>
          b.bookName == bookName &&
          b.chapter == chapter &&
          b.verseNumber == verseNumber,
    );
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  static Future<void> addBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    // Prevent exact duplicates
    final alreadyExists = bookmarks.any(
      (b) =>
          b.bookName == bookmark.bookName &&
          b.chapter == bookmark.chapter &&
          b.verseNumber == bookmark.verseNumber,
    );
    if (alreadyExists) return;

    bookmarks.add(bookmark);
    await _persist(prefs, bookmarks);
  }

  static Future<void> removeBookmark({
    required String bookName,
    required int chapter,
    required int verseNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere(
      (b) =>
          b.bookName == bookName &&
          b.chapter == chapter &&
          b.verseNumber == verseNumber,
    );
    await _persist(prefs, bookmarks);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  static Future<void> _persist(
    SharedPreferences prefs,
    List<Bookmark> bookmarks,
  ) async {
    final encoded = bookmarks.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
