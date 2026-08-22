import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/features/bible/models/book_model.dart';
import 'package:amharic_catholic_bible/features/bible/screens/book_selector_screen.dart';
import 'package:amharic_catholic_bible/features/bible/screens/chapter_selector_screen.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';
import 'package:amharic_catholic_bible/widgets/adaptive_layout.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';

class BibleSplitView extends StatefulWidget {
  const BibleSplitView({super.key});

  @override
  State<BibleSplitView> createState() => _BibleSplitViewState();
}

class _BibleSplitViewState extends State<BibleSplitView> {
  BookModel? _selectedBook;
  String? _selectedChapter;
  double _scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 600;

        if (isWideScreen) {
          return AdaptiveBibleLayout(
            masterPane: _buildMasterPane(context),
            detailPane: _buildDetailPane(context),
          );
        }

        // Standard mobile flow: BookSelectorScreen manages its own navigation
        return const BookSelectorScreen();
      },
    );
  }

  Widget _buildMasterPane(BuildContext context) {
    if (_selectedBook == null) {
      return BookSelectorScreen(
        key: const PageStorageKey('book_selector_wide'),
        onBookSelected: (book) {
          setState(() {
            _selectedBook = book;
            _selectedChapter = null;
            _scrollOffset = 0.0;
          });
        },
      );
    }

    return ChapterSelectorScreen(
      key: ValueKey('chapter_selector_${_selectedBook!.id}'),
      book: _selectedBook!,
      onBack: () {
        setState(() {
          _selectedBook = null;
          _selectedChapter = null;
          _scrollOffset = 0.0;
        });
      },
      onChapterSelected: (chapter) {
        setState(() {
          _selectedChapter = chapter;
          _scrollOffset = 0.0;
        });
      },
    );
  }

  Widget _buildDetailPane(BuildContext context) {
    if (_selectedBook == null || _selectedChapter == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 64,
                  color: AppColors.liturgicalGold.withValues(alpha: 0.8),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'ምዕራፍ ለመጀመር ከግራ በኩል መጽሐፍ ይምረጡ',
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionTitle(context, isDark: isDark).copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _scrollOffset = notification.metrics.pixels;
        }
        return false;
      },
      child: ChapterReaderScreen(
        key: ValueKey('reader_${_selectedBook!.id}_${_selectedChapter}_$orientation'),
        bookName: _selectedBook!.nameAmharic,
        chapterNumber: _selectedChapter!,
        initialScrollOffset: _scrollOffset,
      ),
    );
  }
}
