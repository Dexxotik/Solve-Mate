import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';
  static const String _lastRefreshKey = 'last_refresh_date';
  static const String _pointsKey = 'totalPoints';
  static const String _tasksDoneKey = 'tasksDone';

  // Get default tasks
  List<Task> _getDefaultTasks() {
    return [
      Task(
        id: '1',
        title: 'Learn Number Basics',
        description: 'Learn the basics of numbers and counting',
        timeMinutes: 10,
        points: 100,
        learningActivityType: 'numbers',
      ),
      Task(
        id: '2',
        title: 'Practice Math Symbols',
        description: 'Learn and practice basic math symbols',
        timeMinutes: 15,
        points: 100,
        learningActivityType: 'math_symbols',
      ),
      Task(
        id: '3',
        title: 'Complete Number Quiz',
        description: 'Test your knowledge with a number quiz',
        timeMinutes: 20,
        points: 100,
        learningActivityType: 'number_quiz',
      ),
      Task(
        id: '4',
        title: 'Play Number Match Game',
        description: 'Match pairs of numbers to improve memory',
        timeMinutes: 15,
        points: 120,
        learningActivityType: 'number_match',
      ),
      Task(
        id: '5',
        title: 'Try Speed Math Challenge',
        description: 'Solve math problems quickly to earn points',
        timeMinutes: 10,
        points: 150,
        learningActivityType: 'speed_math',
      ),
    ];
  }

  // Initialize default tasks if they don't exist
  Future<void> initializeDefaultTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey);

    if (tasksJson == null || tasksJson.isEmpty) {
      await _saveTasks(_getDefaultTasks());
      await _updateLastRefreshDate();
      print('Default tasks initialized');
    }
  }

  // Check if tasks should be refreshed (once per day)
  Future<bool> _shouldRefreshTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastRefreshStr = prefs.getString(_lastRefreshKey);

    if (lastRefreshStr == null) {
      // First time, save current date and return true
      await _updateLastRefreshDate();
      return true;
    }

    DateTime lastRefresh = DateTime.parse(lastRefreshStr);
    DateTime now = DateTime.now();

    // Check if it's a new day (comparing date parts only)
    bool isNewDay =
        lastRefresh.year != now.year ||
        lastRefresh.month != now.month ||
        lastRefresh.day != now.day;

    if (isNewDay) {
      await _updateLastRefreshDate();
      return true;
    }

    return false;
  }

  // Update the last refresh date to now
  Future<void> _updateLastRefreshDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRefreshKey, DateTime.now().toIso8601String());
  }

  // Refresh daily tasks if needed
  Future<void> refreshDailyTasks() async {
    bool shouldRefresh = await _shouldRefreshTasks();
    if (shouldRefresh) {
      await _resetTasks();
    }
  }

  // Force refresh tasks (for testing)
  Future<void> forceRefreshTasks() async {
    await _resetTasks();
    await _updateLastRefreshDate();
  }

  // Reset tasks to uncompleted state
  Future<void> _resetTasks() async {
    List<Task> currentTasks = await getAllTasks();
    List<Task> resetTasks = _getDefaultTasks();

    // If user has custom tasks, preserve them but reset completion status
    if (currentTasks.isNotEmpty) {
      for (var task in currentTasks) {
        task.isCompleted = false;
        task.completedAt = null;
      }
      await _saveTasks(currentTasks);
    } else {
      await _saveTasks(resetTasks);
    }
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we need to refresh tasks
    await refreshDailyTasks();

    // Get the current tasks
    List<String>? tasksJson = prefs.getStringList(_tasksKey);
    if (tasksJson == null || tasksJson.isEmpty) {
      // First time app is run, save default tasks
      final defaultTasks = _getDefaultTasks();
      await _saveTasks(defaultTasks);
      return defaultTasks;
    }

    // Parse tasks from JSON
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskJsons =
        tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, taskJsons);
  }

  // Mark a task as completed
  Future<void> completeTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList(_tasksKey);

    if (tasksJson == null || tasksJson.isEmpty) {
      return;
    }

    List<Task> tasks =
        tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);

    if (taskIndex != -1) {
      Task task = tasks[taskIndex];

      // Only complete if not already completed
      if (!task.isCompleted) {
        task.isCompleted = true;
        task.completedAt = DateTime.now();

        // Update tasks done count
        int tasksDone = prefs.getInt(_tasksDoneKey) ?? 0;
        await prefs.setInt(_tasksDoneKey, tasksDone + 1);

        // Add points
        int currentPoints = prefs.getInt(_pointsKey) ?? 0;
        await prefs.setInt(_pointsKey, currentPoints + task.points);

        // Save updated tasks
        await _saveTasks(tasks);
      }
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList(_tasksKey);

    if (tasksJson == null || tasksJson.isEmpty) {
      return;
    }

    List<Task> tasks =
        tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    tasks.removeWhere((task) => task.id == taskId);

    // Save updated tasks
    await _saveTasks(tasks);
  }

  // Get the last refresh date
  Future<DateTime?> getLastRefreshDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastRefreshStr = prefs.getString(_lastRefreshKey);

    if (lastRefreshStr != null) {
      return DateTime.parse(lastRefreshStr);
    }
    return null;
  }

  // Get reward points
  Future<int> getRewardPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }
}
