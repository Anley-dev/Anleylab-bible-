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
    if (mounted) {
      setState(() {
        _allNotes = notes;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    List<Note> filtered = List.from(_allNotes);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((n) =>
              n.book.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q))
          .toList();
    }
    // Sort newest first
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _displayedNotes = filtered;
  }

  // ── Delete ──────────────────────────────────────────────────────────────────

  Future<void> _deleteNote(String id) async {
    await _repo.deleteNote(id);
    await _loadNotes();
  }

  /// Shows a confirmation dialog before deleting a note.
  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ማስታወሻ ይሰረዝ?'),
        content: Text(
          '${note.book} ${note.chapter}:${note.verse} ላይ ያለው ማስታወሻ ይሰረዝ?\n\n"${note.content}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('አይ፣ ተወው'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('አዎ፣ ሰርዝ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ማስታወሻው ተሰርዟል።')),
        );
      }
    }
  }

  // ── Add / Edit Dialog ────────────────────────────────────────────────────────

  Future<void> _showNoteDialog({Note? note}) async {
    final bool isEditing = note != null;
    final bookCtrl    = TextEditingController(text: note?.book ?? '');
    final chapterCtrl = TextEditingController(text: note != null ? note.chapter.toString() : '');
    final verseCtrl   = TextEditingController(text: note != null ? note.verse.toString()   : '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'ማስታወሻ አርም' : 'ማስታወሻ ያዝ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookCtrl,
                decoration: const InputDecoration(
                  labelText: 'መጽሐፍ',
                  hintText: 'ለምሳሌ፦ ዮሐንስ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: chapterCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ምዕራፍ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: verseCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ቁጥር (ጥቅስ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'ይዘት',
                  hintText: 'ማስታወሻዎን ይፃፉ...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ሰርዝ'),
          ),
          ElevatedButton(
            onPressed: () async {
              final String book    = bookCtrl.text.trim();
              final int? chapter   = int.tryParse(chapterCtrl.text.trim());
              final int? verse     = int.tryParse(verseCtrl.text.trim());
              final String content = contentCtrl.text.trim();
              if (book.isEmpty || chapter == null || verse == null || content.isEmpty) return;
              final newNote = Note(
                id:      isEditing ? note.id : const Uuid().v4(),
                book:    book,
                chapter: chapter,
                verse:   verse,
                content: content,
              );
              await _repo.saveNote(newNote);
              await _loadNotes();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('አስቀምጥ'),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ማስታወሻዎች'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ማስታወሻዎችን ፈልግ...',
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'ምንም ማስታወሻ የለም።\nከታች ያለውን + ተጭነው ይጨምሩ።'
                        : 'ምንም ውጤት አልተገኘም።',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.6),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _displayedNotes.length,
              itemBuilder: (context, index) {
                final note = _displayedNotes[index];
                // Swipe left to delete
                return Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (_) async {
                    // Reuse the confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('ማስታወሻ ይሰረዝ?'),
                        content: Text(
                          '${note.book} ${note.chapter}:${note.verse} ላይ ያለው ማስታወሻ ይሰረዝ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('አይ'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('አዎ፣ ሰርዝ', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    return confirmed == true;
                  },
                  onDismissed: (_) async {
                    await _deleteNote(note.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ማስታወሻው ተሰርዟል።')),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.note, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        '${note.book} ${note.chapter}:${note.verse}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date badge
                          Text(
                            '${note.timestamp.day.toString().padLeft(2, '0')}/'
                            '${note.timestamp.month.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          const SizedBox(width: 4),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'ሰርዝ',
                            onPressed: () => _confirmDelete(note),
                          ),
                        ],
                      ),
                      onTap: () => _showNoteDialog(note: note),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'ማስታወሻ ያዝ',
        icon: const Icon(Icons.add),
        label: const Text('ማስታወሻ ያዝ'),
        onPressed: () => _showNoteDialog(),
      ),
    );
  }
}

