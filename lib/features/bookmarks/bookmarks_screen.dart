import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';
import 'package:amharic_catholic_bible/features/bookmarks/models/bookmark.dart';
import 'package:amharic_catholic_bible/features/bookmarks/repositories/bookmark_repository.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkRepository _bookmarkRepo = BookmarkRepository();
  late Future<List<Bookmark>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _bookmarksFuture = _bookmarkRepo.getBookmarks();
    });
  }

  Future<void> _delete(Bookmark b) async {
    await _bookmarkRepo.deleteBookmark(b.id);
    _reload();
  }

  void _openVerse(Bookmark b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(
          bookName: b.bookName,
          chapterNumber: b.chapter.toString(),
          initialScrollOffset: 0.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የተቀመጡ ጥቅሶች'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Bookmark>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'ምንም ጥቅስ አልተቀመጠም።',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final bookmarks = snapshot.data!;
          final Map<String, List<Bookmark>> grouped = {};
          for (final b in bookmarks) {
            grouped.putIfAbsent(b.bookName, () => []).add(b);
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: grouped.entries.map((entry) {
              final bookName = entry.key;
              final items = entry.value;
              
              return ExpansionTile(
                initiallyExpanded: true,
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(
                  bookName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${items.length} ጥቅስ',
                  style: const TextStyle(fontSize: 12),
                ),
                children: items.map((bookmark) {
                  return Dismissible(
                    key: ValueKey(bookmark.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) => _delete(bookmark),
                    child: ListTile(
                      onTap: () => _openVerse(bookmark),
                      leading: CircleAvatar(
                        radius: 18,
                        child: Text(
                          '${bookmark.verseNumber}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                        '${bookmark.bookName} ${bookmark.chapter}:${bookmark.verseNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            bookmark.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ተቀምጧል: ${bookmark.dateSaved}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'አስወግድ',
                        onPressed: () => _delete(bookmark),
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}