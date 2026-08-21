import 'package:flutter/material.dart';
import '../models/reading_history.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock reading history — set to null to preview empty state.
  // DateTime.now() is not a compile-time const, so no `const` here.
  ReadingHistory? _lastRead = ReadingHistory(
    bookId: 'john',
    bookNameAmharic: 'የዮሐንስ ወንጌል',
    chapter: 3,
    verse: 16,
    lastRead: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ANLEYLAB Bible',
          style: AppTypography.appTitle(context, isDark: isDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'መቼቶች',
            onPressed: () {
              // Day 5 Settings navigation
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Welcome Header
            Text(
              'እንኳን ደህና መጡ',
              style: AppTypography.secondaryText(isDark: isDark)
                  .copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),

            // Continue Reading Card (Conditional)
            if (_lastRead != null) ...[
              Text(
                'የመጨረሻ ንባብ',
                style: AppTypography.sectionTitle(context, isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildContinueReadingCard(context, _lastRead!, isDark),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Canon Selection Header
            Text(
              'መጽሐፍ ቅዱስ (73 መጻሕፍት)',
              style: AppTypography.sectionTitle(context, isDark: isDark),
            ),
            const SizedBox(height: AppSpacing.md),

            // Testament Entry Options
            _buildTestamentCard(
              context,
              title: 'ብሉይ ኪዳን',
              subtitle: '46 መጻሕፍት (ዲዩትሮካኖናውያንን ጨምሮ)',
              icon: Icons.auto_stories,
              countBadge: '46',
              isDark: isDark,
              onTap: () {
                // Navigate to Book Selector (Old Testament)
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _buildTestamentCard(
              context,
              title: 'ሐዲስ ኪዳን',
              subtitle: '27 መጻሕፍት',
              icon: Icons.menu_book,
              countBadge: '27',
              isDark: isDark,
              onTap: () {
                // Navigate to Book Selector (New Testament)
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    ReadingHistory history,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            // Jump directly into Reader Screen for this verse
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    // .withValues(alpha:) replaces deprecated .withOpacity()
                    color: AppColors.liturgicalBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.bookmark_outlined,
                    color: AppColors.liturgicalBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.bookNameAmharic,
                        style:
                            AppTypography.bookTitle(context, isDark: isDark),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'ምዕራፍ ${history.chapter} ፡ ቁጥር ${history.verse}',
                        style: AppTypography.secondaryText(isDark: isDark),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'ቀጥል',
                      style: AppTypography.buttonText(isDark: isDark),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.liturgicalBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestamentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String countBadge,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, size: 32, color: AppColors.liturgicalGold),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bookTitle(context, isDark: isDark)
                            .copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.secondaryText(isDark: isDark),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Text(
                    countBadge,
                    style: AppTypography.secondaryText(isDark: isDark)
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
