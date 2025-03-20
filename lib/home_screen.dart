import 'package:flutter/material.dart';
import 'compare_screen.dart';
import 'order_screen.dart';
import 'compose_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: Text('Math Arcade!', style: TextStyle(fontSize: 28, color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, 'Compare Blast', Colors.red, CompareScreen()),
            SizedBox(height: 20),
            _buildButton(context, 'Order Rush', Colors.green, OrderScreen()),
            SizedBox(height: 20),
            _buildButton(context, 'Number Mix', Colors.blue, ComposeScreen()),
            SizedBox(height: 20),
            _buildButton(context, 'Leaderboard', Colors.orange, LeaderboardScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color, Widget screen) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        textStyle: TextStyle(fontSize: 24, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}