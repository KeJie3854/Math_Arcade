import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Compare Blast Screen
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
  int score = 0;
  int streak = 0;
  int timeLeft = 30;
  late Timer _timer;
  bool showHurryUp = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
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
          message = 'Time’s Up!';
          _confettiController.stop();
          endSession();
        }
      });
    });
  }

  void newNumbers() {
    setState(() {
      num1 = random.nextInt(99) + 1;
      num2 = random.nextInt(99) + 1;
      if (num1 == num2) num2 = random.nextInt(99) + 1;
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
        int bonus = timeLeft > 20 ? 5 : 0;
        int streakBonus = (streak >= 3) ? 10 : 0;
        score += 10 + bonus + streakBonus;
        message = 'Super Star! +${10 + bonus + streakBonus} points';
        _confettiController.play();
      } else {
        message = 'Oops, Try Again!';
        endSession();
      }
    });
  }

  void endSession() {
    if (score > 0) {
      CompareScreen.leaderboard.add(score);
      CompareScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (CompareScreen.leaderboard.length > 5) CompareScreen.leaderboard = CompareScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    score = 0;
    streak = 0;
    newNumbers();
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
              onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
              child: Text('No', style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                endGame(); // Proceed with ending
              },
              child: Text('Yes', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  void endGame() {
    _timer.cancel();
    if (score > 0) {
      CompareScreen.leaderboard.add(score);
      CompareScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (CompareScreen.leaderboard.length > 5) CompareScreen.leaderboard = CompareScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
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
                Text('Score: $score | Streak: $streak', style: TextStyle(fontSize: 25, color: Colors.purple)),
                SizedBox(height: 10),
                Text('Time: $timeLeft s', style: TextStyle(fontSize: 25, color: timeLeft <= 5 ? Colors.red : Colors.purple)),
                if (showHurryUp)
                  Text('Hurry Up!', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Number 1: $num1', style: TextStyle(fontSize: 40, color: Colors.purple)),
                Text('Number 2: $num2', style: TextStyle(fontSize: 40, color: Colors.purple)),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton('Number 1 is Bigger', Colors.red, () => check('bigger')),
                    SizedBox(width: 20),
                    _actionButton('Number 2 is Bigger', Colors.red, () => check('smaller')),
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
                _actionButton('Next Level', Colors.blue, newNumbers),
                SizedBox(height: 40), // Extra spacing
                _actionButton('End Game', Colors.grey, _showEndGameConfirmation),
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

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: TextStyle(fontSize: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}

// Order Rush Screen
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
          endSession();
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
      } else {
        message = 'Mix-Up!';
        endSession();
      }
    });
  }

  void endSession() {
    if (score > 0) {
      OrderScreen.leaderboard.add(score);
      OrderScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (OrderScreen.leaderboard.length > 5) OrderScreen.leaderboard = OrderScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    score = 0;
    streak = 0;
    newNumbers();
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
              onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
              child: Text('No', style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                endGame(); // Proceed with ending
              },
              child: Text('Yes', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
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

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
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
                  _actionButton('Check It!', Colors.green, checkOrder),
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
                _actionButton('Next Round', Colors.blue, newNumbers),
                SizedBox(height: 40), // Extra spacing
                _actionButton('End Game', Colors.grey, _showEndGameConfirmation),
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

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: TextStyle(fontSize: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}

// Number Mix Screen
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
  int score = 0;
  int streak = 0;
  int timeLeft = 30;
  late Timer _timer;
  bool showHurryUp = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
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
          message = 'Time’s Up!';
          _confettiController.stop();
          endSession();
        }
      });
    });
  }

  void newNumbers() {
    setState(() {
      target = random.nextInt(20) + 5;
      choices = [];
      int part1 = random.nextInt(target - 1) + 1;
      int part2 = target - part1;
      choices.add(part1);
      choices.add(part2);
      int distractor1, distractor2;
      do {
        distractor1 = random.nextInt(20) + 1;
      } while (distractor1 == part1 || distractor1 == part2 || distractor1 + part1 == target || distractor1 + part2 == target);
      do {
        distractor2 = random.nextInt(20) + 1;
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
          int bonus = timeLeft > 20 ? 5 : 0;
          int streakBonus = (streak >= 3) ? 10 : 0;
          score += 10 + bonus + streakBonus;
          message = 'Magic Match! +${10 + bonus + streakBonus} points';
          _confettiController.play();
        } else {
          message = 'Whoops!';
          endSession();
        }
      }
    });
  }

  void endSession() {
    if (score > 0) {
      ComposeScreen.leaderboard.add(score);
      ComposeScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (ComposeScreen.leaderboard.length > 5) ComposeScreen.leaderboard = ComposeScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    score = 0;
    streak = 0;
    newNumbers();
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
              onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
              child: Text('No', style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                endGame(); // Proceed with ending
              },
              child: Text('Yes', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  void endGame() {
    _timer.cancel();
    if (score > 0) {
      ComposeScreen.leaderboard.add(score);
      ComposeScreen.leaderboard.sort((a, b) => b.compareTo(a));
      if (ComposeScreen.leaderboard.length > 5) ComposeScreen.leaderboard = ComposeScreen.leaderboard.sublist(0, 5);
      _saveLeaderboard();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
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
                Text('Score: $score | Streak: $streak', style: TextStyle(fontSize: 25, color: Colors.purple)),
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
                ElevatedButton(
                  onPressed: newNumbers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('Next Mix!', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 40), // Extra spacing
                ElevatedButton(
                  onPressed: _showEndGameConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('End Game', style: TextStyle(color: Colors.white)),
                ),
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

// Leaderboard Screen
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
            for (int i = 0; i < scores.length && i < 5; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('${i + 1}. ${scores[i]}', style: TextStyle(fontSize: 30, color: Colors.purple)),
              ),
        ],
      ),
    );
  }
}