class HistoryEntry {
  final String book;
  final String chapter;
  final double scrollOffset;
  final DateTime timestamp;

  HistoryEntry({
    required this.book,
    required this.chapter,
    required this.scrollOffset,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'scrollOffset': scrollOffset,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        book: json['book'],
        chapter: json['chapter'],
        scrollOffset: (json['scrollOffset'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}
