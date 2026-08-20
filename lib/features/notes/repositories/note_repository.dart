import 'package:amharic_catholic_bible/features/notes/models/note.dart';
import 'package:amharic_catholic_bible/core/services/note_service.dart';

/// Repository layer for Note objects, delegating persistence to NoteService.
class NoteRepository {
  final NoteService _service = NoteService();

  /// Returns all saved notes.
  Future<List<Note>> getNotes() async => await _service.getNotes();

  /// Saves a note (adds or updates).
  Future<void> saveNote(Note note) async => await _service.saveNote(note);

  /// Deletes a note by its id.
  Future<void> deleteNote(String id) async => await _service.deleteNote(id);
}
