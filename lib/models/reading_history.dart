class ReadingHistory {
  final String bookId;
  final String bookNameAmharic;
  final int chapter;
  final int verse;
  final DateTime lastRead;

  const ReadingHistory({
    required this.bookId,
    required this.bookNameAmharic,
    required this.chapter,
    required this.verse,
    required this.lastRead,
  });

  // Serialization helpers for local storage (SharedPreferences / Isar)
  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'bookNameAmharic': bookNameAmharic,
    'chapter': chapter,
    'verse': verse,
    'lastRead': lastRead.toIso8601String(),
  };

  factory ReadingHistory.fromJson(Map<String, dynamic> json) => ReadingHistory(
    bookId: json['bookId'] as String,
    bookNameAmharic: json['bookNameAmharic'] as String,
    chapter: json['chapter'] as int,
    verse: json['verse'] as int,
    lastRead: DateTime.parse(json['lastRead'] as String),
  );
}
