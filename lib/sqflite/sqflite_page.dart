import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note_model.dart';
import '../widgets/custom_card.dart';

class SqflitePage extends StatefulWidget {
  const SqflitePage({super.key});

  @override
  State<SqflitePage> createState() => _SqflitePageState();
}

class _SqflitePageState extends State<SqflitePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late List<Note> _notes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    _notes = await DatabaseHelper.instance.readAllNotes();
    setState(() => _isLoading = false);
  }

  Future<void> _addOrUpdateNote({Note? note}) async {
    _titleController.text = note?.title ?? '';
    _contentController.text = note?.content ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                if (note == null) {
                  await DatabaseHelper.instance.create(
                    Note(
                      title: _titleController.text,
                      content: _contentController.text,
                    ),
                  );
                } else {
                  await DatabaseHelper.instance.update(
                    Note(
                      id: note.id,
                      title: _titleController.text,
                      content: _contentController.text,
                    ),
                  );
                }
                if (mounted) Navigator.pop(context);
                _refreshNotes();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNote(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sqflite Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Structured relational database. Good for complex querying.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notes.isEmpty
                  ? const Center(child: Text('No notes yet'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CustomCard(
                            onTap: () => _addOrUpdateNote(note: note),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => _deleteNote(note.id!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(note.content),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
