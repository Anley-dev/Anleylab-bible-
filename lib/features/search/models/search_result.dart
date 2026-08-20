class SearchResult {
  final String book;
  final int chapter;
  final int verseNumber;
  final String text;

  SearchResult({
    required this.book,
    required this.chapter,
    required this.verseNumber,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'text': text,
      };

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verseNumber: json['verseNumber'] as int,
        text: json['text'] as String,
      );
}
