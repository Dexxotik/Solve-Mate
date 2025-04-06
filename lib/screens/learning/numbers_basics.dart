import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NumberBasics extends StatefulWidget {
  const NumberBasics({super.key});

  @override
  State<NumberBasics> createState() => _NumberBasicsState();
}

class _NumberBasicsState extends State<NumberBasics> {
  final FlutterTts flutterTts = FlutterTts();
  int currentNumber = 1;
  bool hasCompletedTutorial = false;
  bool showingQuiz = false;
  bool isPlaying = false;

  Map<int, String> numberWords = {
    1: 'one',
    2: 'two',
    3: 'three',
    4: 'four',
    5: 'five',
    6: 'six',
    7: 'seven',
    8: 'eight',
    9: 'nine',
    10: 'ten',
    11: 'eleven',
    12: 'twelve',
    13: 'thirteen',
    14: 'fourteen',
    15: 'fifteen',
  };

  @override
  void initState() {
    super.initState();
    _initTts();
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

  // Use text-to-speech instead of audio files
  Future<void> speakNumber(int number) async {
    if (isPlaying) return;

    try {
      setState(() {
        isPlaying = true;
      });

      // Speak the number word
      String textToSpeak = numberWords[number] ?? number.toString();
      print('Speaking: $textToSpeak');

      await flutterTts.speak(textToSpeak);
    } catch (e) {
      print('Exception in speakNumber: $e');
      setState(() {
        isPlaying = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not play audio')));
    }
  }

  Widget buildNumberDisplay() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$currentNumber',
            style: TextStyle(
              fontSize: 120,
              color: Colors.deepPurple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            numberWords[currentNumber]!,
            style: TextStyle(fontSize: 32, color: Colors.deepPurple[700]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: isPlaying ? null : () => speakNumber(currentNumber),
                icon: Icon(
                  isPlaying ? Icons.volume_up : Icons.volume_up,
                  color: Colors.white,
                ),
                label: Text(
                  isPlaying ? 'Playing...' : 'Listen',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 6,
                  shadowColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text(
          'Learn Numbers',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Let\'s learn numbers together!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            buildNumberDisplay(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentNumber > 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentNumber--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      elevation: 6,
                      shadowColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                const SizedBox(width: 16),
                if (currentNumber < 15)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentNumber++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400],
                      elevation: 6,
                      shadowColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
