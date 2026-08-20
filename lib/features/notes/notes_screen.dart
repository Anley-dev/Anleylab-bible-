import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/features/notes/models/note.dart';
import 'package:amharic_catholic_bible/features/notes/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:amharic_catholic_bible/core/services/note_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteRepository _repo = NoteRepository();
  List<Note> _allNotes = [];
  List<Note> _displayedNotes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Listen for changes in notes storage
    NoteService().notifier.addListener(_loadNotes);
    _loadNotes();
  }

  @override
  void dispose() {
    NoteService().notifier.removeListener(_loadNotes);
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await _repo.getNotes();
    setState(() {
      _allNotes = notes;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Note> filtered = List.from(_allNotes);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((n) => n.book.toLowerCase().contains(q) || n.content.toLowerCase().contains(q)).toList();
    }
    // Sort alphabetically by book name
    filtered.sort((a, b) => a.book.compareTo(b.book));
    _displayedNotes = filtered;
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final bool isEditing = note != null;
    final TextEditingController bookCtrl = TextEditingController(text: note?.book ?? '');
    final TextEditingController chapterCtrl = TextEditingController(text: note != null ? note!.chapter.toString() : '');
    final TextEditingController verseCtrl = TextEditingController(text: note != null ? note!.verse.toString() : '');
    final TextEditingController contentCtrl = TextEditingController(text: note?.content ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: bookCtrl, decoration: const InputDecoration(labelText: 'Book')),
              TextField(controller: chapterCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chapter')),
              TextField(controller: verseCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Verse')),
              TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Content')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final String book = bookCtrl.text.trim();
              final int? chapter = int.tryParse(chapterCtrl.text.trim());
              final int? verse = int.tryParse(verseCtrl.text.trim());
              final String content = contentCtrl.text.trim();
              if (book.isEmpty || chapter == null || verse == null || content.isEmpty) return;
              final newNote = Note(
                id: isEditing ? note!.id : Uuid().v4(),
                book: book,
                chapter: chapter,
                verse: verse,
                content: content,
              );
              await _repo.saveNote(newNote);
              await _loadNotes();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(String id) async {
    await _repo.deleteNote(id);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                _searchQuery = val;
                setState(() => _applyFilters());
              },
            ),
          ),
        ),
      ),
      body: _displayedNotes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
              itemCount: _displayedNotes.length,
              itemBuilder: (context, index) {
                final note = _displayedNotes[index];
                return ListTile(
                  title: Text('${note.book} ${note.chapter}:${note.verse}'),
                  subtitle: Text(note.content),
                  trailing: Text('${note.timestamp.year}-${note.timestamp.month.toString().padLeft(2, '0')}-${note.timestamp.day.toString().padLeft(2, '0')}'),
                  onTap: () => _showNoteDialog(note: note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
        onPressed: () => _showNoteDialog(),
      ),
    );
  }
}
