import 'package:flutter/material.dart';

import 'src/providers/chat_settings_provider.dart';
import 'view/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SharedPrefs first
  final prefs = SharedPrefsHelper();
  await prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Chat',
        theme: ThemeData( colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true, ),
        home: const ChatScreen() );
  }
}