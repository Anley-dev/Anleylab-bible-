class Note {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String content;
  final DateTime timestamp;

  Note({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
