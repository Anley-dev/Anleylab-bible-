class ContinueEntry {
  final String book;
  final int chapter;
  final int verse;
  final DateTime timestamp;

  ContinueEntry({
    required this.book,
    required this.chapter,
    required this.verse,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ContinueEntry.fromJson(Map<String, dynamic> json) => ContinueEntry(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
