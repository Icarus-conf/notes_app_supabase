import 'package:flutter/material.dart';
import 'package:notes_app_supabase/notes_view.dart';
import 'package:notes_app_supabase/sign_in_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return const NotesPage();
          } else {
            return const SignInPage();
          }
        });
  }
}
