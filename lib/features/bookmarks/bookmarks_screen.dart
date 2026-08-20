import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/services/bookmark_service.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';

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
    _loadBookmarks();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የተቀመጡ ጥቅሶች (Bookmarks)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(child: Text('ምንም የተቀመጠ ጥቅስ የለም።'))
              : ListView.builder(
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarks[index];
                    return ListTile(
                      title: Text('${item['book']} ምዕራፍ ${item['chapter']}:${item['verse']}'),
                      subtitle: Text(item['text'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await _bookmarkService.removeBookmark(
                            item['book']!,
                            item['chapter']!,
                            item['verse']!,
                          );
                          _loadBookmarks();
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChapterReaderScreen(
                              bookName: item['book']!,
                              chapterNumber: item['chapter']!,
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