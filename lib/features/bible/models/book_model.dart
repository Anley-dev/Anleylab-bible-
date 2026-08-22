class BookModel {
  final String id;
  final String nameAmharic;
  final String nameEnglish;
  final int totalChapters;
  final bool isOldTestament;
  final bool isDeuterocanonical;

  const BookModel({
    required this.id,
    required this.nameAmharic,
    required this.nameEnglish,
    required this.totalChapters,
    required this.isOldTestament,
    this.isDeuterocanonical = false,
  });
}
