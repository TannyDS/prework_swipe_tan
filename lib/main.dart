import 'package:flutter/material.dart';
import 'package:prework_swipe/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.purple.shade50),
      home: const LoginPage(),
    );
  }
}
