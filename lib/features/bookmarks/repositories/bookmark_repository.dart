import 'package:amharic_catholic_bible/features/bookmarks/models/bookmark.dart';

/// Simple in‑memory repository for [Bookmark] objects.
class BookmarkRepository {
  final List<Bookmark> _bookmarks = [];

  /// Returns an immutable list of all stored bookmarks.
  List<Bookmark> getAll() => List.unmodifiable(_bookmarks);

  /// Async version used by UI
  Future<List<Bookmark>> getBookmarks() async => getAll();

  /// Save a new bookmark
  Future<void> saveBookmark(Bookmark b) async => add(b);

  /// Delete a bookmark by its id
  Future<void> deleteBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
  }

  /// Adds a new bookmark.
  void add(Bookmark bookmark) => _bookmarks.add(bookmark);

  /// Removes a bookmark.
  void remove(Bookmark bookmark) => _bookmarks.remove(bookmark);

  /// Clears all bookmarks – useful for testing.
  void clear() => _bookmarks.clear();
}
