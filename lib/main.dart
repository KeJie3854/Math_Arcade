import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(MathApp());
}

class MathApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Arcade',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomeScreen(),
    );
  }
}