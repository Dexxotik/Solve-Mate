import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MathSymbols extends StatefulWidget {
  const MathSymbols({super.key});

  @override
  State<MathSymbols> createState() => _MathSymbolsState();
}

class _MathSymbolsState extends State<MathSymbols> {
  final FlutterTts flutterTts = FlutterTts();
  int currentSymbolIndex = 0;
  bool isPlaying = false;

  final List<Map<String, dynamic>> symbols = [
    {'symbol': '+', 'name': 'Plus', 'description': 'Used for addition'},
    {'symbol': '-', 'name': 'Minus', 'description': 'Used for subtraction'},
    {
      'symbol': '×',
      'name': 'Multiply',
      'description': 'Used for multiplication',
    },
    {'symbol': '÷', 'name': 'Divide', 'description': 'Used for division'},
    {
      'symbol': '=',
      'name': 'Equals',
      'description': 'Shows that values are the same',
    },
    {
      'symbol': '<',
      'name': 'Less than',
      'description': 'Shows left value is smaller',
    },
    {
      'symbol': '>',
      'name': 'Greater than',
      'description': 'Shows left value is larger',
    },
  ];

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

  // Use text-to-speech to speak the symbol name
  Future<void> speakSymbol(int index) async {
    if (isPlaying) return;

    try {
      setState(() {
        isPlaying = true;
      });

      // Speak the symbol name
      String textToSpeak = symbols[index]['name'];
      print('Speaking: $textToSpeak');

      await flutterTts.speak(textToSpeak);
    } catch (e) {
      print('Exception in speakSymbol: $e');
      setState(() {
        isPlaying = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not play audio')));
    }
  }

  Widget buildSymbolDisplay() {
    final symbol = symbols[currentSymbolIndex];

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
            symbol['symbol'],
            style: TextStyle(
              fontSize: 120,
              color: Colors.deepPurple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            symbol['name'],
            style: TextStyle(fontSize: 32, color: Colors.deepPurple[700]),
          ),
          const SizedBox(height: 8),
          Text(
            symbol['description'],
            style: TextStyle(fontSize: 18, color: Colors.deepPurple[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed:
                    isPlaying ? null : () => speakSymbol(currentSymbolIndex),
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
          'Math Symbols',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Let\'s learn math symbols!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            buildSymbolDisplay(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentSymbolIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentSymbolIndex--;
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
                if (currentSymbolIndex < symbols.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentSymbolIndex++;
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
