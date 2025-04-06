import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

class NumberQuiz extends StatefulWidget {
  const NumberQuiz({super.key});

  @override
  State<NumberQuiz> createState() => _NumberQuizState();
}

class _NumberQuizState extends State<NumberQuiz> {
  final FlutterTts flutterTts = FlutterTts();
  final Random random = Random();

  late int correctAnswer;
  late List<int> options;
  bool isPlaying = false;
  bool hasAnswered = false;
  int? selectedAnswer;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _generateNewQuestion();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  // Update the _generateNewQuestion method to have 4 options
  void _generateNewQuestion() {
    // Generate a simple number between 1 and 5 for very basic questions
    correctAnswer = random.nextInt(5) + 1;

    // Create options with the correct answer and 3 other random numbers
    options = [correctAnswer];

    while (options.length < 4) {
      int option = random.nextInt(5) + 1;
      if (!options.contains(option)) {
        options.add(option);
      }
    }

    // Shuffle the options
    options.shuffle();

    // Reset quiz state
    setState(() {
      hasAnswered = false;
      selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Number Quiz',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Which number is this?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Number display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$correctAnswer',
                    style: TextStyle(
                      fontSize: 100,
                      color: Colors.deepPurple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed:
                        isPlaying ? null : () => _speakNumber(correctAnswer),
                    icon: Icon(
                      isPlaying ? Icons.volume_up : Icons.volume_up,
                      color: Colors.white,
                    ),
                    label: Text(isPlaying ? 'Playing...' : 'Listen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Answer options - improved grid layout
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                padding: const EdgeInsets.all(8),
                children:
                    options.map((option) {
                      bool isSelected = selectedAnswer == option;
                      bool showCorrect = hasAnswered && option == correctAnswer;
                      bool showIncorrect =
                          hasAnswered && isSelected && !isCorrect;

                      return GestureDetector(
                        onTap: hasAnswered ? null : () => _checkAnswer(option),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                showCorrect
                                    ? Colors.green[100]
                                    : showIncorrect
                                    ? Colors.red[100]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  showCorrect
                                      ? Colors.green
                                      : showIncorrect
                                      ? Colors.red
                                      : isSelected
                                      ? Colors.blue
                                      : Colors.deepPurple[300]!,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              option.toString(),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[700],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (hasAnswered && !isCorrect)
              ElevatedButton(
                onPressed: _generateNewQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Try Another Question',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakNumber(int number) async {
    if (isPlaying) return;

    try {
      setState(() {
        isPlaying = true;
      });

      // Get the word for the number
      Map<int, String> numberWords = {
        1: 'one',
        2: 'two',
        3: 'three',
        4: 'four',
        5: 'five',
      };

      String textToSpeak = numberWords[number] ?? number.toString();
      await flutterTts.speak(textToSpeak);
    } catch (e) {
      print('Exception in speakNumber: $e');
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _checkAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;
      isCorrect = answer == correctAnswer;
    });

    // Provide audio feedback
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isCorrect) {
        flutterTts.speak("Correct! Well done!");
      } else {
        flutterTts.speak("Let's try again!");
      }
    });

    // Generate a new question after a delay
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 3), () {
        _generateNewQuestion();
      });
    }
  }
}
