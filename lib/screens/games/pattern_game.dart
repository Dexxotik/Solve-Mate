import 'package:flutter/material.dart';
import 'dart:math';

class PatternGame extends StatefulWidget {
  const PatternGame({super.key});

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  List<int> pattern = [];
  List<int> userPattern = [];
  int score = 0;
  bool isShowingPattern = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      pattern = [];
      userPattern = [];
      score = 0;
      isGameOver = false;
      addToPattern();
    });
  }

  void addToPattern() {
    setState(() {
      pattern.add(Random().nextInt(4));
      isShowingPattern = true;
      userPattern = [];
    });
    showPattern();
  }

  void showPattern() async {
    for (int i = 0; i < pattern.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        userPattern = [pattern[i]];
      });
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        userPattern = [];
      });
    }
    if (!mounted) return;
    setState(() {
      isShowingPattern = false;
    });
  }

  void onTilePressed(int index) {
    if (isShowingPattern || isGameOver) return;

    setState(() {
      userPattern.add(index);
    });

    if (userPattern.last != pattern[userPattern.length - 1]) {
      setState(() {
        isGameOver = true;
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Game Over!'),
              content: Text('Your score: $score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startNewGame();
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
      );
    } else if (userPattern.length == pattern.length) {
      setState(() {
        score += 10;
      });
      addToPattern();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Pattern Game',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 18,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isShowingPattern ? 'Watch the pattern!' : 'Your turn!',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: List.generate(4, (index) {
                return GestureDetector(
                  onTap: () => onTilePressed(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          userPattern.contains(index)
                              ? Colors.white
                              : Colors.deepPurple[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
