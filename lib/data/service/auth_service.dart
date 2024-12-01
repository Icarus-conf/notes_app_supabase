import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Sign Up with email, password, username, and profile image
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required File profileImage,
  }) async {
    try {
      // Create a user account
      final response =
          await supabase.auth.signUp(email: email, password: password);
      final user = response.user;

      if (user != null) {
        // Upload the profile image
        final imagePath = 'profile_images/${user.id}.jpg';
        await supabase.storage.from('avatars').upload(imagePath, profileImage);

        // Insert user details into the profiles table
        await supabase.from('profiles').insert({
          'id': user.id,
          'username': username,
          'avatar_url':
              supabase.storage.from('avatars').getPublicUrl(imagePath),
        });

        return null; // Sign up successful
      } else {
        return 'Sign up failed: No user returned.';
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  /// Sign In with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        return null; // Sign in successful
      } else {
        return 'Sign in failed: No user found.';
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  /// Sign Out the current user
  Future<String?> signOut() async {
    try {
      await supabase.auth.signOut();
      return null; // Sign out successful
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  /// Get the currently logged-in user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Reset password via email
  Future<String?> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null; // Reset email sent successfully
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
}
