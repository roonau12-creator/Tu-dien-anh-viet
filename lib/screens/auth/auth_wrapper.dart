import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        final displayName =
            user.displayName ?? user.email?.split('@').first ?? user.uid;
        return MainScreen(
          currentUserId: user.uid,
          displayUsername: displayName,
        );
      },
    );
  }
}