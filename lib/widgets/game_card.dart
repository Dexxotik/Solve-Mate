import 'package:flutter/material.dart';
import '../screens/games/number_match_game.dart';
import '../screens/games/speed_math_game.dart';
import '../screens/games/pattern_game.dart';
// Import the learning screens
import '../screens/learning/numbers_basics.dart';
import '../screens/learning/math_symbols.dart';
import '../screens/learning/number_quiz.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  Widget _getGameScreen(String title) {
    switch (title) {
      case 'Learn Numbers':
        return const NumberBasics();
      case 'Math Symbols':
        return const MathSymbols();
      case 'Number Quiz':
        return const NumberQuiz();
      case 'Number Match':
        return const NumberMatchGame();
      case 'Speed Math':
        return const SpeedMathGame();
      case 'Pattern Game':
        return const PatternGame();
      default:
        return const NumberMatchGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => _getGameScreen(title)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
