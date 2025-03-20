import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(MathArcade());
}

class MathArcade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Arcade',
      theme: ThemeData(fontFamily: 'Comic Sans MS'),
      home: HomeScreen(),
    );
  }
}