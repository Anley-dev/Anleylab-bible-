import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:amharic_catholic_bible/features/search/models/search_result.dart';

class SearchService {
  static const String _assetPath = 'assets/bible.json'; // JSON array of verses

  // Load all verses from asset (once)
  Future<List<SearchResult>> _loadAll() async {
    final String jsonString = await rootBundle.loadString(_assetPath);
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => SearchResult(
          book: e['book'] as String,
          chapter: e['chapter'] as int,
          verseNumber: e['verseNumber'] as int,
          text: e['text'] as String,
        )).toList();
  }

  // Simple case‑insensitive contains search
  Future<List<SearchResult>> search(String query) async {
    final all = await _loadAll();
    final lower = query.toLowerCase();
    return all.where((verse) => verse.text.toLowerCase().contains(lower)).toList();
  }
}
