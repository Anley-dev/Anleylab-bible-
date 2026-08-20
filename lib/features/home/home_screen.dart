import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';
import 'package:amharic_catholic_bible/data/repositories/bible_repository.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';
import 'package:amharic_catholic_bible/features/bible/bible_screen.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/settings/settings_screen.dart';
import 'package:amharic_catholic_bible/features/main_navigation_controller.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryRepository _historyRepository = HistoryRepository();

  // Verse of the day — changes every calendar day
  Map<String, String>? _verseOfDay;

  @override
  void initState() {
    super.initState();
    _loadVerseOfDay();
  }

  /// Returns day-of-year (0-based) so the verse rotates every calendar day.
  int _getDayOfYear() {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays;
  }

  /// Picks a deterministic verse based on today's date from the full bible.
  Future<void> _loadVerseOfDay() async {
    try {
      final repo = BibleRepository();
      final data = await repo.getFullBible();
      final books = data.keys.toList();

      final day = _getDayOfYear();
      final bookName = books[day % books.length];
      final chapters = data[bookName] as Map<String, dynamic>;
      final chapterKeys = chapters.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      final chapterKey = chapterKeys[(day ~/ books.length) % chapterKeys.length];
      final verses = chapters[chapterKey] as Map<String, dynamic>;
      final verseKeys = verses.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      final verseKey = verseKeys[day % verseKeys.length];

      if (mounted) {
        setState(() {
          _verseOfDay = {
            'book': bookName,
            'chapter': chapterKey,
            'verse': verseKey,
            'text': verses[verseKey].toString(),
          };
        });
      }
    } catch (_) {
      // If loading fails, _verseOfDay remains null and a fallback is shown.
    }
  }

  @override
  Widget build(BuildContext context) {

    final entries = _historyRepository.getAll();
    final HistoryEntry? _latestEntry = entries.isNotEmpty ? entries.last : null;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 650;
    final bool isFirstLaunch = StorageService.getString('firstLaunchDone') != 'true';


    // Builds the verse-of-the-day card using the state loaded in initState.
    Widget _todayVerse = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        child: _verseOfDay == null
            // Loading state — show a slim progress bar until the verse is ready.
            ? const ListTile(
                title: Text('የዕለቱ ጥቅስ'),
                subtitle: LinearProgressIndicator(),
              )
            // Loaded state — show the verse and a navigation button.
            : ListTile(
                title: const Text('የዕለቱ ጥቅስ'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '"${_verseOfDay!['text']}"\n${_verseOfDay!['book']} ${_verseOfDay!['chapter']}:${_verseOfDay!['verse']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                trailing: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChapterReaderScreen(
                        bookName: _verseOfDay!['book']!,
                        chapterNumber: _verseOfDay!['chapter']!,
                      ),
                    ),
                  ),
                  child: const Text('ተጨማሪ ያንብቡ →'),
                ),
              ),
      ),
    );


    Widget _recentReading = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('የቅርብ ጊዜ ንባብ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._historyRepository.getAll().take(3).map((e) => ListTile(
                      title: Text(e.book),
                      subtitle: Text('ምዕራፍ ${e.chapter}'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterReaderScreen(bookName: e.book, chapterNumber: e.chapter, initialScrollOffset: e.scrollOffset))).then((_) => setState(() {})),
                    )),
              ],
            ),
          ),
        );

    // Notes preview widget removed (handled via Notes page)

    Widget _welcomeOverlay = isFirstLaunch
        ? Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('ወደ Catholic መጽሐፍ ቅዱስ እንኳን በደህና መጡ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    const Text('73 መጻሕፍት • ያለ በይነመረብ የሚነበብ • የካቶሊክ ቀኖና', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () {
                      StorageService.setString('firstLaunchDone', 'true');
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationController()));
                    }, child: const Text('ማንበብ ይጀምሩ')),
                  ]),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANLEYLAB BIBLE', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'ቅንብሮች',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(settings: globalSettings, onUpdate: () => setState(() {}))),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isTablet ? 650 : double.infinity),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('☀️ ሰላም!', style: TextStyle(fontSize: 16)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('አንሌይላብ መጽሐፍ ቅዱስ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('"ሕግህ ለእግሬ መብራት፥ ለመንገዴም ብርሃን ነው።"\nመዝሙረ ዳዊት 118:105', style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                    const Divider(thickness: 1, height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.play_arrow, color: Colors.blue, size: 36),
                          title: const Text('ማንበብ ይቀጥሉ'),
                          subtitle: _latestEntry != null
                              ? Text('${_latestEntry.book} ምዕራፍ ${_latestEntry.chapter}')
                              : const Text('ምንም የቅርብ ጊዜ ንባብ የለም'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (_latestEntry != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterReaderScreen(bookName: _latestEntry.book, chapterNumber: _latestEntry.chapter, initialScrollOffset: _latestEntry.scrollOffset))).then((_) => setState(() {}));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const BibleScreen())).then((_) => setState(() {}));
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _todayVerse,
                    const SizedBox(height: 16),
                    _recentReading,
                     const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          _welcomeOverlay,
        ],
      ),
    );
  }
}
