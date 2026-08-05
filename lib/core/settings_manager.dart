import 'package:flutter/foundation.dart';

class ReadingSettings extends ChangeNotifier {
  double _fontSize;
  double _lineHeight;
  bool _isDarkMode;

  ReadingSettings({
    this._fontSize = 20.0,
    this._lineHeight = 1.6,
    this._isDarkMode = false,
  });

  double get fontSize => _fontSize;
  set fontSize(double val) {
    if (_fontSize != val) {
      _fontSize = val;
      notifyListeners();
    }
  }

  double get lineHeight => _lineHeight;
  set lineHeight(double val) {
    if (_lineHeight != val) {
      _lineHeight = val;
      notifyListeners();
    }
  }

  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool val) {
    if (_isDarkMode != val) {
      _isDarkMode = val;
      notifyListeners();
    }
  }
}

final ReadingSettings globalSettings = ReadingSettings();
