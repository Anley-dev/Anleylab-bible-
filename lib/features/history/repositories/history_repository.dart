import 'dart:convert';
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';

/// Simple repository for [HistoryEntry] objects, persisted to SharedPreferences.
class HistoryRepository {
  static final HistoryRepository _instance = HistoryRepository._internal();
  factory HistoryRepository() => _instance;

  final List<HistoryEntry> _entries = [];
  static const String _storageKey = 'recent_history';

  HistoryRepository._internal() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final String? data = StorageService.getString(_storageKey);
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _entries.clear();
        for (var item in jsonList) {
          _entries.add(HistoryEntry(
            book: item['book'],
            chapter: item['chapter'],
            scrollOffset: (item['scrollOffset'] as num).toDouble(),
            timestamp: DateTime.parse(item['timestamp']),
          ));
        }
      } catch (e) {
        // Handle error quietly
      }
    }
  }

  void _saveToStorage() {
    final List<Map<String, dynamic>> jsonList = _entries.map((e) => {
      'book': e.book,
      'chapter': e.chapter,
      'scrollOffset': e.scrollOffset,
      'timestamp': e.timestamp.toIso8601String(),
    }).toList();
    StorageService.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Returns an immutable list of all stored entries.
  List<HistoryEntry> getAll() => List.unmodifiable(_entries);

  /// Adds a new history entry.
  void add(HistoryEntry entry) {
    // Remove existing entry for the same chapter so it moves to top
    _entries.removeWhere((e) => e.book == entry.book && e.chapter == entry.chapter);
    _entries.add(entry);
    
    // Keep only last 10 entries
    if (_entries.length > 10) {
      _entries.removeAt(0);
    }
    _saveToStorage();
  }

  /// Clears all entries.
  void clear() {
    _entries.clear();
    StorageService.remove(_storageKey);
  }

  /// Alias for adding a history entry, used by UI
  void appendEntry(HistoryEntry entry) => add(entry);
}
