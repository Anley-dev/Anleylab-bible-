// lib/features/bible/bible_controller.dart
import 'package:amharic_catholic_bible/data/repositories/bible_repository.dart';

class BibleController {
  final _repo = BibleRepository();

  /// Fetches categorized book list for the BibleScreen
  Future<Map<String, List<String>>> getCategorizedBooks() async {
    final data = await _repo.getFullBible();
    final allBooks = _repo.getAllBookNames(data);
    
    // Using Amharic headers for user accessibility
    return {
      "ብሉይ ኪዳን": allBooks.sublist(0, 46), 
      "ሐዲስ ኪዳን": allBooks.sublist(46),
    };
  }

  /// Fetches specific chapter verses for the ChapterReaderScreen
  Future<Map<String, String>> getChapter(String bookName, String chapterNumber) async {
    final data = await _repo.getFullBible();
    final chapterData = Map<String, dynamic>.from(data[bookName][chapterNumber]);
    
    // Sort keys numerically to ensure verses are in perfect 1, 2, 3... sequence
    final sortedKeys = chapterData.keys.toList()..sort((a, b) {
      final intA = int.tryParse(a) ?? 0;
      final intB = int.tryParse(b) ?? 0;
      return intA.compareTo(intB);
    });

    final Map<String, String> sortedVerses = {};
    for (final key in sortedKeys) {
      sortedVerses[key] = chapterData[key].toString();
    }
    return sortedVerses;
  }

  /// Helper to check if a chapter exists (useful for Next/Previous navigation)
  Future<bool> hasChapter(String book, int chapter) async {
    final data = await _repo.getFullBible();
    return data[book] != null && data[book][chapter.toString()] != null;
  }

  // Returns a list of chapter numbers as strings
  Future<List<String>> getChapterList(String bookName) async {
    final data = await _repo.getFullBible();
    return (data[bookName] as Map<String, dynamic>).keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }
}