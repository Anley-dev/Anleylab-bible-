import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';

// ─── ReaderSettings immutable value model ───────────────────────────────────

class ReaderSettings {
  final double fontSize;
  final double lineSpacing;
  final double letterSpacing;

  const ReaderSettings({
    required this.fontSize,
    required this.lineSpacing,
    required this.letterSpacing,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineSpacing,
    double? letterSpacing,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  static const ReaderSettings defaults = ReaderSettings(
    fontSize: 20.0,
    lineSpacing: 1.6,
    letterSpacing: 0.2,
  );
}

// ─── ValueNotifier-based settings manager (persists to SharedPreferences) ───

class ReaderSettingsNotifier extends ValueNotifier<ReaderSettings> {
  static const _keyFontSize      = 'settings_font_size';
  static const _keyLineSpacing   = 'settings_line_height';
  static const _keyLetterSpacing = 'settings_letter_spacing';
  static const _keyThemeMode     = 'settings_theme_mode';

  ThemeMode _themeMode;

  ReaderSettingsNotifier()
      : _themeMode = _parseThemeMode(StorageService.getString(_keyThemeMode)),
        super(
          ReaderSettings(
            fontSize:      StorageService.getDouble(_keyFontSize)      ?? ReaderSettings.defaults.fontSize,
            lineSpacing:   StorageService.getDouble(_keyLineSpacing)   ?? ReaderSettings.defaults.lineSpacing,
            letterSpacing: StorageService.getDouble(_keyLetterSpacing) ?? ReaderSettings.defaults.letterSpacing,
          ),
        );

  static ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  static String _encodeThemeMode(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.dark:   return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  // ── Font size ────────────────────────────────────────────────────────────

  double get fontSize => value.fontSize;

  set fontSize(double v) {
    if (value.fontSize != v) {
      value = value.copyWith(fontSize: v);
      StorageService.setDouble(_keyFontSize, v);
    }
  }

  void updateFontSize(double v) => fontSize = v;

  // ── Line spacing ─────────────────────────────────────────────────────────

  double get lineHeight => value.lineSpacing;

  set lineHeight(double v) {
    if (value.lineSpacing != v) {
      value = value.copyWith(lineSpacing: v);
      StorageService.setDouble(_keyLineSpacing, v);
    }
  }

  void updateLineSpacing(double v) => lineHeight = v;

  // ── Letter spacing ───────────────────────────────────────────────────────

  double get letterSpacing => value.letterSpacing;

  set letterSpacing(double v) {
    if (value.letterSpacing != v) {
      value = value.copyWith(letterSpacing: v);
      StorageService.setDouble(_keyLetterSpacing, v);
    }
  }

  void updateLetterSpacing(double v) => letterSpacing = v;

  // ── Theme mode ───────────────────────────────────────────────────────────

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode m) {
    if (_themeMode != m) {
      _themeMode = m;
      StorageService.setString(_keyThemeMode, _encodeThemeMode(m));
      notifyListeners();
    }
  }

  /// Backward-compat: returns true only when explicitly set to dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Backward-compat setter — maps bool to ThemeMode.
  set isDarkMode(bool v) => themeMode = v ? ThemeMode.dark : ThemeMode.light;
}

/// Global singleton — accessed project-wide as [globalSettings].
final ReaderSettingsNotifier globalSettings = ReaderSettingsNotifier();
