import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  final ReadingSettings settings;
  final VoidCallback onUpdate;

  const SettingsScreen({super.key, required this.settings, required this.onUpdate});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ቅንብሮች (Settings)")), // Amharic label
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("የፊደል መጠን (Font Size)"),
            Slider(
              value: widget.settings.fontSize,
              min: 14, max: 30,
              onChanged: (val) {
                setState(() => widget.settings.fontSize = val);
                widget.onUpdate(); // Notify the app to rebuild
              },
            ),
            const Text("የመስመር ክፍተት (Line Height)"),
            Slider(
              value: widget.settings.lineHeight,
              min: 1.0, max: 2.5,
              onChanged: (val) {
                setState(() => widget.settings.lineHeight = val);
                widget.onUpdate();
              },
            ),
            SwitchListTile(
              title: const Text("ጨለማ ሁነታ (Dark Mode)"),
              value: widget.settings.isDarkMode,
              onChanged: (val) {
                setState(() => widget.settings.isDarkMode = val);
                widget.onUpdate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
