import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/data/repositories/bible_repository.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';
class VerseSearchResult {
  final String bookName;
  final String chapter;
  final String verse;
  final String text;

  VerseSearchResult({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });
}

class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, List<VerseSearchResult>> _invertedIndex = {};
  final List<VerseSearchResult> _allVerses = [];
  final BibleRepository _repo = BibleRepository();
  
  List<VerseSearchResult> _searchResults = [];
  bool _isIndexing = true;
  String _searchExecutionTime = "";

  @override
  void initState() {
    super.initState();
    _loadAndIndexBible();
  }

  Future<void> _loadAndIndexBible() async {
    try {
      final Map<String, dynamic> rawBible = await _repo.getFullBible();
      _invertedIndex.clear(); 
      _allVerses.clear();

      rawBible.forEach((bookName, chapters) {
        if (chapters is Map) {
          chapters.forEach((chapterNum, verses) {
            if (verses is Map) {
              verses.forEach((verseNum, verseText) {
                String text = verseText.toString();

                final result = VerseSearchResult(
                  bookName: bookName,
                  chapter: chapterNum.toString(),
                  verse: verseNum.toString(),
                  text: text,
                );
                _allVerses.add(result);

                // Splits Amharic words correctly while ignoring punctuation marks
                List<String> words = text
                    .replaceAll(RegExp(r'[፣።፤፥፦፡]|[.,\/#!$%\^&\*;:{}=\-_`~()]'), ' ')
                    .split(RegExp(r'\s+'));

                for (var word in words) {
                  String cleanWord = word.trim();
                  if (cleanWord.isEmpty || cleanWord.length < 2) continue;

                  _invertedIndex.putIfAbsent(cleanWord, () => []);
                  _invertedIndex[cleanWord]!.add(result);
                }
              });
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Indexing Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isIndexing = false;
        });
      }
    }
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchExecutionTime = "";
      });
      return;
    }

    final stopwatch = Stopwatch()..start();
    String cleanQuery = query.trim();
    List<VerseSearchResult> localResults = [];
    final Set<String> uniqueCheck = {};

    // 1. Check for Reference Search (e.g. "2ተኛ ዜና 26፥5")
    bool isReferenceSearch = cleanQuery.contains(RegExp(r'\d')) || cleanQuery.contains(':') || cleanQuery.contains('፥');
    if (isReferenceSearch) {
      String normalizedQuery = cleanQuery.replaceAll('፥', ':').replaceAll('ተኛ', 'ኛ');
      List<String> queryParts = normalizedQuery.split(RegExp(r'\s+'));

      for (var result in _allVerses) {
        String ref = "${result.bookName} ${result.chapter}:${result.verse}";
        bool matchesRef = true;
        for (var part in queryParts) {
          if (!ref.contains(part)) {
            matchesRef = false;
            break;
          }
        }
        if (matchesRef) {
          final uniqueId = "${result.bookName}_${result.chapter}_${result.verse}";
          if (!uniqueCheck.contains(uniqueId)) {
            uniqueCheck.add(uniqueId);
            localResults.add(result);
          }
        }
      }
    }

    // 2. Text Search
    if (_invertedIndex.containsKey(cleanQuery)) {
      for (var result in _invertedIndex[cleanQuery]!) {
        final uniqueId = "${result.bookName}_${result.chapter}_${result.verse}";
        if (!uniqueCheck.contains(uniqueId)) {
          uniqueCheck.add(uniqueId);
          localResults.add(result);
        }
      }
    } else {
      final matchingKeys = _invertedIndex.keys.where((key) => key.contains(cleanQuery));
      for (var key in matchingKeys) {
        for (var result in _invertedIndex[key]!) {
          final uniqueId = "${result.bookName}_${result.chapter}_${result.verse}";
          if (!uniqueCheck.contains(uniqueId)) {
            uniqueCheck.add(uniqueId);
            localResults.add(result);
          }
        }
      }
    }

    stopwatch.stop();

    setState(() {
      _searchResults = localResults;
      _searchExecutionTime = "${stopwatch.elapsedMilliseconds} ms";
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    Widget mainContent = _isIndexing
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blueAccent),
                SizedBox(height: 16),
                Text("የፍለጋ ማውጫ በመዘጋጀት ላይ ነው... እባክዎ ይጠብቁ", style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : Column(
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _executeSearch,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: "ቃላትን ወይም ጥቅሶችን እዚህ ይፈልጉ...",
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              
              if (_searchExecutionTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "በ ${_searchExecutionTime} ውስጥ ${_searchResults.length} ውጤቶች ተገኝተዋል",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),

              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty ? "የሚፈልጉትን ቃል ያስገቡ" : "ምንም ተዛማጅ ጥቅስ አልተገኘም",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                "${result.bookName} ${result.chapter}:${result.verse}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  result.text,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              // Navigation handler for item tap
                              onTap: () {
                                final bool canPop = Navigator.canPop(context);
                                
                                if (canPop) {
                                  // If opened from inside ChapterReaderScreen, pass back the result
                                  Navigator.pop(context, result);
                                } else {
                                  // If clicked directly from your Home navigation bar tab view shell
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChapterReaderScreen(
                                        bookName: result.bookName,
                                        chapterNumber: result.chapter,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
          if (canPop) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("ቅዱስ ቃሉን ፈልግ"),
          centerTitle: true,
        ),
        body: mainContent,
      );
    }

    return Scaffold(
      body: SafeArea(child: mainContent),
    );
  }
} 