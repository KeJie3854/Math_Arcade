import 'package:flutter/material.dart';
import 'compare_screen.dart';
import 'order_screen.dart';
import 'compose_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[300]!,
              Colors.yellow[200]!,
              Colors.orange[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purple[700],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Math Arcade!',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.yellow,
                            offset: Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ready to Rock Some Numbers?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.yellow[100],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        _buildFancyButton(
                          context,
                          'Compare Blast',
                          Colors.red[400]!,
                          Colors.red[800]!,
                          CompareScreen(),
                        ),
                        SizedBox(height: 20),
                        _buildFancyButton(
                          context,
                          'Order Rush',
                          Colors.green[400]!,
                          Colors.green[800]!,
                          OrderScreen(),
                        ),
                        SizedBox(height: 20),
                        _buildFancyButton(
                          context,
                          'Number Mix',
                          Colors.blue[400]!,
                          Colors.blue[800]!,
                          ComposeScreen(),
                        ),
                        SizedBox(height: 20),
                        _buildFancyButton(
                          context,
                          'Leaderboard',
                          Colors.orange[400]!,
                          Colors.orange[800]!,
                          LeaderboardScreen(),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFancyButton(
      BuildContext context, String text, Color startColor, Color endColor, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        width: 250,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}