import 'package:flutter/material.dart';
import 'compare_screen.dart';
import 'order_screen.dart';
import 'compose_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(title: Text('Leaderboard', style: TextStyle(color: Colors.white)), backgroundColor: Colors.purple),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs: [
                Tab(text: 'Compare Blast'),
                Tab(text: 'Order Rush'),
                Tab(text: 'Number Mix'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLeaderboardSection('Compare Blast', CompareScreen.leaderboard),
                  _buildLeaderboardSection('Order Rush', OrderScreen.leaderboard),
                  _buildLeaderboardSection('Number Mix', ComposeScreen.leaderboard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(String title, List<int> scores) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$title Top Scores', style: TextStyle(fontSize: 35, color: Colors.purple)),
          SizedBox(height: 20),
          if (scores.isEmpty)
            Text('No scores yet!', style: TextStyle(fontSize: 25, color: Colors.purple))
          else
            for (int i = 0; i < scores.length && i < 10; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('${i + 1}. ${scores[i]}', style: TextStyle(fontSize: 25, color: Colors.purple)),
              ),
        ],
      ),
    );
  }
}