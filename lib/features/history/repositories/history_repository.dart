import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';

/// Simple in‑memory repository for [HistoryEntry] objects.
class HistoryRepository {
  final List<HistoryEntry> _entries = [];

  /// Returns an immutable list of all stored entries.
  List<HistoryEntry> getAll() => List.unmodifiable(_entries);

  /// Adds a new history entry.
  void add(HistoryEntry entry) => _entries.add(entry);

  /// Clears all entries – useful for testing.
  void clear() => _entries.clear();
  /// Alias for adding a history entry, used by UI
  void appendEntry(HistoryEntry entry) => add(entry);

}
