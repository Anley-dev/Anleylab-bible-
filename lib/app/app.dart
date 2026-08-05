import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/main.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';

class AnleyLabBibleApp extends StatefulWidget {
  const AnleyLabBibleApp({super.key});

  @override
  State<AnleyLabBibleApp> createState() => _AnleyLabBibleAppState();
}

class _AnleyLabBibleAppState extends State<AnleyLabBibleApp> {
  @override
  void initState() {
    super.initState();
    globalSettings.addListener(_updateTheme);
  }

  @override
  void dispose() {
    globalSettings.removeListener(_updateTheme);
    super.dispose();
  }

  void _updateTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANLEYLAB Bible',
      debugShowCheckedModeBanner: false,
      theme: globalSettings.isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: const MainNavigationController(),
    );
  }
}
