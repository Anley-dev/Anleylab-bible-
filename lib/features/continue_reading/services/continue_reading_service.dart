import 'package:amharic_catholic_bible/core/services/storage_service.dart';
import 'package:amharic_catholic_bible/features/continue_reading/models/continue_entry.dart';
import 'dart:convert';

class ContinueReadingService {
  static const String _key = 'continue_reading_entry';

  Future<ContinueEntry?> getLastEntry() async {
    final jsonString = StorageService.getString(_key);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return ContinueEntry.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveEntry(ContinueEntry entry) async {
    final jsonString = jsonEncode(entry.toJson());
    await StorageService.setString(_key, jsonString);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}
