import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';
import 'package:amharic_catholic_bible/features/bible/models/book_model.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';

class ChapterSelectorScreen extends StatelessWidget {
  final BookModel book;
  final void Function(String)? onChapterSelected;
  final VoidCallback? onBack;

  const ChapterSelectorScreen({
    super.key,
    required this.book,
    this.onChapterSelected,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.nameAmharic,
          style: AppTypography.appTitle(context, isDark: isDark),
        ),
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'ምዕራፍ ምረጥ',
                style: AppTypography.sectionTitle(context, isDark: isDark),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                ),
                itemCount: book.totalChapters,
                itemBuilder: (context, index) {
                  final chapterNumber = index + 1;
                  return Material(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () {
                        if (onChapterSelected != null) {
                          onChapterSelected!(chapterNumber.toString());
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChapterReaderScreen(
                                bookName: book.nameAmharic,
                                chapterNumber: chapterNumber.toString(),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            '$chapterNumber',
                            style: AppTypography.bookTitle(context, isDark: isDark)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
