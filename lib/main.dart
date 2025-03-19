import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(MathArcade());
}

class MathArcade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Arcade',
      theme: ThemeData(fontFamily: 'Comic Sans MS'), // Optional font
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

// Compare Blast Screen (Unchanged)
class CompareScreen extends StatefulWidget {
  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Random random = Random();
  int num1 = 0, num2 = 0;
  String message = '';
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    newNumbers();
  }

  void newNumbers() {
    setState(() {
      num1 = random.nextInt(99) + 1; // 1-99
      num2 = random.nextInt(99) + 1;
      if (num1 == num2) num2 = random.nextInt(99) + 1;
      message = '';
      _confettiController.stop();
    });
  }

  void check(String guess) {
    setState(() {
      bool correct = (guess == 'bigger' && num1 > num2) || (guess == 'smaller' && num1 < num2);
      message = correct ? 'Super Star!' : 'Oops, Try Again!';
      if (correct) _confettiController.play();
    });
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
                    fontSize: message == 'Super Star!' ? 35 : 30,
                    color: message == 'Super Star!' ? Colors.green : Colors.red,
                  ),
                  child: Text(message),
                ),
                SizedBox(height: 30),
                _actionButton('Next Level', Colors.blue, newNumbers),
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

// Order Rush Screen (Updated UI for Clarity)
class OrderScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    newNumbers();
  }

  void newNumbers() {
    setState(() {
      numbers = [];
      while (numbers.length < 3) {
        int num = random.nextInt(99) + 1; // 1-99
        if (!numbers.contains(num)) numbers.add(num);
      }
      userOrder = [];
      isAscending = random.nextBool(); // Randomly ascending or descending
      message = '';
      _confettiController.stop();
    });
  }

  void tapNumber(int num) {
    setState(() {
      if (userOrder.contains(num)) {
        userOrder.remove(num);
        print('Removed $num. New order: $userOrder'); // Debug
      } else if (userOrder.length < 3) {
        userOrder.add(num);
        print('Added $num. New order: $userOrder'); // Debug
      }
    });
  }

  void checkOrder() {
    List<int> correctOrder = List.from(numbers);
    correctOrder.sort(isAscending ? null : (a, b) => b.compareTo(a));
    setState(() {
      message = userOrder.toString() == correctOrder.toString() ? 'You Rock!' : 'Mix-Up!';
      if (message == 'You Rock!') _confettiController.play();
    });
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
                    fontSize: message == 'You Rock!' ? 35 : 30,
                    color: message == 'You Rock!' ? Colors.yellow : Colors.red,
                  ),
                  child: Text(message),
                ),
                SizedBox(height: 20),
                _actionButton('Next Round', Colors.blue, newNumbers),
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

// Number Mix Screen (Unchanged)
class ComposeScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    newNumbers();
  }

  void newNumbers() {
    setState(() {
      target = random.nextInt(20) + 5; // 5-24, easy for kids
      choices = [];
      int part1 = random.nextInt(target - 1) + 1;
      int part2 = target - part1;
      choices.addAll([part1, part2, random.nextInt(20) + 1, random.nextInt(20) + 1]);
      choices.shuffle();
      picked = [];
      message = '';
      _confettiController.stop();
    });
  }

  void pickNumber(int num) {
    setState(() {
      if (!picked.contains(num) && picked.length < 2) {
        picked.add(num);
      }
      if (picked.length == 2) {
        message = (picked[0] + picked[1] == target) ? 'Magic Match!' : 'Whoops!';
        if (message == 'Magic Match!') _confettiController.play();
      }
    });
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
                    fontSize: message == 'Magic Match!' ? 35 : 30,
                    color: message == 'Magic Match!' ? Colors.green : Colors.red,
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