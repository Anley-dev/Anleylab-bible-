import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/features/home/home_screen.dart';
import 'package:amharic_catholic_bible/features/bible/bible_screen.dart';
import 'package:amharic_catholic_bible/features/search/bible_search_screen.dart';
import 'package:amharic_catholic_bible/features/bookmarks/bookmarks_screen.dart';
import 'package:amharic_catholic_bible/features/notes/notes_screen.dart';


class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const BibleScreen(),
      const BibleSearchScreen(),
      const BookmarksScreen(),
      const NotesScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
        ],
      ),
    );
  }
}
