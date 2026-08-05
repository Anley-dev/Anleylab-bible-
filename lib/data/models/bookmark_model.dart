import 'dart:convert';

/// Represents a saved Bible verse bookmark.
class Bookmark {
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String text;
  final String dateSaved;

  const Bookmark({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.text,
    required this.dateSaved,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() => {
        'bookName': bookName,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'text': text,
        'dateSaved': dateSaved,
      };

  factory Bookmark.fromMap(Map<String, dynamic> map) => Bookmark(
        bookName: map['bookName'] as String,
        chapter: map['chapter'] as int,
        verseNumber: map['verseNumber'] as int,
        text: map['text'] as String,
        dateSaved: map['dateSaved'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory Bookmark.fromJson(String source) =>
      Bookmark.fromMap(jsonDecode(source) as Map<String, dynamic>);

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  /// Returns a new [Bookmark] with updated fields, keeping the rest unchanged.
  Bookmark copyWith({
    String? bookName,
    int? chapter,
    int? verseNumber,
    String? text,
    String? dateSaved,
  }) =>
      Bookmark(
        bookName: bookName ?? this.bookName,
        chapter: chapter ?? this.chapter,
        verseNumber: verseNumber ?? this.verseNumber,
        text: text ?? this.text,
        dateSaved: dateSaved ?? this.dateSaved,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bookmark &&
          runtimeType == other.runtimeType &&
          bookName == other.bookName &&
          chapter == other.chapter &&
          verseNumber == other.verseNumber &&
          text == other.text &&
          dateSaved == other.dateSaved;

  @override
  int get hashCode => Object.hash(bookName, chapter, verseNumber, text, dateSaved);

  @override
  String toString() =>
      'Bookmark(bookName: $bookName, chapter: $chapter, '
      'verseNumber: $verseNumber, dateSaved: $dateSaved)';
}
