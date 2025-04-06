import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/task_service.dart';
import 'services/reward_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final taskService = TaskService();
  final rewardService = RewardService();

  // Initialize tasks and rewards
  await taskService.initializeDefaultTasks();
  await rewardService.initializeDefaultRewards();

  runApp(const SolveMateApp());
}

class SolveMateApp extends StatelessWidget {
  const SolveMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solve Mate',
      theme: ThemeData(
        primaryColor: const Color(0xFF5E35B1),
        scaffoldBackgroundColor: const Color(0xFF5E35B1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E35B1),
          secondary: Colors.white,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkIfLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }

  Future<bool> _checkIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
}
