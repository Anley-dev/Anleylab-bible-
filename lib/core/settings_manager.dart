import 'package:flutter/foundation.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';

class ReadingSettings extends ChangeNotifier {
  static const _keyFontSize = 'settings_font_size';
  static const _keyLineHeight = 'settings_line_height';
  static const _keyDarkMode = 'settings_dark_mode';

  double _fontSize;
  double _lineHeight;
  bool _isDarkMode;

  ReadingSettings({
    double fontSize = 20.0,
    double lineHeight = 1.6,
    bool isDarkMode = false,
  })  : _fontSize = fontSize,
        _lineHeight = lineHeight,
        _isDarkMode = isDarkMode {
    _loadFromStorage();
  }

  /// Restores saved values from SharedPreferences on startup.
  void _loadFromStorage() {
    _fontSize = StorageService.getDouble(_keyFontSize) ?? _fontSize;
    _lineHeight = StorageService.getDouble(_keyLineHeight) ?? _lineHeight;
    _isDarkMode = StorageService.getBool(_keyDarkMode) ?? _isDarkMode;
  }

  double get fontSize => _fontSize;
  set fontSize(double val) {
    if (_fontSize != val) {
      _fontSize = val;
      StorageService.setDouble(_keyFontSize, val);
      notifyListeners();
    }
  }

  double get lineHeight => _lineHeight;
  set lineHeight(double val) {
    if (_lineHeight != val) {
      _lineHeight = val;
      StorageService.setDouble(_keyLineHeight, val);
      notifyListeners();
    }
  }

  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool val) {
    if (_isDarkMode != val) {
      _isDarkMode = val;
      StorageService.setBool(_keyDarkMode, val);
      notifyListeners();
    }
  }
}

final ReadingSettings globalSettings = ReadingSettings();

