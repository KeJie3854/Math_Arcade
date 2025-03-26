import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets.dart';

class OrderScreen extends StatefulWidget {
  static List<int> leaderboard = [];

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Random random = Random();
  List<int> numbers = [];
  List<int> userOrder = [];
  bool isAscending = true;
  String message = '';
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  int score = 0;
  int streak = 0;
  int timeLeft = 30;
  late Timer _timer;
  bool showHurryUp = false;
  int level = 1;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _loadLeaderboard();
    startTimer();
    newNumbers();
  }

  void _loadLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      OrderScreen.leaderboard = prefs.getStringList('order_leaderboard')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  void _saveLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('order_leaderboard', OrderScreen.leaderboard.map((e) => e.toString()).toList());
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          showHurryUp = timeLeft <= 5;
        } else {
          timer.cancel();
          message = 'Time’s Up!';
          _confettiController.stop();
          _showLoseDialog();
        }
      });
    });
  }

  void newNumbers() {
    setState(() {
      numbers = [];
      int range = level == 1 ? 20 : (level == 2 ? 50 : 99);
      while (numbers.length < 3) {
        int num = random.nextInt(range) + 1;
        if (!numbers.contains(num)) numbers.add(num);
      }
      userOrder = [];
      isAscending = random.nextBool();
      message = '';
      _confettiController.stop();
      timeLeft = 30;
      showHurryUp = false;
      _timer.cancel();
      startTimer();
    });
  }

  void tapNumber(int num) {
    setState(() {
      if (userOrder.contains(num)) {
        userOrder.remove(num);
      } else if (userOrder.length < 3) {
        userOrder.add(num);
      }
    });
  }

  void checkOrder() {
    List<int> correctOrder = List.from(numbers);
    correctOrder.sort(isAscending ? null : (a, b) => b.compareTo(a));
    setState(() {
      if (userOrder.toString() == correctOrder.toString()) {
        streak++;
        correctAnswers++;
        if (correctAnswers % 5 == 0 && level < 3) level++;
        int bonus = timeLeft > 20 ? 5 : 0;
        int streakBonus = (streak >= 3) ? 10 : 0;
        score += 10 + bonus + streakBonus;
        message = 'You Rock! +${10 + bonus + streakBonus} points';
        _confettiController.play();
        _audioPlayer.play(AssetSource('sounds/confetti.mp3'));
      } else {
        message = 'Mix-Up!';
        _showLoseDialog();
      }
    });
  }

  void _showLoseDialog() {
    _audioPlayer.play(AssetSource('sounds/lose.mp3'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Chaos!', style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(
            'Oops, Number Ninja! Your score was $score.\nReady to reorder or retreat?',
            style: TextStyle(fontSize: 20, color: Colors.purple),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveScoreAndReset();
              },
              child: Text('Try Again', style: TextStyle(fontSize: 18, color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                endGame();
              },
              child: Text('Back to Menu', style: TextStyle(fontSize: 18, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _saveScoreAndReset() {
    setState(() {
      score = 0;
      streak = 0;
      level = 1;
      correctAnswers = 0;
    });
    newNumbers();
  }

  void endGame() {
    _timer.cancel();
    if (score > 0) {
      OrderScreen.leaderboard.add(score);
      OrderScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (OrderScreen.leaderboard.length > 5) OrderScreen.leaderboard = OrderScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    Navigator.pop(context);
  }

  void _showEndGameConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('End Game?'),
          content: Text('Are you sure you want to end the game? Your score will be saved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                endGame();
              },
              child: Text('Yes', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(title: Text('Order Rush!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Level: $level | Score: $score | Streak: $streak', style: TextStyle(fontSize: 25, color: Colors.purple)),
                SizedBox(height: 10),
                Text('Time: $timeLeft s', style: TextStyle(fontSize: 25, color: timeLeft <= 5 ? Colors.red : Colors.purple)),
                if (showHurryUp)
                  Text('Hurry Up!', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(
                  'Your Order: ${userOrder.isEmpty ? "Start tapping!" : userOrder.join(", ")}',
                  style: TextStyle(fontSize: 30, color: Colors.purple),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 40,
                      color: isAscending ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isAscending ? 'Small to Big!' : 'Big to Small!',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: isAscending ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: numbers.map((num) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () => tapNumber(num),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userOrder.contains(num) ? Colors.grey : Colors.purple,
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('$num', style: TextStyle(fontSize: 30, color: Colors.white)),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 30),
                if (userOrder.length == 3)
                  actionButton('Check It!', Colors.green, checkOrder),
                SizedBox(height: 20),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: message.startsWith('You Rock') ? 35 : 30,
                    color: message.startsWith('You Rock') ? Colors.yellow : Colors.red,
                  ),
                  child: Text(message),
                ),
                SizedBox(height: 20),
                actionButton('Next Round', Colors.blue, newNumbers),
                SizedBox(height: 40),
                actionButton('End Game', Colors.grey, _showEndGameConfirmation),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [Colors.green, Colors.yellow, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}