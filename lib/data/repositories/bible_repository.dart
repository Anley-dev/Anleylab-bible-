import 'dart:convert';
import 'package:flutter/services.dart';

class BibleRepository {
  static final BibleRepository _instance = BibleRepository._internal();
  factory BibleRepository() => _instance;
  BibleRepository._internal();

  Map<String, dynamic>? _bibleData;

  Future<Map<String, dynamic>> getFullBible() async {
    if (_bibleData != null) return _bibleData!;
    final String jsonString = await rootBundle.loadString('assets/bible/amharic_bible.json');
    _bibleData = jsonDecode(jsonString);
    return _bibleData!;
  }

  List<String> getAllBookNames(Map<String, dynamic> data) {
    return data.keys.toList();
  }
}