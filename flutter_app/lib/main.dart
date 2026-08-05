import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:amharic_catholic_bible/core/constants/app_colors.dart';
import 'package:amharic_catholic_bible/data/models/bible_model.dart';

void main() {
  runApp(const AnleyLabBibleApp());
}

class AnleyLabBibleApp extends StatelessWidget {
  const AnleyLabBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANLEYLAB Bible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: AppColors.textDark,
            fontSize: 16.0,
            height: 1.5,
          ),
        ),
      ),
      home: const MainNavigationController(),
    );
  }
}

class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BibleScreen(),
    const SearchScreen(),
    const SavedScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: AppColors.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ዋና ገጽ'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'መጽሐፍ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'ፈልግ'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'የተቀመጡ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ቅንብር'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initBibleDataPipeline();
  }

  Future<void> _initBibleDataPipeline() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/bible/amharic_bible.json');
      final Map<String, dynamic> fullBibleMap = jsonDecode(jsonString);
      final BibleChapter genesis1 = BibleChapter.fromRawJson(fullBibleMap, "ኦሪት ዘፍጥረት", "1");
      
      debugPrint('--- Data Pipeline Check ---');
      debugPrint('Book: ${genesis1.bookName}');
      debugPrint('Chapter: ${genesis1.chapterNumber}');
      debugPrint('Verse 1: ${genesis1.verses[1]}');
      debugPrint('--------------------------');
    } catch (exception) {
      debugPrint('Database Initialization Error: $exception');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ANLEYLAB BIBLE'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'እንኳን ወደ ANLEYLAB መጽሐፍ ቅዱስ በደህና መጡ።',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('መጽሐፍ ቅዱስ'), centerTitle: true),
      body: const Center(child: Text('የመጽሐፍ ቅዱስ ዝርዝር (Week 2 Objective)')),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ፈልግ'), centerTitle: true),
      body: const Center(child: Text('ቃላት መፈለጊያ ክፍል')),
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('የተቀመጡ ጥቅሶች'), centerTitle: true),
      body: const Center(child: Text('የተመረጡ ጥቅሶች ማከማቻ')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ቅንብሮች'), centerTitle: true),
      body: const Center(child: Text('የፊደል መጠን እና ገጽታ ማስተካከያ')),
    );
  }
}
