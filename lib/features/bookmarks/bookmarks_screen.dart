import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/services/bookmark_service.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<Map<String, String>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bookmarkService.notifier.addListener(_loadBookmarks);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _bookmarkService.notifier.removeListener(_loadBookmarks);
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _bookmarks = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(Map<String, String> item) async {
    await _bookmarkService.removeBookmark(
      item['book']!,
      item['chapter']!,
      item['verse']!,
    );
    await _loadBookmarks();
  }

  Future<void> _confirmRemove(Map<String, String> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ማስታወሻ ይሰረዝ?'),
        content: Text(
          '${item['book']} ምዕራፍ ${item['chapter']}:${item['verse']} ቁጥር ማስታወሻ ይሰረዝ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('አይ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('አዎ፣ ሰርዝ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await _removeBookmark(item);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('ጥቅሱ ከዝርዝሩ ተሰርዟል።')),
        );
      }
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የተቀመጡ ጥቅሶች'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarks[index];
                    return Dismissible(
                      key: ValueKey('${item['book']}_${item['chapter']}_${item['verse']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('ጥቅሱ ይሰረዝ?'),
                            content: Text(
                              '${item['book']} ${item['chapter']}:${item['verse']} ከዝርዝሩ ይሰረዝ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('አይ'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('አዎ፣ ሰርዝ', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        return confirmed == true;
                      },
                      onDismissed: (_) async {
                        final messenger = ScaffoldMessenger.of(context);
                        await _removeBookmark(item);
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('ጥቅሱ ተሰርዟል።')),
                          );
                        }
                      },
                      child: _BookmarkCard(
                        item: item,
                        dateLabel: _formatDate(item['date']),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChapterReaderScreen(
                              bookName: item['book']!,
                              chapterNumber: item['chapter']!,
                            ),
                          ),
                        ),
                        onDelete: () => _confirmRemove(item),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_outlined,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'ምንም ጥቅስ አልተቀመጠም።',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ጥቅስ ሲያነቡ ⊕ ወይም ★ ን ይጫኑ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.item,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, String> item;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold bookmark icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.liturgicalGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.liturgicalGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item['book']} ምዕራፍ ${item['chapter']}:${item['verse']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (dateLabel.isNotEmpty)
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    if ((item['text'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['text']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Delete icon
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.redAccent,
                tooltip: 'ሰርዝ',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
