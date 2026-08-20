import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:amharic_catholic_bible/core/services/storage_service.dart';
import 'package:amharic_catholic_bible/features/notes/models/note.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  static const String _keyNotes = 'user_notes_list';
  final ValueNotifier<int> notifier = ValueNotifier(0);

  // Fetch all notes as Note objects
  Future<List<Note>> getNotes() async {
    final String? jsonString = StorageService.getString(_keyNotes);
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save a new note (adds to front)
  Future<void> saveNote(Note note) async {
    final notes = await getNotes();
    // Remove duplicate id if exists
    notes.removeWhere((n) => n.id == note.id);
    notes.insert(0, note);
    await StorageService.setString(_keyNotes, jsonEncode(notes.map((n) => n.toJson()).toList()));
    notifier.value++;
  }

  // Delete a note by id
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await StorageService.setString(_keyNotes, jsonEncode(notes.map((n) => n.toJson()).toList()));
    notifier.value++;
  }
}
