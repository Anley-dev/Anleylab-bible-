class HistoryEntry {
  final String bookId;
  final String bookNameAmharic;
  final int chapter;
  final int verse;
  final DateTime lastRead;

  // Backward compatibility fields
  final double scrollOffset;

  const HistoryEntry({
    required this.bookId,
    required this.bookNameAmharic,
    required this.chapter,
    required this.verse,
    required this.lastRead,
    this.scrollOffset = 0.0,
  });

  // Getters for legacy fields
  String get book => bookNameAmharic;
  DateTime get timestamp => lastRead;

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookNameAmharic': bookNameAmharic,
    'chapter': chapter,
    'verse': verse,
    'lastRead': lastRead.toIso8601String(),
    'scrollOffset': scrollOffset,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    bookId: json['bookId'] as String? ?? json['book'] as String? ?? '',
    bookNameAmharic: json['bookNameAmharic'] as String? ?? json['book'] as String? ?? '',
    chapter: json['chapter'] is String ? (int.tryParse(json['chapter'] as String) ?? 1) : (json['chapter'] as int? ?? 1),
    verse: json['verse'] as int? ?? 1,
    lastRead: json['lastRead'] != null ? DateTime.parse(json['lastRead'] as String) : (json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now()),
    scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0.0,
  );
}
