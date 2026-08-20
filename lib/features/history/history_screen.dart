import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/constants/app_colors.dart';
import 'package:amharic_catholic_bible/features/history/models/history_entry.dart';
import 'package:amharic_catholic_bible/features/history/repositories/history_repository.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = HistoryRepository();

  // Helper to categorize dates into human-friendly strings
  String _getSectionHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'ዛሬ (Today)';
    } else if (checkDate == yesterday) {
      return 'ትላንት (Yesterday)';
    } else {
      switch (date.weekday) {
        case DateTime.monday:    return 'ሰኞ (Monday)';
        case DateTime.tuesday:   return 'ማክሰኞ (Tuesday)';
        case DateTime.wednesday: return 'ረቡዕ (Wednesday)';
        case DateTime.thursday:  return 'ሐሙስ (Thursday)';
        case DateTime.friday:    return 'አርብ (Friday)';
        case DateTime.saturday:  return 'ቅዳሜ (Saturday)';
        case DateTime.sunday:    return 'እሑድ (Sunday)';
        default:                 return 'ቀደም ሲል የነበሩ';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የንባብ ታሪክ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'ታሪክ አጽዳ',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('ታሪክ ማጽጃ'),
                  content: const Text('ሁሉንም የንባብ ታሪክ መሰረዝ እንደሚፈልጉ እርግጠኛ ነዎት?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('አይ')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('አዎ')),
                  ],
                ),
              );
              if (confirm == true) {
                _repo.clear();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final list = _repo.getAll();
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('ምንም የተቀመጠ የንባብ ታሪክ የለም።', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          // Group entries by date categories
          final Map<String, List<HistoryEntry>> grouped = {};
          for (var entry in list) {
            final header = _getSectionHeader(entry.timestamp);
            grouped.putIfAbsent(header, () => []).add(entry);
          }

          final headers = grouped.keys.toList();

          return ListView.builder(
            itemCount: headers.length,
            itemBuilder: (context, sectionIndex) {
              final sectionHeader = headers[sectionIndex];
              final sectionEntries = grouped[sectionHeader]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      sectionHeader,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sectionEntries.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final entry = sectionEntries[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.book_outlined, color: AppColors.primary),
                        ),
                        title: Text(
                          entry.book,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('ምዕራፍ ${entry.chapter}'),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterReaderScreen(
                                bookName: entry.book,
                                chapterNumber: entry.chapter,
                                initialScrollOffset: entry.scrollOffset,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}