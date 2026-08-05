class Bookmark {
  final String bookName;
  final int chapter;
  final int verseNumber;
  final String text;
  final String dateSaved;

  Bookmark({
    required this.bookName,
    required this.chapter,
    required this.verseNumber,
    required this.text,
    required this.dateSaved,
  });

  String get id => '$bookName-$chapter-$verseNumber';

  Map<String, dynamic> toJson() => {
        'bookName': bookName,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'text': text,
        'dateSaved': dateSaved,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        bookName: json['bookName'],
        chapter: json['chapter'],
        verseNumber: json['verseNumber'],
        text: json['text'],
        dateSaved: json['dateSaved'] ?? '',
      );
}
