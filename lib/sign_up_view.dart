import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  File? _profileImage;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> signUp() async {
    final email = emailController.text;
    final password = passwordController.text;
    final username = usernameController.text;

    if (_profileImage == null ||
        email.isEmpty ||
        password.isEmpty ||
        username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    try {
      final response =
          await supabase.auth.signUp(email: email, password: password);
      final user = response.user;

      if (user != null) {
        // Upload the profile image
        final imagePath = 'profile_images/${user.id}.jpg';
        await supabase.storage
            .from('avatars')
            .upload(imagePath, _profileImage!);

        // Update user's metadata
        await supabase.from('profiles').insert({
          'id': user.id,
          'username': username,
          'avatar_url':
              supabase.storage.from('avatars').getPublicUrl(imagePath),
        });

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
