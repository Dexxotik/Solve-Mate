import 'package:shared_preferences/shared_preferences.dart';

class GameService {
  static const String _gamesPlayedKey = 'gamesPlayed';
  static const String _totalPointsKey = 'totalPoints';
  static const String _streakDaysKey = 'streakDays';
  static const String _lastPlayedDateKey = 'lastPlayedDate';

  // Update game statistics
  static Future<void> updateGameStats({required int pointsEarned}) async {
    final prefs = await SharedPreferences.getInstance();

    // Update games played
    final gamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
    await prefs.setInt(_gamesPlayedKey, gamesPlayed + 1);

    // Update total points
    final totalPoints = prefs.getInt(_totalPointsKey) ?? 0;
    await prefs.setInt(_totalPointsKey, totalPoints + pointsEarned);

    // Update streak
    final lastPlayedDate = prefs.getString(_lastPlayedDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastPlayedDate != null) {
      final yesterday =
          DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String()
              .split('T')[0];

      if (lastPlayedDate == yesterday) {
        // Increment streak
        final currentStreak = prefs.getInt(_streakDaysKey) ?? 0;
        await prefs.setInt(_streakDaysKey, currentStreak + 1);
      } else if (lastPlayedDate != today) {
        // Reset streak if not played yesterday
        await prefs.setInt(_streakDaysKey, 1);
      }
    } else {
      // First time playing
      await prefs.setInt(_streakDaysKey, 1);
    }

    // Update last played date
    await prefs.setString(_lastPlayedDateKey, today);
  }

  // Get game statistics
  static Future<Map<String, dynamic>> getGameStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'gamesPlayed': prefs.getInt(_gamesPlayedKey) ?? 0,
      'totalPoints': prefs.getInt(_totalPointsKey) ?? 0,
      'streakDays': prefs.getInt(_streakDaysKey) ?? 0,
    };
  }
}
