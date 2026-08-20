import 'dart:convert';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';

class BookmarkService {
  static const String _keyBookmarks = 'user_bookmarks_list';

  // Fetch all bookmarks
  Future<List<Map<String, String>>> getBookmarks() async {
    final String? jsonString = StorageService.getString(_keyBookmarks);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, String>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save a bookmark
  Future<void> saveBookmark(String book, String chapter, String verse, String text) async {
    final bookmarks = await getBookmarks();
    // Prevent duplicate entries
    bookmarks.removeWhere((item) =>
      item['book'] == book && item['chapter'] == chapter && item['verse'] == verse);
    bookmarks.insert(0, {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'date': DateTime.now().toIso8601String(),
    });
    await StorageService.setString(_keyBookmarks, jsonEncode(bookmarks));
  }

  // Remove a single bookmark
  Future<void> removeBookmark(String book, String chapter, String verse) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((item) =>
      item['book'] == book && item['chapter'] == chapter && item['verse'] == verse);
    await StorageService.setString(_keyBookmarks, jsonEncode(bookmarks));
  }
}
