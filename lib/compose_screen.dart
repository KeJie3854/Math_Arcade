import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'widgets.dart';

class ComposeScreen extends StatefulWidget {
  static List<int> leaderboard = [];

  @override
  _ComposeScreenState createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  Random random = Random();
  int target = 0;
  List<int> choices = [];
  List<int> picked = [];
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
      ComposeScreen.leaderboard = prefs.getStringList('compose_leaderboard')?.map((e) => int.parse(e)).toList() ?? [];
    });
  }

  void _saveLeaderboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('compose_leaderboard', ComposeScreen.leaderboard.map((e) => e.toString()).toList());
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          showHurryUp = timeLeft <= 5;
        } else {
          timer.cancel();
          message = 'Time\'s Up!';
          _confettiController.stop();
          _showLoseDialog();
        }
      });
    });
  }

  void newNumbers() {
    setState(() {
      int maxTarget = level == 1 ? 20 : (level == 2 ? 50 : 99);
      int maxNumber = level == 1 ? 20 : (level == 2 ? 50 : 99);
      target = random.nextInt(maxTarget - 4) + 5;
      choices = [];
      int part1 = random.nextInt(target - 1) + 1;
      int part2 = target - part1;
      choices.add(part1);
      choices.add(part2);
      int distractor1, distractor2;
      do {
        distractor1 = random.nextInt(maxNumber) + 1;
      } while (distractor1 == part1 || distractor1 == part2 || distractor1 + part1 == target || distractor1 + part2 == target);
      do {
        distractor2 = random.nextInt(maxNumber) + 1;
      } while (distractor2 == part1 || distractor2 == part2 || distractor2 == distractor1 || distractor2 + part1 == target || distractor2 + part2 == target || distractor2 + distractor1 == target);
      choices.add(distractor1);
      choices.add(distractor2);
      choices.shuffle();
      picked = [];
      message = '';
      _confettiController.stop();
      timeLeft = 30;
      showHurryUp = false;
      _timer.cancel();
      startTimer();
    });
  }

  void pickNumber(int num) {
    setState(() {
      if (picked.contains(num)) {
        picked.remove(num);
      } else if (picked.length < 2) {
        picked.add(num);
      }
      if (picked.length == 2) {
        if (picked[0] + picked[1] == target) {
          streak++;
          correctAnswers++;
          if (correctAnswers % 5 == 0 && level < 3) level++;
          int bonus = timeLeft > 20 ? 5 : 0;
          int streakBonus = (streak >= 3) ? 10 : 0;
          score += 10 + bonus + streakBonus;
          message = 'Magic Match! +${10 + bonus + streakBonus} points';
          _confettiController.play();
          _audioPlayer.play(AssetSource('sounds/confetti.mp3'));
        } else {
          message = 'Whoops!';
          _showLoseDialog();
        }
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
          title: Text(message == 'Time\'s Up!' ? 'Time Ran Out!' : 'Mix Mishap!', 
            style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(
            message == 'Time\'s Up!' 
              ? 'Oops, Time\'s Up! Your score was $score.\nMix it up again or bounce?' 
              : 'Yikes, Mix Master! Your score was $score.\nMix it up again or bounce?',
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
      ComposeScreen.leaderboard.add(score);
      ComposeScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (ComposeScreen.leaderboard.length > 10) ComposeScreen.leaderboard = ComposeScreen.leaderboard.sublist(0, 10);
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
      backgroundColor: Colors.blue[100],
      appBar: AppBar(title: Text('Number Mix!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
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
                Text('Make: $target', style: TextStyle(fontSize: 40, color: Colors.purple)),
                SizedBox(height: 20),
                Text('Pick 2 numbers that mix to $target!', style: TextStyle(fontSize: 25, color: Colors.purple)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: choices.map((num) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () => pickNumber(num),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: picked.contains(num) ? Colors.yellow : Colors.blue,
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('$num', style: TextStyle(fontSize: 25, color: Colors.white)),
                    ),
                  )).toList(),
                ),
                SizedBox(height: 20),
                Text('Your Mix: ${picked.join(" and ")}', style: TextStyle(fontSize: 25, color: Colors.purple)),
                SizedBox(height: 20),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: message.startsWith('Magic Match') ? 35 : 30,
                    color: message.startsWith('Magic Match') ? Colors.green : Colors.red,
                  ),
                  child: Text(message),
                ),
                SizedBox(height: 20),
                actionButton('Next Mix!', Colors.blue, newNumbers),
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
              colors: [Colors.blue, Colors.yellow, Colors.red],
            ),
          ),
        ],
      ),
    );
  }
}