import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';
import 'package:amharic_catholic_bible/core/services/share_service.dart';
import 'package:amharic_catholic_bible/features/bible/bible_controller.dart';
import 'package:amharic_catholic_bible/features/search/bible_search_screen.dart';

// Feature Layers
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/core/services/bookmark_service.dart';
import 'package:amharic_catholic_bible/features/highlights/models/highlight.dart';
import 'package:amharic_catholic_bible/features/highlights/repositories/highlight_repository.dart';
import 'package:amharic_catholic_bible/features/notes/models/note.dart';
import 'package:amharic_catholic_bible/features/notes/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';


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
  Map<String, Note> _loadedNotes = {};

  final HistoryRepository _historyRepository = HistoryRepository();
  final HighlightRepository _highlightRepository = HighlightRepository();
  final BookmarkService _bookmarkService = BookmarkService();
  final NoteRepository _noteRepository = NoteRepository();
  bool _hasPrev = false;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _chapterFuture = _controller.getChapter(widget.bookName, widget.chapterNumber);
    _scrollController = ScrollController(initialScrollOffset: widget.initialScrollOffset);
    
    _scrollController.addListener(_onScroll);

    globalSettings.addListener(_onSettingsChanged);
    _restoreScrollPosition();
    _refreshHighlightsAndNotes();
    _checkAdjacency();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveProgress(); 
    _scrollController.dispose();
    globalSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  double _currentOffset = 0.0;

  void _onScroll() {
    if (_scrollController.hasClients) {
      _currentOffset = _scrollController.offset;
    }
  }

  void _saveProgress() {
    _historyRepository.appendEntry(
      HistoryEntry(
        book: widget.bookName,
        chapter: widget.chapterNumber,
        scrollOffset: _currentOffset,
        timestamp: DateTime.now(),
      ),
    );
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

  Future<void> _checkAdjacency() async {
    final int? cur = int.tryParse(widget.chapterNumber);
    if (cur == null) return;
    final hasPrev = await _controller.hasChapter(widget.bookName, cur - 1);
    final hasNext = await _controller.hasChapter(widget.bookName, cur + 1);
    if (mounted) {
      setState(() {
        _hasPrev = hasPrev;
        _hasNext = hasNext;
      });
    }
  }

  void _navigateToChapter(int targetChapter, double offset) {
    if (!mounted) return;
    // Save current progress before leaving
    _saveProgress();
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => ChapterReaderScreen(
        bookName: widget.bookName,
        chapterNumber: targetChapter.toString(),
        initialScrollOffset: offset,
      ),
    ));
  }

  Future<void> _refreshHighlightsAndNotes() async {
    final highlights = await _highlightRepository.getHighlights();
    final notes = await _noteRepository.getNotes();
    
    final Map<String, String> localHighlights = {};
    final Map<String, Note> localNotes = {};
    final int? currentChapter = int.tryParse(widget.chapterNumber);

    if (currentChapter != null) {
      for (var hl in highlights) {
        if (hl.book.trim() == widget.bookName.trim() && hl.chapter == currentChapter) {
          localHighlights[hl.verseNumber.toString()] = hl.colorHex;
        }
      }
      for (var n in notes) {
        if (n.book.trim() == widget.bookName.trim() && n.chapter == currentChapter) {
          localNotes[n.verse.toString()] = n;
        }
      }
    }

    if (mounted) {
      setState(() {
        _loadedHighlights = localHighlights;
        _loadedNotes = localNotes;
      });
    }
  }

  void _showVerseMenu(int verseNum, String text) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.bookmark_add_outlined),
                    title: const Text('ጥቅስ አስቀምጥ (Bookmark)'),
                    onTap: () async {
                      Navigator.pop(context);
                      final int? currentChapter = int.tryParse(widget.chapterNumber);
                      if (currentChapter != null) {
                        await _bookmarkService.saveBookmark(
                          widget.bookName,
                          widget.chapterNumber,
                          verseNum.toString(),
                          text,
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
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('ጥቅስ አጋራ (Share / Copy)'),
                  onTap: () async {
                    Navigator.pop(context);
                    await ShareService.shareVerse(
                      bookName: widget.bookName,
                      chapter: widget.chapterNumber,
                      verse: verseNum.toString(),
                      text: text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ጥቅሱ ወደ ቅንጥብ ሰሌዳ ተቀድቷል!')),
                      );
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('ማስታወሻ ያዝ (Add Note)'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddNoteDialog(verseNum);
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('ቀለም (Highlight)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorButton(verseNum, '0xFFFFF59D', Colors.yellow.shade200),
                    _buildColorButton(verseNum, '0xFFA5D6A7', Colors.green.shade200),
                    _buildColorButton(verseNum, '0xFF90CAF9', Colors.blue.shade200),
                    _buildColorButton(verseNum, '0xFFF48FB1', Colors.pink.shade200),
                    _buildColorButton(verseNum, '0xFFCE93D8', Colors.purple.shade200),
                  ],
                ),
                const SizedBox(height: 8),
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
                      await _refreshHighlightsAndNotes();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorButton(int verseNum, String hexString, Color color) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final int? currentChapter = int.tryParse(widget.chapterNumber);
        if (currentChapter != null) {
          await _highlightRepository.saveHighlight(
            Highlight(
              book: widget.bookName,
              chapter: currentChapter,
              verseNumber: verseNum,
              colorHex: hexString,
            ),
          );
          await _refreshHighlightsAndNotes();
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  Future<void> _showAddNoteDialog(int verseNum) async {
    final TextEditingController contentCtrl = TextEditingController();
    // Pre-fill if note already exists
    final existingNote = _loadedNotes[verseNum.toString()];
    if (existingNote != null) {
      contentCtrl.text = existingNote.content;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingNote != null ? 'ማስታወሻ አርም (Edit Note)' : 'ማስታወሻ ያዝ (Add Note)'),
        content: TextField(
          controller: contentCtrl,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'ማስታወሻ (Note Content)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ሰርዝ (Cancel)')),
          ElevatedButton(
            onPressed: () async {
              final String content = contentCtrl.text.trim();
              final int? currentChapter = int.tryParse(widget.chapterNumber);
              if (content.isEmpty || currentChapter == null) {
                if (existingNote != null && content.isEmpty) {
                  // Delete note if content is cleared
                  await _noteRepository.deleteNote(existingNote.id);
                  await _refreshHighlightsAndNotes();
                }
                if (mounted) Navigator.of(context).pop();
                return;
              }
              final newNote = Note(
                id: existingNote?.id ?? Uuid().v4(),
                book: widget.bookName,
                chapter: currentChapter,
                verse: verseNum,
                content: content,
              );
              await _noteRepository.saveNote(newNote);
              await _refreshHighlightsAndNotes();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('አስቀምጥ (Save)'),
          ),
        ],
      ),
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
          ),
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
              final Note? verseNote = _loadedNotes[verseNum.toString()];

              return GestureDetector(
                onLongPress: () => _showVerseMenu(verseNum, verseText),
                child: Container(
                  color: tileColor,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$verseKey. $verseText',
                        style: TextStyle(fontSize: globalSettings.fontSize),
                      ),
                      if (verseNote != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.note, size: 16, color: Colors.blueAccent),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  verseNote.content,
                                  style: const TextStyle(color: Colors.blueAccent, fontStyle: FontStyle.italic, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Tooltip(
                message: 'Previous Chapter',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 30,
                  color: _hasPrev ? null : Colors.grey,
                  onPressed: _hasPrev
                      ? () => _navigateToChapter(int.parse(widget.chapterNumber) - 1, _scrollController.offset)
                      : null,
                ),
              ),
              Tooltip(
                message: 'Next Chapter',
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 30,
                  color: _hasNext ? null : Colors.grey,
                  onPressed: _hasNext
                      ? () => _navigateToChapter(int.parse(widget.chapterNumber) + 1, _scrollController.offset)
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
  }
}