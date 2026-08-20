import 'package:flutter/services.dart';

class ShareService {
  /// Copies a formatted verse string to the system clipboard.
  /// Returns the formatted text so the caller can show confirmation feedback.
  static Future<String> shareVerse({
    required String bookName,
    required String chapter,
    required String verse,
    required String text,
  }) async {
    final formatted = '"$text"\n\n— $bookName $chapter:$verse\n\nANLEYLAB Bible';
    await Clipboard.setData(ClipboardData(text: formatted));
    return formatted;
  }

  /// Copies any raw text to the system clipboard.
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

