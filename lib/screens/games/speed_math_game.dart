import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

/// A game that challenges users to solve math problems quickly.
///
/// This game generates random math problems and tracks the user's score
/// based on how many problems they solve correctly within a time limit.
class SpeedMathGame extends StatefulWidget {
  const SpeedMathGame({Key? key}) : super(key: key);

  @override
  State<SpeedMathGame> createState() => _SpeedMathGameState();
}

class _SpeedMathGameState extends State<SpeedMathGame> {
  // Game state
  bool _isPlaying = false;
  int _score = 0;
  int _timeLeft = 60; // 60 seconds game
  late Timer _timer;

  // Current problem
  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  late List<int> _answerOptions;

  // User input
  final TextEditingController _answerController = TextEditingController();

  // Random generator
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewProblem();
  }

  @override
  void dispose() {
    // Make sure to cancel the timer when the widget is disposed
    if (_isPlaying) {
      _timer.cancel();
    }
    _answerController.dispose();
    super.dispose();
  }

  /// Starts the game timer and sets the game state to playing.
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _timeLeft = 60;
      _generateNewProblem();
    });

    // Create a timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _endGame();
          }
        });
      }
    });
  }

  /// Ends the game, cancels the timer, and shows the final score.
  void _endGame() {
    if (_isPlaying) {
      _timer.cancel();
      setState(() {
        _isPlaying = false;
      });

      // Show the final score dialog
      if (mounted) {
        _showGameOverDialog();
      }
    }
  }

  /// Generates a new math problem with random numbers and operator.
  void _generateNewProblem() {
    try {
      // Generate random numbers based on difficulty
      // Keep numbers small to make it easier for users with dyscalculia
      _num1 = _random.nextInt(10) + 1; // 1-10
      _num2 = _random.nextInt(10) + 1; // 1-10

      // Choose a random operator (addition, subtraction, or multiplication)
      final operators = ['+', '-', '×'];
      _operator = operators[_random.nextInt(3)];

      // Calculate the correct answer
      switch (_operator) {
        case '+':
          _correctAnswer = _num1 + _num2;
          break;
        case '-':
          // Ensure the result is positive by swapping if needed
          if (_num1 < _num2) {
            final temp = _num1;
            _num1 = _num2;
            _num2 = temp;
          }
          _correctAnswer = _num1 - _num2;
          break;
        case '×':
          _correctAnswer = _num1 * _num2;
          break;
        default:
          _correctAnswer = _num1 + _num2;
      }

      // Generate answer options (including the correct one)
      _generateAnswerOptions();
    } catch (e) {
      print('Error generating problem: $e');
      // Fallback to a simple addition problem
      _num1 = 2;
      _num2 = 3;
      _operator = '+';
      _correctAnswer = 5;
      _answerOptions = [3, 4, 5, 6];
    }
  }

  /// Generates a list of answer options including the correct answer.
  void _generateAnswerOptions() {
    final Set<int> options = {_correctAnswer};

    // Add 3 more unique options
    while (options.length < 4) {
      // Generate a random answer that's close to the correct one
      int randomOffset = _random.nextInt(5) + 1; // 1-5
      if (_random.nextBool())
        randomOffset = -randomOffset; // Make it negative sometimes

      int newOption = _correctAnswer + randomOffset;
      // Ensure the option is positive
      if (newOption > 0) {
        options.add(newOption);
      }
    }

    // Convert to list and shuffle
    _answerOptions = options.toList()..shuffle();
  }

  /// Checks if the selected answer is correct.
  void _checkAnswer(int selectedAnswer) {
    if (!_isPlaying) return;

    if (selectedAnswer == _correctAnswer) {
      // Correct answer
      setState(() {
        _score += 10;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! +10 points'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Wrong answer
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect. The answer was $_correctAnswer'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // Generate a new problem
    setState(() {
      _generateNewProblem();
    });
  }

  /// Shows a dialog when the game is over.
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Game Over!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Time\'s up!'),
                const SizedBox(height: 16),
                Text(
                  'Your Score: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Exit'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle back button press
      onWillPop: () async {
        if (_isPlaying) {
          _endGame();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF5E35B1),
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[700],
          title: const Text(
            'Speed Math Challenge',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_isPlaying) {
                _endGame();
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGameHeader(),
                const SizedBox(height: 24),
                _buildGameContent(),
                const SizedBox(height: 24),
                if (!_isPlaying)
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the game header with score and timer.
  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Score',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Time Left',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$_timeLeft s',
                style: TextStyle(
                  color: _timeLeft <= 10 ? Colors.red : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the main game content with the math problem and answer options.
  Widget _buildGameContent() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPlaying)
              const Text(
                'Solve math problems as quickly as you can!',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              )
            else
              Column(
                children: [
                  // Math problem
                  Text(
                    '$_num1 $_operator $_num2 = ?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Answer options
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children:
                        _answerOptions.map((answer) {
                          return ElevatedButton(
                            onPressed: () => _checkAnswer(answer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.all(16),
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text('$answer'),
                          );
                        }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
