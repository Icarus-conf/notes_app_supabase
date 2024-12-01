import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  final SupabaseClient supabase;

  NotesService(this.supabase);

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('username, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotes(String userId) async {
    try {
      final response = await supabase
          .from('notes')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error fetching notes: $e');
      return [];
    }
  }

  Future<void> addNote(String userId, String title, String content) async {
    try {
      await supabase.from('notes').insert({
        'title': title,
        'content': content,
        'user_id': userId,
      });
    } catch (e) {
      log('Error adding note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await supabase.from('notes').delete().eq('id', noteId);
    } catch (e) {
      log('Error deleting note: $e');
    }
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    try {
      await supabase.from('notes').update({
        'title': title,
        'content': content,
      }).eq('id', noteId);
    } catch (e) {
      log('Error updating note: $e');
    }
  }
}
