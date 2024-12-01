import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> addNote() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // Navigate to sign-in page if user is not authenticated
      return;
    }

    await supabase.from('notes').insert({
      'title': titleController.text,
      'content': contentController.text,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    });

    Navigator.pop(context); // Return to the notes page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 6,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: addNote,
              child: const Text('Add Note'),
            ),
          ],
        ),
      ),
    );
  }
}
