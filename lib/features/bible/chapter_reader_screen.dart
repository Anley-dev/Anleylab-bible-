import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/constants/app_colors.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';
import 'package:amharic_catholic_bible/features/bible/bible_controller.dart';
import 'package:amharic_catholic_bible/features/search/bible_search_screen.dart';

// Feature Layers
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/features/bookmarks/models/bookmark.dart';
import 'package:amharic_catholic_bible/features/bookmarks/repositories/bookmark_repository.dart';
import 'package:amharic_catholic_bible/features/highlights/models/highlight.dart';
import 'package:amharic_catholic_bible/features/highlights/repositories/highlight_repository.dart';

class ChapterReaderScreen extends StatefulWidget {
  final String bookName;
  final String chapterNumber;
  final double initialScrollOffset;

  const ChapterReaderScreen({
    super.key,
    required this.bookName,
    required this.chapterNumber,
    this.initialScrollOffset = 0.0,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  final BibleController _controller = BibleController();
  late Future<Map<String, String>> _chapterFuture;
  late ScrollController _scrollController;
  
  Map<String, String> _loadedHighlights = {};

  final HistoryRepository _historyRepository = HistoryRepository();
  final HighlightRepository _highlightRepository = HighlightRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  @override
  void initState() {
    super.initState();
    _chapterFuture = _controller.getChapter(widget.bookName, widget.chapterNumber);
    _scrollController = ScrollController(initialScrollOffset: widget.initialScrollOffset);
    
    // Simple, lightweight scroll listener that doesn't hammer disk on every single pixel
    _scrollController.addListener(_onScroll);

    globalSettings.addListener(_onSettingsChanged);
    _restoreScrollPosition();
    _refreshHighlights();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveProgress(); // Saves progress cleanly ONLY when leaving the page
    _scrollController.dispose();
    globalSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    // Left empty or simple to avoid scroll lag
  }

  void _saveProgress() {
    if (_scrollController.hasClients) {
      _historyRepository.appendEntry(
        HistoryEntry(
          book: widget.bookName,
          chapter: widget.chapterNumber,
          scrollOffset: _scrollController.offset,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _restoreScrollPosition() {
    if (widget.initialScrollOffset > 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(widget.initialScrollOffset);
        }
      });
    }
  }

  Future<void> _refreshHighlights() async {
    final highlights = await _highlightRepository.getHighlights();
    final Map<String, String> localMap = {};
    final int? currentChapter = int.tryParse(widget.chapterNumber);

    if (currentChapter != null) {
      for (var hl in highlights) {
        if (hl.book.trim() == widget.bookName.trim() && hl.chapter == currentChapter) {
          localMap[hl.verseNumber.toString()] = hl.colorHex;
        }
      }
    }

    if (mounted) {
      setState(() {
        _loadedHighlights = localMap;
      });
    }
  }

  void _showVerseMenu(int verseNum, String text) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text('ጥቅስ አስቀምጥ (Bookmark)'),
                onTap: () async {
                  Navigator.pop(context);
                  final int? currentChapter = int.tryParse(widget.chapterNumber);
                  if (currentChapter != null) {
                    await _bookmarkRepository.saveBookmark(
                      Bookmark(
                        bookName: widget.bookName,
                        chapter: currentChapter,
                        verseNumber: verseNum,
                        text: text,
                        dateSaved: DateTime.now().toLocal().toString().split('.')[0],
                      ),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ጥቅሱ ተቀምጧል!')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_color_fill_outlined),
                title: const Text('አምቅ ቀለም (Highlight Yellow)'),
                onTap: () async {
                  Navigator.pop(context);
                  final int? currentChapter = int.tryParse(widget.chapterNumber);
                  if (currentChapter != null) {
                    await _highlightRepository.saveHighlight(
                      Highlight(
                        book: widget.bookName,
                        chapter: currentChapter,
                        verseNumber: verseNum,
                        colorHex: '0xFFFFF59D', // Clean classic yellow
                      ),
                    );
                    await _refreshHighlights();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.clear_all_outlined, color: Colors.redAccent),
                title: const Text('ቀለም አስወግድ', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(context);
                  final int? currentChapter = int.tryParse(widget.chapterNumber);
                  if (currentChapter != null) {
                    await _highlightRepository.removeHighlight(
                      widget.bookName,
                      currentChapter,
                      verseNum,
                    );
                    await _refreshHighlights();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} ምዕራፍ ${widget.chapterNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibleSearchScreen()),
            ),
          )
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _chapterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ምዕራፉን መጫን አልተቻለም።'));
          }

          final verses = snapshot.data!;
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verseKey = verses.keys.elementAt(index);
              final verseText = verses[verseKey]!;
              final verseNum = int.tryParse(verseKey) ?? (index + 1);

              final String? hexString = _loadedHighlights[verseNum.toString()];
              Color? tileColor = hexString != null ? Color(int.parse(hexString)) : null;

              return GestureDetector(
                onLongPress: () => _showVerseMenu(verseNum, verseText),
                child: Container(
                  color: tileColor,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    '$verseKey. $verseText',
                    style: TextStyle(fontSize: globalSettings.fontSize),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}