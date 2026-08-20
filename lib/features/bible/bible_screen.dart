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

    // 2. Open a modal to let the user pick a chapter
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      // sheetContext is scoped to the sheet; we keep the outer [context] for
      // Navigator.push so it is always valid after the sheet is dismissed.
      builder: (sheetContext) => GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemCount: chapters.length,
        itemBuilder: (_, index) => ElevatedButton(
          onPressed: () {
            Navigator.pop(sheetContext); // close the sheet
            // 3. Navigate using the stable outer context — no Element hack needed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterReaderScreen(
                  bookName: book,
                  chapterNumber: chapters[index],
                ),
              ),
            );
          },
          child: Text(chapters[index]),
        ),
      ),
    );
  }
}