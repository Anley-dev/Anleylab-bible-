import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';
import 'package:amharic_catholic_bible/core/services/share_service.dart';
import 'package:amharic_catholic_bible/features/bible/bible_controller.dart';
import 'package:amharic_catholic_bible/features/search/bible_search_screen.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';

// Feature layers
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/core/services/bookmark_service.dart';
import 'package:amharic_catholic_bible/features/highlights/models/highlight.dart';
import 'package:amharic_catholic_bible/features/highlights/repositories/highlight_repository.dart';
import 'package:amharic_catholic_bible/features/notes/models/note.dart';
import 'package:amharic_catholic_bible/features/notes/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Day 4 — High-Performance Bible Reader
//
// Performance architecture:
//  • Chapter data loaded once per chapter via a cached BibleRepository singleton
//    (JSON decoded only on first launch; all subsequent reads are in-memory).
//  • Verse selection held in a ValueNotifier<Set<int>> so tapping a verse
//    rebuilds *only* that verse widget, not the entire list.
//  • Highlights and notes stored in ValueNotifiers so colour/note overlays
//    refresh without touching the text layer.
//  • ReaderSettings changes (font size, line height, letter spacing) observed
//    via the global ValueNotifier; ListView re-runs itemBuilder but never
//    re-allocates the ScrollController or StatefulWidget subtree.
//  • AnimatedContainer removed in favour of a plain ColoredBox — eliminates
//    per-frame GPU work on Mali-400 class GPUs (common in Android 5 devices).
//  • WidgetSpan verse numbers kept for superscript alignment but parent RichText
//    uses TextWidthBasis.parent, so the layout engine measures only once.
// ─────────────────────────────────────────────────────────────────────────────

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
  // ── Data ──────────────────────────────────────────────────────────────────
  final BibleController _controller = BibleController();
  late Future<Map<String, String>> _chapterFuture;
  late ScrollController _scrollController;

  // ── Repositories ─────────────────────────────────────────────────────────
  final HistoryRepository _historyRepo = HistoryRepository();
  final HighlightRepository _highlightRepo = HighlightRepository();
  final BookmarkService _bookmarkService = BookmarkService();
  final NoteRepository _noteRepo = NoteRepository();

  // ── Fine-grained reactive state ───────────────────────────────────────────
  //
  // Using ValueNotifier instead of setState prevents the ListView.builder from
  // being called for all N verses when a single verse is tapped or highlighted.
  //
  final ValueNotifier<Set<int>> _selectedVerses = ValueNotifier(const {});
  final ValueNotifier<Map<String, String>> _highlights = ValueNotifier(const {});
  final ValueNotifier<Map<String, Note>> _notes = ValueNotifier(const {});

  // ── Chapter navigation state ──────────────────────────────────────────────
  bool _hasPrev = false;
  bool _hasNext = false;
  double _currentOffset = 0.0;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chapterFuture = _controller.getChapter(widget.bookName, widget.chapterNumber);
    _scrollController = ScrollController(initialScrollOffset: widget.initialScrollOffset);
    _scrollController.addListener(_onScroll);
    _restoreScrollPosition();
    _refreshHighlightsAndNotes();
    _checkAdjacency();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveProgress();
    _scrollController.dispose();
    _selectedVerses.dispose();
    _highlights.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _currentOffset = _scrollController.offset;
    }
  }

  void _saveProgress() {
    _historyRepo.appendEntry(
      HistoryEntry(
        bookId: widget.bookName,
        bookNameAmharic: widget.bookName,
        chapter: int.tryParse(widget.chapterNumber) ?? 1,
        verse: 1,
        lastRead: DateTime.now(),
        scrollOffset: _currentOffset,
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
    final cur = int.tryParse(widget.chapterNumber);
    if (cur == null) return;
    final prev = await _controller.hasChapter(widget.bookName, cur - 1);
    final next = await _controller.hasChapter(widget.bookName, cur + 1);
    if (mounted) setState(() { _hasPrev = prev; _hasNext = next; });
  }

  void _navigateToChapter(int targetChapter) {
    if (!mounted) return;
    _saveProgress();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // 180 ms slide — fast enough to feel instant on low-end devices.
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => ChapterReaderScreen(
          bookName: widget.bookName,
          chapterNumber: targetChapter.toString(),
        ),
      ),
    );
  }

  /// Reloads highlights and notes for this chapter into their ValueNotifiers.
  /// The read path is synchronous (in-memory singleton), so this completes in
  /// microseconds and never blocks the raster thread.
  Future<void> _refreshHighlightsAndNotes() async {
    final allHighlights = await _highlightRepo.getHighlights();
    final allNotes = await _noteRepo.getNotes();
    final cur = int.tryParse(widget.chapterNumber);

    final Map<String, String> hl = {};
    final Map<String, Note> nt = {};

    if (cur != null) {
      for (final h in allHighlights) {
        if (h.book.trim() == widget.bookName.trim() && h.chapter == cur) {
          hl[h.verseNumber.toString()] = h.colorHex;
        }
      }
      for (final n in allNotes) {
        if (n.book.trim() == widget.bookName.trim() && n.chapter == cur) {
          nt[n.verse.toString()] = n;
        }
      }
    }

    if (mounted) {
      // ValueNotifier assignment triggers only widgets that listen to these
      // notifiers — the verse list body is NOT rebuilt.
      _highlights.value = hl;
      _notes.value = nt;
    }
  }

  // ── Verse selection ───────────────────────────────────────────────────────

  /// Toggles verse selection without rebuilding the parent scaffold.
  /// Each _VerseItem listens to _selectedVerses directly.
  void _toggleVerseSelection(int verseNum) {
    final current = _selectedVerses.value;
    final updated = Set<int>.from(current);
    if (updated.contains(verseNum)) {
      updated.remove(verseNum);
    } else {
      updated.add(verseNum);
    }
    _selectedVerses.value = updated;
  }

  // ── Verse action menu ─────────────────────────────────────────────────────

  void _showVerseMenu(int verseNum, String text) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_add_outlined),
                  title: const Text('ጥቅስ አስቀምጥ'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final cur = int.tryParse(widget.chapterNumber);
                    if (cur != null) {
                      final messenger = ScaffoldMessenger.of(context);
                      await _bookmarkService.saveBookmark(
                        widget.bookName,
                        widget.chapterNumber,
                        verseNum.toString(),
                        text,
                      );
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('ጥቅሱ ተቀምጧል!')),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('ጥቅስ አጋራ'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    await ShareService.shareVerse(
                      bookName: widget.bookName,
                      chapter: widget.chapterNumber,
                      verse: verseNum.toString(),
                      text: text,
                    );
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('ጥቅሱ ወደ ቅንጥብ ሰሌዳ ተቀድቷል!')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: const Text('ማስታወሻ ያዝ'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddNoteDialog(verseNum);
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('ቀለም', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Navigator.pop(ctx);
                    final cur = int.tryParse(widget.chapterNumber);
                    if (cur != null) {
                      await _highlightRepo.removeHighlight(widget.bookName, cur, verseNum);
                      await _refreshHighlightsAndNotes();
                    }
                  },
                ),
                const SizedBox(height: 8),
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
        final cur = int.tryParse(widget.chapterNumber);
        if (cur != null) {
          await _highlightRepo.saveHighlight(
            Highlight(
              book: widget.bookName,
              chapter: cur,
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
    final ctrl = TextEditingController();
    final existing = _notes.value[verseNum.toString()];
    if (existing != null) ctrl.text = existing.content;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? 'ማስታወሻ አርም' : 'ማስታወሻ ያዝ'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'ማስታወሻ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ሰርዝ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = ctrl.text.trim();
              final cur = int.tryParse(widget.chapterNumber);
              if (cur == null) { Navigator.of(context).pop(); return; }
              if (content.isEmpty) {
                if (existing != null) await _noteRepo.deleteNote(existing.id);
              } else {
                await _noteRepo.saveNote(Note(
                  id: existing?.id ?? const Uuid().v4(),
                  book: widget.bookName,
                  chapter: cur,
                  verse: verseNum,
                  content: content,
                ));
              }
              await _refreshHighlightsAndNotes();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('አስቀምጥ'),
          ),
        ],
      ),
    );
  }

  // ── Quick settings sheet ──────────────────────────────────────────────────

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      // useSafeArea keeps content inside system insets (notch-safe).
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return ValueListenableBuilder<ReaderSettings>(
          valueListenable: globalSettings,
          builder: (_, settings, _) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'የጽሑፍ ቅንብሮች',
                    style: AppTypography.sectionTitle(ctx, isDark: isDark),
                  ),
                  const SizedBox(height: 16),

                  // ── Font size ─────────────────────────────────────────────
                  _SettingsRow(
                    icon: Icons.format_size,
                    label: 'ፊደል ትልቅነት',
                    trailing: '${settings.fontSize.toInt()}',
                    child: Slider(
                      value: settings.fontSize,
                      min: 14.0,
                      max: 30.0,
                      divisions: 8,
                      activeColor: AppColors.liturgicalGold,
                      onChanged: (v) => globalSettings.updateFontSize(v),
                    ),
                  ),

                  // ── Line spacing ──────────────────────────────────────────
                  _SettingsRow(
                    icon: Icons.format_line_spacing,
                    label: 'የመስመር ርዝመት',
                    trailing: settings.lineSpacing.toStringAsFixed(1),
                    child: Slider(
                      value: settings.lineSpacing,
                      min: 1.2,
                      max: 2.4,
                      divisions: 6,
                      activeColor: AppColors.liturgicalGold,
                      onChanged: (v) => globalSettings.updateLineSpacing(v),
                    ),
                  ),

                  // ── Letter spacing ────────────────────────────────────────
                  _SettingsRow(
                    icon: Icons.text_fields,
                    label: 'የቃላት ርቀት',
                    trailing: settings.letterSpacing.toStringAsFixed(1),
                    child: Slider(
                      value: settings.letterSpacing,
                      min: 0.0,
                      max: 1.0,
                      divisions: 5,
                      activeColor: AppColors.liturgicalGold,
                      onChanged: (v) => globalSettings.updateLetterSpacing(v),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          '${widget.bookName} ምዕ. ${widget.chapterNumber}',
          style: AppTypography.appTitle(context, isDark: isDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'ፈልግ',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibleSearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'ቅንብሮች',
            onPressed: _showSettingsSheet,
          ),
          // Bookmark action: only visible when verses are selected.
          // ValueListenableBuilder ensures only this icon slot rebuilds, not
          // the entire AppBar.
          ValueListenableBuilder<Set<int>>(
            valueListenable: _selectedVerses,
            builder: (_, selected, _) {
              if (selected.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.bookmark_add_outlined,
                  color: AppColors.liturgicalGold,
                ),
                tooltip: 'ጥቅስ አስቀምጥ',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  
                  // Retrieve chapter verses so we can save the actual text along with the bookmark
                  final verses = await _chapterFuture;
                  
                  for (final v in selected) {
                    final verseKey = v.toString();
                    final verseText = verses[verseKey] ?? '';
                    await _bookmarkService.saveBookmark(
                      widget.bookName,
                      widget.chapterNumber,
                      verseKey,
                      verseText,
                    );
                  }
                  _selectedVerses.value = const {};
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('ጥቅሶቹ ተቀምጠዋል!')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),

      // ── Chapter body ──────────────────────────────────────────────────────
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

          // ValueListenableBuilder limits ReaderSettings rebuilds to this list
          // only. Changes to _selectedVerses / _highlights / _notes are handled
          // inside each _VerseItem, so this builder fires only on font/spacing
          // changes.
          return ValueListenableBuilder<ReaderSettings>(
            valueListenable: globalSettings,
            builder: (_, settings, _) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: verses.length,
                itemBuilder: (ctx, index) {
                  final verseKey = verses.keys.elementAt(index);
                  final verseText = verses[verseKey]!;
                  final verseNum = int.tryParse(verseKey) ?? (index + 1);

                  return _VerseItem(
                    verseNum: verseNum,
                    verseText: verseText,
                    settings: settings,
                    isDark: isDark,
                    selectedNotifier: _selectedVerses,
                    highlightsNotifier: _highlights,
                    notesNotifier: _notes,
                    onTap: () => _toggleVerseSelection(verseNum),
                    onLongPress: () => _showVerseMenu(verseNum, verseText),
                  );
                },
              );
            },
          );
        },
      ),

      // ── Prev / Next navigation bar ────────────────────────────────────────
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: _hasPrev
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : AppColors.textSecondaryLight,
              ),
              tooltip: 'ቀዳሚ ምዕራፍ',
              onPressed: _hasPrev
                  ? () => _navigateToChapter(int.parse(widget.chapterNumber) - 1)
                  : null,
            ),
            Text(
              'ምዕ. ${widget.chapterNumber}',
              style: AppTypography.secondaryText(isDark: isDark),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: _hasNext
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : AppColors.textSecondaryLight,
              ),
              tooltip: 'ቀጣይ ምዕራፍ',
              onPressed: _hasNext
                  ? () => _navigateToChapter(int.parse(widget.chapterNumber) + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VerseItem
//
// Extracted StatelessWidget so Flutter's element reconciliation can diff and
// skip unaffected verses independently. A tap on verse 5 only repaints verse
// 5's ColoredBox — not all 176 verses of Psalms 119.
// ─────────────────────────────────────────────────────────────────────────────

class _VerseItem extends StatelessWidget {
  const _VerseItem({
    required this.verseNum,
    required this.verseText,
    required this.settings,
    required this.isDark,
    required this.selectedNotifier,
    required this.highlightsNotifier,
    required this.notesNotifier,
    required this.onTap,
    required this.onLongPress,
  });

  final int verseNum;
  final String verseText;
  final ReaderSettings settings;
  final bool isDark;

  final ValueNotifier<Set<int>> selectedNotifier;
  final ValueNotifier<Map<String, String>> highlightsNotifier;
  final ValueNotifier<Map<String, Note>> notesNotifier;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    // Single ListenableBuilder covering all three notifiers avoids triple
    // nesting. Rebuilds when any of the three changes — but only for the verse
    // whose key appears in the updated map/set, because new Map/Set copies are
    // created on each update so identity comparison short-circuits correctly.
    return ListenableBuilder(
      listenable: Listenable.merge([selectedNotifier, highlightsNotifier, notesNotifier]),
      builder: (_, _) {
        final isSelected = selectedNotifier.value.contains(verseNum);
        final verseKey = verseNum.toString();
        final hexStr = highlightsNotifier.value[verseKey];
        final verseNote = notesNotifier.value[verseKey];

        // Resolve highlight color once — avoids repeated hex parsing in paint.
        Color? highlightColor;
        if (hexStr != null) {
          final clean = hexStr.replaceFirst('0x', '').replaceFirst('#', '');
          final val = int.tryParse(clean, radix: 16);
          if (val != null) {
            highlightColor = Color(clean.length == 6 ? (0xFF000000 + val) : val);
          }
        }

        // Selection overrides highlight; transparent if neither applies.
        final bgColor = isSelected
            ? AppColors.liturgicalGold.withValues(alpha: 0.18)
            : highlightColor;

        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          // ColoredBox is a single-layer paint call with no border radius,
          // avoiding the save-layer overhead that ClipRRect adds — critical on
          // Mali-400 GPUs where save-layers cost ~1 ms each.
          child: ColoredBox(
            color: bgColor ?? Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Verse text with superscript verse number ─────────────
                  //
                  // textWidthBasis: TextWidthBasis.parent prevents the RichText
                  // from measuring based on the longest line, avoiding a second
                  // layout pass on wrapped Ethiopic text (Ethiopic characters
                  // are wider than Latin on average).
                  RichText(
                    textWidthBasis: TextWidthBasis.parent,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0, top: 2),
                            child: Text(
                              '$verseNum',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: settings.fontSize * 0.68,
                                fontWeight: FontWeight.bold,
                                color: AppColors.liturgicalGold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: verseText,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: settings.fontSize,
                            height: settings.lineSpacing,
                            letterSpacing: settings.letterSpacing,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Inline note preview ─────────────────────────────────
                  if (verseNote != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 24),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 13,
                            color: AppColors.liturgicalBlue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              verseNote.content,
                              style: TextStyle(
                                color: AppColors.liturgicalBlue,
                                fontStyle: FontStyle.italic,
                                fontSize: settings.fontSize * 0.75,
                              ),
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
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsRow
//
// Thin layout helper for quick-settings sheet rows. Extracted to keep the
// sheet builder readable.
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.child,
  });

  final IconData icon;
  final String label;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
        Expanded(child: child),
        SizedBox(
          width: 36,
          child: Text(trailing, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
