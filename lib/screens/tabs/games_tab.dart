import 'package:flutter/material.dart';
import '../../widgets/game_card.dart';
import '../learning/numbers_basics.dart';
import '../learning/number_quiz.dart';
import '../learning/math_symbols.dart';

class GamesTab extends StatelessWidget {
  const GamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Games & Learning',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Number Learning Games First
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NumberBasics()),
                );
              },
              child: const GameCard(
                title: 'Learn Numbers',
                description: 'Learn numbers 1-15 with fun activities',
                icon: Icons.looks_one_rounded,
              ),
            ),

            // Quiz Second
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NumberQuiz()),
                );
              },
              child: const GameCard(
                title: 'Number Quiz',
                description: 'Test your number knowledge',
                icon: Icons.quiz,
              ),
            ),

            // Math Symbols (Learning)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MathSymbols()),
                );
              },
              child: const GameCard(
                title: 'Math Symbols',
                description: 'Learn basic math symbols',
                icon: Icons.calculate,
              ),
            ),

            // Other Games
            const GameCard(
              title: 'Number Match',
              description: 'Match pairs of numbers',
              icon: Icons.grid_on,
            ),
            const GameCard(
              title: 'Speed Math',
              description: 'Solve math problems quickly',
              icon: Icons.speed,
            ),
            const GameCard(
              title: 'Pattern Game',
              description: 'Remember and repeat patterns',
              icon: Icons.psychology,
            ),
          ],
        ),
      ),
    );
  }
}
