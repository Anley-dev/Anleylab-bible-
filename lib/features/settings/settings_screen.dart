import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/settings_manager.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:amharic_catholic_bible/features/settings/about_screen.dart';

/// Full-page Settings screen.
///
/// All controls write directly into [globalSettings] (a [ReaderSettingsNotifier]
/// that persists to SharedPreferences). No constructor parameters are needed
/// because the notifier is a project-wide singleton.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('ቅንብሮች')),
      body: ValueListenableBuilder<ReaderSettings>(
        valueListenable: globalSettings,
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ── Typography section ────────────────────────────────────────
              _SectionHeader(label: 'ጽሑፍ', isDark: isDark),

              // Font size
              _SliderTile(
                icon: Icons.format_size,
                label: 'የፊደል መጠን',
                valueLabel: '${settings.fontSize.toInt()}pt',
                value: settings.fontSize,
                min: 14.0,
                max: 30.0,
                divisions: 8,
                onChanged: globalSettings.updateFontSize,
              ),

              // Line spacing
              _SliderTile(
                icon: Icons.format_line_spacing,
                label: 'የመስመር ክፍተት',
                valueLabel: '${settings.lineSpacing.toStringAsFixed(1)}×',
                value: settings.lineSpacing,
                min: 1.2,
                max: 2.4,
                divisions: 6,
                onChanged: globalSettings.updateLineSpacing,
              ),

              // Letter spacing
              _SliderTile(
                icon: Icons.text_fields,
                label: 'የቃላት ርቀት',
                valueLabel: settings.letterSpacing.toStringAsFixed(1),
                value: settings.letterSpacing,
                min: 0.0,
                max: 1.0,
                divisions: 5,
                onChanged: globalSettings.updateLetterSpacing,
              ),

              const Divider(height: 32),

              // ── Appearance section ────────────────────────────────────────
              _SectionHeader(label: 'መልክ', isDark: isDark),

              // We rebuild this section on themeMode changes via a separate
              // ListenableBuilder so the slider section doesn't redraw.
              ListenableBuilder(
                listenable: globalSettings,
                builder: (context2, w) {
                  final mode = globalSettings.themeMode;
                  return RadioGroup<ThemeMode>(
                    groupValue: mode,
                    onChanged: (m) {
                      if (m != null) globalSettings.themeMode = m;
                    },
                    child: Column(
                      children: [
                        _ThemeRadioTile(
                          icon: Icons.light_mode_outlined,
                          label: 'ብርሃን ሁነታ',
                          subtitle: 'Light',
                          value: ThemeMode.light,
                          isSelected: mode == ThemeMode.light,
                        ),
                        _ThemeRadioTile(
                          icon: Icons.dark_mode_outlined,
                          label: 'ጨለማ ሁነታ',
                          subtitle: 'Dark',
                          value: ThemeMode.dark,
                          isSelected: mode == ThemeMode.dark,
                        ),
                        _ThemeRadioTile(
                          icon: Icons.brightness_auto_outlined,
                          label: 'ስርዓቱን ተከተሉ',
                          subtitle: 'System',
                          value: ThemeMode.system,
                          isSelected: mode == ThemeMode.system,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 32),

              // ── About section ─────────────────────────────────────────────
              _SectionHeader(label: 'ስለ መተግበሪያው', isDark: isDark),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('ስለ ANLEYLAB Bible'),
                subtitle: const Text('Version 1.0.0 • Catholic 73-Book Canon'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 4,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.liturgicalGold,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(valueLabel, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  const _ThemeRadioTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final ThemeMode value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.liturgicalGold : null,
      ),
      title: Text(label),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: AppColors.liturgicalGold,
    );
  }
}
