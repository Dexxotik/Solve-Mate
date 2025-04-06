import 'package:flutter/material.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/settings_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String username = '';
  int gamesPlayed = 0;
  int tasksDone = 0;
  int totalPoints = 0;
  int streakDays = 0;
  bool isLoading = true;

  // Settings toggles
  bool notificationsEnabled = true;
  bool soundEffectsEnabled = true;
  bool dyslexiaFontEnabled = false;
  bool highContrastEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      gamesPlayed = prefs.getInt('gamesPlayed') ?? 0;
      tasksDone = prefs.getInt('tasksDone') ?? 0;
      totalPoints = prefs.getInt('totalPoints') ?? 0;
      streakDays = prefs.getInt('streakDays') ?? 0;

      // Load settings
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      soundEffectsEnabled = prefs.getBool('soundEffects') ?? true;
      dyslexiaFontEnabled = prefs.getBool('dyslexiaFont') ?? false;
      highContrastEnabled = prefs.getBool('highContrast') ?? false;

      isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', notificationsEnabled);
    await prefs.setBool('soundEffects', soundEffectsEnabled);
    await prefs.setBool('dyslexiaFont', dyslexiaFontEnabled);
    await prefs.setBool('highContrast', highContrastEnabled);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _calculateLevel() {
    if (totalPoints < 100) return 'Beginner';
    if (totalPoints < 500) return 'Explorer';
    if (totalPoints < 1000) return 'Master';
    return 'Champion';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple[400],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _calculateLevel(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Games Played',
                    value: gamesPlayed.toString(),
                    icon: Icons.gamepad,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Tasks Done',
                    value: tasksDone.toString(),
                    icon: Icons.task_alt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Points',
                    value: totalPoints.toString(),
                    icon: Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Streak',
                    value: '$streakDays days',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                    _saveSettings();
                  });
                },
                secondary: const Icon(Icons.notifications, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Sound Effects',
                  style: TextStyle(color: Colors.white),
                ),
                value: soundEffectsEnabled,
                onChanged: (value) {
                  setState(() {
                    soundEffectsEnabled = value;
                    _saveSettings();
                  });
                },
                secondary: const Icon(Icons.volume_up, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Dyslexia Font',
                  style: TextStyle(color: Colors.white),
                ),
                value: dyslexiaFontEnabled,
                onChanged: (value) {
                  setState(() {
                    dyslexiaFontEnabled = value;
                    _saveSettings();
                  });
                },
                secondary: const Icon(Icons.text_fields, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'High Contrast Mode',
                  style: TextStyle(color: Colors.white),
                ),
                value: highContrastEnabled,
                onChanged: (value) {
                  setState(() {
                    highContrastEnabled = value;
                    _saveSettings();
                  });
                },
                secondary: const Icon(Icons.contrast, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
