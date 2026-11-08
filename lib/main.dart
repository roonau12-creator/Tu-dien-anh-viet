import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await FirebaseService.seedInitialWords();
  } catch (e) {
    debugPrint('Không thể nạp dữ liệu mẫu: $e');
  }

  runApp(const DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Từ điển Việt–Anh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}
