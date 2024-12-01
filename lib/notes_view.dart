import 'package:flutter/material.dart';
import 'package:notes_app_supabase/data/service/note_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final NotesService notesService;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> notes = [];

  _NotesPageState() : notesService = NotesService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchNotes();
  }

  Future<void> fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final data = await notesService.fetchUserData(user.id);
      setState(() {
        userData = data;
      });
    }
  }

  Future<void> fetchNotes() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final fetchedNotes = await notesService.fetchNotes(user.id);
      setState(() {
        notes = fetchedNotes;
      });
    }
  }

  Future<void> addNote() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
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
                await notesService.addNote(
                    user.id, titleController.text, contentController.text);
                Navigator.pop(context);
                fetchNotes();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteNote(String noteId) async {
    await notesService.deleteNote(noteId);
    fetchNotes();
  }

  Future<void> updateNote(Map<String, dynamic> note) async {
    final titleController = TextEditingController(text: note['title']);
    final contentController = TextEditingController(text: note['content']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
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
                await notesService.updateNote(
                    note['id'], titleController.text, contentController.text);
                Navigator.pop(context);
                fetchNotes();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          children: [
            if (userData != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userData!['avatar_url'] != null
                          ? NetworkImage(userData!['avatar_url'])
                          : null,
                      child: userData!['avatar_url'] == null
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      userData!['username'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.pushReplacementNamed(context, '/signIn');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: addNote,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note['created_at'].toString().split('T').first,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          note['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      note['content'],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => updateNote(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNote(note['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
