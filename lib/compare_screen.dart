import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets.dart';

class CompareScreen extends StatefulWidget {
  static List<int> leaderboard = [];

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Random random = Random();
  int num1 = 0, num2 = 0;
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
      CompareScreen.leaderboard = prefs.getStringList('compare_leaderboard')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  void _saveLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('compare_leaderboard', CompareScreen.leaderboard.map((e) => e.toString()).toList());
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          showHurryUp = timeLeft <= 5;
        } else {
          timer.cancel();
          message = "Time's Up!";
          _confettiController.stop();
          _showLoseDialog();
        }
      });
    });
  }

  void newNumbers() {
    setState(() {
      int maxNumber = level == 1 ? 20 : (level == 2 ? 50 : 99);
      num1 = random.nextInt(maxNumber) + 1;
      num2 = random.nextInt(maxNumber) + 1;
      if (num1 == num2) num2 = random.nextInt(maxNumber) + 1;
      message = '';
      _confettiController.stop();
      timeLeft = 30;
      showHurryUp = false;
      _timer.cancel();
      startTimer();
    });
  }

  void check(String guess) {
    setState(() {
      bool correct = (guess == 'bigger' && num1 > num2) || (guess == 'smaller' && num1 < num2);
      if (correct) {
        streak++;
        correctAnswers++;
        if (correctAnswers % 5 == 0 && level < 3) level++;
        int bonus = timeLeft > 20 ? 5 : 0;
        int streakBonus = (streak >= 3) ? 10 : 0;
        score += 10 + bonus + streakBonus;
        message = 'Super Star! +${10 + bonus + streakBonus} points';
        _confettiController.play();
        _audioPlayer.play(AssetSource('sounds/confetti.mp3'));
      } else {
        message = 'Oops, Try Again!';
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
          title: Text(message == "Time's Up!" ? 'Time Ran Out!' : 'Oh Snap!', 
            style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(
            message == "Time's Up!" 
              ? 'Oops, Time\'s Up! Your score was $score.\nWant to try again or head back?' 
              : 'Wrong Answer, Math Wizard! Your score was $score.\nWant to bounce back or bail?',
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
      CompareScreen.leaderboard.add(score);
      CompareScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (CompareScreen.leaderboard.length > 10) CompareScreen.leaderboard = CompareScreen.leaderboard.sublist(0, 10);
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
      backgroundColor: Colors.orange[100],
      appBar: AppBar(title: Text('Compare Blast!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
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
                Text('Pick the Bigger Number!', style: TextStyle(fontSize: 30, color: Colors.purple, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Number 1: $num1', style: TextStyle(fontSize: 40, color: Colors.purple)),
                Text('Number 2: $num2', style: TextStyle(fontSize: 40, color: Colors.purple)),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    actionButton('Number 1', Colors.red, () => check('bigger')),
                    SizedBox(width: 20),
                    actionButton('Number 2', Colors.red, () => check('smaller')),
                  ],
                ),
                SizedBox(height: 30),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: message.startsWith('Super Star') ? 35 : 30,
                    color: message.startsWith('Super Star') ? Colors.green : Colors.red,
                  ),
                  child: Text(message),
                ),
                SizedBox(height: 30),
                actionButton('Next Level', Colors.blue, newNumbers),
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
              colors: [Colors.red, Colors.blue, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }
}