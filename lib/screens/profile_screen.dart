import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  int gamesPlayed = 0;
  int tasksDone = 0;
  int totalPoints = 0;
  int streakDays = 0;
  String level = 'Level 5 Explorer';
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
      username = prefs.getString('username') ?? 'User Name';
      gamesPlayed = prefs.getInt('gamesPlayed') ?? 42;
      tasksDone = prefs.getInt('tasksDone') ?? 28;
      totalPoints = prefs.getInt('totalPoints') ?? 750;
      streakDays = prefs.getInt('streakDays') ?? 5;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple[300],
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Username
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Level
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Statistics grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          Icons.games,
                          gamesPlayed.toString(),
                          'Games Played',
                        ),
                        _buildStatCard(
                          Icons.check_circle,
                          tasksDone.toString(),
                          'Tasks Done',
                        ),
                        _buildStatCard(
                          Icons.star,
                          totalPoints.toString(),
                          'Total Points',
                        ),
                        _buildStatCard(
                          Icons.local_fire_department,
                          '$streakDays days',
                          'Streak',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Settings section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Settings toggles
                    _buildSettingToggle(
                      Icons.notifications,
                      'Notifications',
                      notificationsEnabled,
                      (value) {
                        setState(() {
                          notificationsEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingToggle(
                      Icons.volume_up,
                      'Sound Effects',
                      soundEffectsEnabled,
                      (value) {
                        setState(() {
                          soundEffectsEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingToggle(
                      Icons.text_format,
                      'Dyslexia Font',
                      dyslexiaFontEnabled,
                      (value) {
                        setState(() {
                          dyslexiaFontEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingToggle(
                      Icons.contrast,
                      'High Contrast Mode',
                      highContrastEnabled,
                      (value) {
                        setState(() {
                          highContrastEnabled = value;
                          _saveSettings();
                        });
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.deepPurple[200],
          ),
        ],
      ),
    );
  }
}
