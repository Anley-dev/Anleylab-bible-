class BibleChapter {
  final String bookName;
  final int chapterNumber;
  final Map<int, String> verses;

  BibleChapter({
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
  });

  factory BibleChapter.fromRawJson(Map<String, dynamic> fullBible, String book, String chapter) {
    final bookData = fullBible[book] as Map<String, dynamic>?;
    if (bookData == null) throw Exception("Book '$book' not found.");

    final chapterData = bookData[chapter] as Map<String, dynamic>?;
    if (chapterData == null) throw Exception("Chapter '$chapter' not found in $book.");

    final Map<int, String> parsedVerses = {};
    chapterData.forEach((verseNumStr, verseText) {
      final int? verseNum = int.tryParse(verseNumStr);
      if (verseNum != null) {
        parsedVerses[verseNum] = verseText.toString().trim();
      }
    });

    return BibleChapter(
      bookName: book,
      chapterNumber: int.parse(chapter),
      verses: parsedVerses,
    );
  }
}
