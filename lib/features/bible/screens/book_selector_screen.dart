import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';
import 'package:amharic_catholic_bible/features/bible/models/book_model.dart';
import 'package:amharic_catholic_bible/features/bible/screens/chapter_selector_screen.dart';

class BookSelectorScreen extends StatefulWidget {
  final void Function(BookModel)? onBookSelected;

  const BookSelectorScreen({
    super.key,
    this.onBookSelected,
  });

  @override
  State<BookSelectorScreen> createState() => _BookSelectorScreenState();
}

class _BookSelectorScreenState extends State<BookSelectorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<BookModel> _allBooks = const [
    // ብሉይ ኪዳን
    BookModel(id: 'gen', nameAmharic: 'ኦሪት ዘፍጥረት', nameEnglish: 'Genesis', totalChapters: 50, isOldTestament: true),
    BookModel(id: 'exo', nameAmharic: 'ኦሪት ዘፀአት', nameEnglish: 'Exodus', totalChapters: 40, isOldTestament: true),
    BookModel(id: 'lev', nameAmharic: 'ኦሪት ዘሌዋውያን', nameEnglish: 'Leviticus', totalChapters: 27, isOldTestament: true),
    BookModel(id: 'num', nameAmharic: 'ኦሪት ዘኍልቊ', nameEnglish: 'Numbers', totalChapters: 36, isOldTestament: true),
    BookModel(id: 'deu', nameAmharic: 'ኦሪት ዘዳግም', nameEnglish: 'Deuteronomy', totalChapters: 34, isOldTestament: true),
    BookModel(id: 'jos', nameAmharic: 'መጽሐፈ ኢያሱ', nameEnglish: 'Joshua', totalChapters: 24, isOldTestament: true),
    BookModel(id: 'jdg', nameAmharic: 'መጽሐፈ መሳፍንት', nameEnglish: 'Judges', totalChapters: 21, isOldTestament: true),
    BookModel(id: 'rut', nameAmharic: 'መጽሐፈ ሩት', nameEnglish: 'Ruth', totalChapters: 4, isOldTestament: true),
    BookModel(id: '1sa', nameAmharic: '1ኛ መጽሐፈ ሳሙኤል', nameEnglish: '1 Samuel', totalChapters: 31, isOldTestament: true),
    BookModel(id: '2sa', nameAmharic: '2ኛ መጽሐፈ ሳሙኤል', nameEnglish: '2 Samuel', totalChapters: 24, isOldTestament: true),
    BookModel(id: '1ki', nameAmharic: '1ኛ መጽሐፈ ነገሥት', nameEnglish: '1 Kings', totalChapters: 22, isOldTestament: true),
    BookModel(id: '2ki', nameAmharic: '2ኛ መጽሐፈ ነገሥት', nameEnglish: '2 Kings', totalChapters: 25, isOldTestament: true),
    BookModel(id: '1ch', nameAmharic: '1ኛ መጽሐፈ ዜና መዋዕል', nameEnglish: '1 Chronicles', totalChapters: 29, isOldTestament: true),
    BookModel(id: '2ch', nameAmharic: '2ኛ መጽሐፈ ዜና መዋዕል', nameEnglish: '2 Chronicles', totalChapters: 36, isOldTestament: true),
    BookModel(id: 'ezr', nameAmharic: 'መጽሐፈ ዕዝራ', nameEnglish: 'Ezra', totalChapters: 10, isOldTestament: true),
    BookModel(id: 'neh', nameAmharic: 'መጽሐፈ ነህምያ', nameEnglish: 'Nehemiah', totalChapters: 13, isOldTestament: true),
    BookModel(id: 'tob', nameAmharic: 'መጽ​ሐፈ ጦቢት', nameEnglish: 'Tobit', totalChapters: 14, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'jdt', nameAmharic: 'መጽሐፈ ዮዲት', nameEnglish: 'Judith', totalChapters: 16, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'est', nameAmharic: 'መጽሐፈ አስቴር', nameEnglish: 'Esther', totalChapters: 10, isOldTestament: true),
    BookModel(id: '1ma', nameAmharic: '1ኛ መጽሐፈ መቃብያን', nameEnglish: '1 Maccabees', totalChapters: 16, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: '2ma', nameAmharic: '2ኛ መጽሐፈ መቃብያን', nameEnglish: '2 Maccabees', totalChapters: 15, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'job', nameAmharic: 'መጽሐፈ ኢዮብ', nameEnglish: 'Job', totalChapters: 42, isOldTestament: true),
    BookModel(id: 'psa', nameAmharic: 'መዝሙረ ዳዊት', nameEnglish: 'Psalms', totalChapters: 150, isOldTestament: true),
    BookModel(id: 'pro', nameAmharic: 'መጽሐፈ ምሳሌ', nameEnglish: 'Proverbs', totalChapters: 31, isOldTestament: true),
    BookModel(id: 'ecc', nameAmharic: 'መጽሐፈ መክብብ', nameEnglish: 'Ecclesiastes', totalChapters: 12, isOldTestament: true),
    BookModel(id: 'sng', nameAmharic: 'መኃልየ መኃልይ', nameEnglish: 'Song of Songs', totalChapters: 8, isOldTestament: true),
    BookModel(id: 'wis', nameAmharic: 'መጽሐፈ ጥበብ', nameEnglish: 'Wisdom', totalChapters: 19, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'sir', nameAmharic: 'መጽሐፈ ሲራክ', nameEnglish: 'Sirach', totalChapters: 51, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'isa', nameAmharic: 'ትንቢተ ኢሳይያስ', nameEnglish: 'Isaiah', totalChapters: 66, isOldTestament: true),
    BookModel(id: 'jer', nameAmharic: 'ትንቢተ ኤርምያስ', nameEnglish: 'Jeremiah', totalChapters: 52, isOldTestament: true),
    BookModel(id: 'lam', nameAmharic: 'ሰቈቃወ ኤርምያስ', nameEnglish: 'Lamentations', totalChapters: 5, isOldTestament: true),
    BookModel(id: 'bar', nameAmharic: 'መጽሐፈ ባሮክ', nameEnglish: 'Baruch', totalChapters: 6, isOldTestament: true, isDeuterocanonical: true),
    BookModel(id: 'eze', nameAmharic: 'ትንቢተ ሕዝቅኤል', nameEnglish: 'Ezekiel', totalChapters: 48, isOldTestament: true),
    BookModel(id: 'dan', nameAmharic: 'ትንቢተ ዳንኤል', nameEnglish: 'Daniel', totalChapters: 12, isOldTestament: true),
    BookModel(id: 'hos', nameAmharic: 'ትንቢተ ሆሴዕ', nameEnglish: 'Hosea', totalChapters: 14, isOldTestament: true),
    BookModel(id: 'joe', nameAmharic: 'ትንቢተ ኢዩኤል', nameEnglish: 'Joel', totalChapters: 3, isOldTestament: true),
    BookModel(id: 'amo', nameAmharic: 'ትንቢተ አሞጽ', nameEnglish: 'Amos', totalChapters: 9, isOldTestament: true),
    BookModel(id: 'oba', nameAmharic: 'ትንቢተ አብድዩ', nameEnglish: 'Obadiah', totalChapters: 1, isOldTestament: true),
    BookModel(id: 'jon', nameAmharic: 'ትንቢተ ዮናስ', nameEnglish: 'Jonah', totalChapters: 4, isOldTestament: true),
    BookModel(id: 'mic', nameAmharic: 'ትንቢተ ሚክያስ', nameEnglish: 'Micah', totalChapters: 7, isOldTestament: true),
    BookModel(id: 'nah', nameAmharic: 'ትንቢተ ናሆም', nameEnglish: 'Nahum', totalChapters: 3, isOldTestament: true),
    BookModel(id: 'hab', nameAmharic: 'ትንቢተ ዕንባቆም', nameEnglish: 'Habakkuk', totalChapters: 3, isOldTestament: true),
    BookModel(id: 'zep', nameAmharic: 'ትንቢተ ሶፎንያስ', nameEnglish: 'Zephaniah', totalChapters: 3, isOldTestament: true),
    BookModel(id: 'hag', nameAmharic: 'ትንቢተ ሐጌ', nameEnglish: 'Haggai', totalChapters: 2, isOldTestament: true),
    BookModel(id: 'zec', nameAmharic: 'ትንቢተ ዘካርያስ', nameEnglish: 'Zechariah', totalChapters: 14, isOldTestament: true),
    BookModel(id: 'mal', nameAmharic: 'ትንቢተ ሚልክያስ', nameEnglish: 'Malachi', totalChapters: 4, isOldTestament: true),
    // ሐዲስ ኪዳን
    BookModel(id: 'mat', nameAmharic: 'የማቴዎስ ወንጌል', nameEnglish: 'Matthew', totalChapters: 28, isOldTestament: false),
    BookModel(id: 'mar', nameAmharic: 'የማርቆስ ወንጌል', nameEnglish: 'Mark', totalChapters: 16, isOldTestament: false),
    BookModel(id: 'luk', nameAmharic: 'የሉቃስ ወንጌል', nameEnglish: 'Luke', totalChapters: 24, isOldTestament: false),
    BookModel(id: 'joh', nameAmharic: 'የዮሐንስ ወንጌል', nameEnglish: 'John', totalChapters: 21, isOldTestament: false),
    BookModel(id: 'act', nameAmharic: 'የሐዋርያት ሥራ', nameEnglish: 'Acts', totalChapters: 28, isOldTestament: false),
    BookModel(id: 'rom', nameAmharic: 'ወደ ሮሜ ሰዎች', nameEnglish: 'Romans', totalChapters: 16, isOldTestament: false),
    BookModel(id: '1co', nameAmharic: '1ኛ ወደ ቆሮንቶስ ሰዎች', nameEnglish: '1 Corinthians', totalChapters: 16, isOldTestament: false),
    BookModel(id: '2co', nameAmharic: '2ኛ ወደ ቆሮንቶስ ሰዎች', nameEnglish: '2 Corinthians', totalChapters: 13, isOldTestament: false),
    BookModel(id: 'gal', nameAmharic: 'ወደ ገላትያ ሰዎች', nameEnglish: 'Galatians', totalChapters: 6, isOldTestament: false),
    BookModel(id: 'eph', nameAmharic: 'ወደ ኤፌሶን ሰዎች', nameEnglish: 'Ephesians', totalChapters: 6, isOldTestament: false),
    BookModel(id: 'php', nameAmharic: 'ወደ ፊልጵስዩስ ሰዎች', nameEnglish: 'Philippians', totalChapters: 4, isOldTestament: false),
    BookModel(id: 'col', nameAmharic: 'ወደ ቈላስይስ ሰዎች', nameEnglish: 'Colossians', totalChapters: 4, isOldTestament: false),
    BookModel(id: '1th', nameAmharic: '1ኛ ወደ ተሰሎንቄ ሰዎች', nameEnglish: '1 Thessalonians', totalChapters: 5, isOldTestament: false),
    BookModel(id: '2th', nameAmharic: '2ኛ ወደ ተሰሎንቄ ሰዎች', nameEnglish: '2 Thessalonians', totalChapters: 3, isOldTestament: false),
    BookModel(id: '1ti', nameAmharic: '1ኛ ወደ ጢሞቴዎስ', nameEnglish: '1 Timothy', totalChapters: 6, isOldTestament: false),
    BookModel(id: '2ti', nameAmharic: '2ኛ ወደ ጢሞቴዎስ', nameEnglish: '2 Timothy', totalChapters: 4, isOldTestament: false),
    BookModel(id: 'tit', nameAmharic: 'ወደ ቲቶ', nameEnglish: 'Titus', totalChapters: 3, isOldTestament: false),
    BookModel(id: 'phm', nameAmharic: 'ወደ ፊልሞና', nameEnglish: 'Philemon', totalChapters: 1, isOldTestament: false),
    BookModel(id: 'heb', nameAmharic: 'ወደ ዕብራውያን', nameEnglish: 'Hebrews', totalChapters: 13, isOldTestament: false),
    BookModel(id: 'jas', nameAmharic: 'የያዕቆብ መልእክት', nameEnglish: 'James', totalChapters: 5, isOldTestament: false),
    BookModel(id: '1pe', nameAmharic: '1ኛ የጴጥሮስ መልእክት', nameEnglish: '1 Peter', totalChapters: 5, isOldTestament: false),
    BookModel(id: '2pe', nameAmharic: '2ኛ የጴጥሮስ መልእክት', nameEnglish: '2 Peter', totalChapters: 3, isOldTestament: false),
    BookModel(id: '1jo', nameAmharic: '1ኛ የዮሐንስ መልእክት', nameEnglish: '1 John', totalChapters: 5, isOldTestament: false),
    BookModel(id: '2jo', nameAmharic: '2ኛ የዮሐንስ መልእክት', nameEnglish: '2 John', totalChapters: 1, isOldTestament: false),
    BookModel(id: '3jo', nameAmharic: '3ኛ የዮሐንስ መልእክት', nameEnglish: '3 John', totalChapters: 1, isOldTestament: false),
    BookModel(id: 'jd2', nameAmharic: 'የይሁዳ መልእክት', nameEnglish: 'Jude', totalChapters: 1, isOldTestament: false),
    BookModel(id: 'rev', nameAmharic: 'የዮሐንስ ራእይ', nameEnglish: 'Revelation', totalChapters: 22, isOldTestament: false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'መጻሕፍት',
          style: AppTypography.appTitle(context, isDark: isDark),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.liturgicalGold,
          labelColor: AppColors.liturgicalGold,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'ብሉይ ኪዳን'),
            Tab(text: 'ሐዲስ ኪዳን'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: AppTypography.bookTitle(context, isDark: isDark),
                decoration: InputDecoration(
                  hintText: 'መጽሐፍ ፈልግ...',
                  hintStyle: AppTypography.secondaryText(isDark: isDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.liturgicalBlue),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookList(isOldTestament: true, isDark: isDark),
                  _buildBookList(isOldTestament: false, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList({required bool isOldTestament, required bool isDark}) {
    final books = _allBooks.where((b) {
      final matchesTestament = b.isOldTestament == isOldTestament;
      final matchesSearch = _searchQuery.isEmpty ||
          b.nameAmharic.contains(_searchQuery) ||
          b.nameEnglish.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTestament && matchesSearch;
    }).toList();

    if (books.isEmpty) {
      return Center(
        child: Text(
          'ምንም መጽሐፍ አልተገኘም',
          style: AppTypography.secondaryText(isDark: isDark),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _buildBookTile(context, books[index], isDark),
    );
  }

  Widget _buildBookTile(BuildContext context, BookModel book, bool isDark) {
    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          if (widget.onBookSelected != null) {
            widget.onBookSelected!(book);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChapterSelectorScreen(book: book),
              ),
            );
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  book.nameAmharic,
                  style: AppTypography.bookTitle(context, isDark: isDark),
                ),
              ),
              if (book.isDeuterocanonical)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.liturgicalGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'ዲዩትሮካናዊ',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.liturgicalGold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${book.totalChapters} ምዕራፎች',
            style: AppTypography.secondaryText(isDark: isDark),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
