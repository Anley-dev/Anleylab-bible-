import 'dart:math';
import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/theme/app_tokens.dart';
import 'package:amharic_catholic_bible/theme/app_typography.dart';
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/features/history/history_screen.dart';
import 'package:amharic_catholic_bible/features/settings/settings_screen.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryRepository _historyRepository = HistoryRepository();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = _historyRepository.getAll();
    final HistoryEntry? lastRead = entries.isNotEmpty ? entries.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ANLEYLAB መጽሐፍ ቅዱስ',
          style: AppTypography.appTitle(context, isDark: isDark),
        ),
        actions: [
          // History Button
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'ታሪክ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ).then((_) => setState(() {}));
            },
          ),
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'መቼቶች',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Signature verse + daily quote header
            const HeaderVerseCard(),

            // Continue Reading Section
            if (lastRead != null) ...[
              Text(
                'የመጨረሻ ንባብ',
                style: AppTypography.sectionTitle(context, isDark: isDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildContinueReadingCard(context, lastRead, isDark),
            ] else ...[
              // Empty State when no history exists
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.massive),
                  child: Text(
                    'ምንም የተነበበ ታሪክ የለም',
                    style: AppTypography.secondaryText(isDark: isDark),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    HistoryEntry history,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterReaderScreen(
                  bookName: history.bookNameAmharic,
                  chapterNumber: history.chapter.toString(),
                  initialScrollOffset: history.scrollOffset,
                ),
              ),
            ).then((_) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.liturgicalBlue.withValues(alpha: 0.12),
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
                        style: AppTypography.bookTitle(context, isDark: isDark),
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
}

// Permanent signature verse + rotating daily quote widget
class HeaderVerseCard extends StatelessWidget {
  const HeaderVerseCard({super.key});

  static const List<Map<String, String>> _dailyVerses = [
    {
      'text': '"እግዚአብሔር ብርሃኔና መድኃኒቴ ነው፤ የሚያስፈራኝ ማን ነው?"',
      'ref': 'መዝሙር 27:1'
    },
    {
      'text': '"በሙሉ ልብህ በእግዚአብሔር ታመን፤ በራስህም ማስተዋል አትደገፍ።"',
      'ref': 'ምሳሌ 3:5'
    },
    {
      'text': '"ሰላምን እተውላችኋለሁ፤ ሰላሜን እሰጣችኋለሁ፤ እኔ የምሰጣችሁ ዓለም እንደሚሰጠው አይደለም።"',
      'ref': 'ዮሐንስ 14:27'
    },
    {
      'text': '"ኃይልን በሚሰጠኝ በእርሱ ሁሉን ማድረግ እችላለሁ።"',
      'ref': 'ፊልጵስዩስ 4:13'
    },
  ];

  Map<String, String> _getDailyVerse() {
    final now = DateTime.now();
    final dayOfYear = now.year * 365 + now.month * 31 + now.day;
    final random = Random(dayOfYear);
    return _dailyVerses[random.nextInt(_dailyVerses.length)];
  }

  @override
  Widget build(BuildContext context) {
    final dailyVerse = _getDailyVerse();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PERMANENT SIGNATURE VERSE (PURE TEXT IN GOLD — NO LABEL)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37), // Metallic Gold
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            '"እነሱ ጥሪዬን ችላ አሉ፤ እግዚአብሔር ግን ጸሎቴን መረጠ። በሰው የተናቀው ድንጋይ፡ በእግዚአብሔር እጅ የማዕዘን ራስ ሆነ።"',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: Color(0xFFC59B27), // Elegant Gold Text
            ),
          ),
        ),

        // 2. DYNAMIC DAILY QUOTE
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.format_quote, color: Color(0xFF9E1B32), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${dailyVerse['text']} — ${dailyVerse['ref']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
