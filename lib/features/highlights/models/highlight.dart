class Highlight {
  final String book;
  final int chapter;
  final int verseNumber;
  final String colorHex;

  Highlight({
    required this.book,
    required this.chapter,
    required this.verseNumber,
    required this.colorHex,
  });

  String get verseId => verseNumber.toString();

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'colorHex': colorHex,
      };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
        book: json['book'],
        chapter: json['chapter'],
        verseNumber: json['verseNumber'],
        colorHex: json['colorHex'],
      );
}
