import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/features/bible/bible_controller.dart';
import 'package:amharic_catholic_bible/features/bible/chapter_reader_screen.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final BibleController _controller = BibleController();
  late Future<Map<String, List<String>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _controller.getCategorizedBooks();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Old Testament and New Testament
      child: Scaffold(
        appBar: AppBar(
          title: const Text("መጽሐፍ ቅዱስ"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "ብሉይ ኪዳን"), // Old Testament
              Tab(text: "ሐዲስ ኪዳን"), // New Testament
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<String>>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final data = snapshot.data!;
            return TabBarView(
              children: [
                _buildBookList(data["ብሉይ ኪዳን"]!), // List for Old Testament
                _buildBookList(data["ሐዲስ ኪዳን"]!), // List for New Testament
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper to keep code clean
  Widget _buildBookList(List<String> books) {
    return ListView.separated(
      itemCount: books.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => ListTile(
        title: Text(books[index]),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _handleBookSelection(context, books[index]),
      ),
    );
  }
  
  // Logic to trigger the chapter picker grid
  void _handleBookSelection(BuildContext context, String book) async {
    // 1. Fetch the chapter list first
    List<String> chapters = await _controller.getChapterList(book);
    
    // 2. Open a modal or a new screen to let the user pick
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemCount: chapters.length,
        itemBuilder: (context, index) => ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close picker
            // 3. Now navigate to the specific chosen chapter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChapterReaderScreen(
                  bookName: book,
                  chapterNumber: chapters[index],
                ),
              ),
            ).then((_) {
              if (context.mounted) {
                (context as Element).markNeedsBuild();
              }
            });
          },
          child: Text(chapters[index]),
        ),
      ),
    );
  }
}