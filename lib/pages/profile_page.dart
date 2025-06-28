// profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Logged in as ${user.email}')),
    );
  }
}
