// lib/services/task_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Task {
  final String id;
  final String title;
  final int points;
  final String timeLimit;
  bool completed;
  String? lastCompletedDate;

  Task({
    required this.id,
    required this.title,
    required this.points,
    required this.timeLimit,
    this.completed = false,
    this.lastCompletedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
      'timeLimit': timeLimit,
      'completed': completed,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      points: json['points'],
      timeLimit: json['timeLimit'],
      completed: json['completed'],
      lastCompletedDate: json['lastCompletedDate'],
    );
  }
}

class TaskManager {
  static const _tasksKey = 'tasks';

  // Get all tasks
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_tasksKey);

    if (tasksJson == null) {
      // Initial tasks if none exist
      return [
        Task(
          id: '1',
          title: 'Complete Speed Math Game',
          points: 150,
          timeLimit: '10 min',
        ),
        Task(
          id: '2',
          title: 'Learn 5 Math Symbols',
          points: 100,
          timeLimit: '15 min',
        ),
        Task(
          id: '3',
          title: 'Practice Number Basics',
          points: 150,
          timeLimit: '20 min',
        ),
      ];
    }

    List<dynamic> tasksList = jsonDecode(tasksJson);
    return tasksList.map((task) => Task.fromJson(task)).toList();
  }

  // Save tasks
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  // Complete a task
  static Future<void> completeTask(String taskId) async {
    final tasks = await getTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);

    if (taskIndex != -1) {
      tasks[taskIndex].completed = true;
      tasks[taskIndex].lastCompletedDate = DateTime.now().toIso8601String();
      await saveTasks(tasks);
    }
  }

  // Check if tasks should be refreshed (new day)
  static Future<void> checkAndRefreshTasks() async {
    final tasks = await getTasks();
    bool needsRefresh = false;

    for (var task in tasks) {
      if (task.completed && task.lastCompletedDate != null) {
        final lastCompleted = DateTime.parse(task.lastCompletedDate!);
        final now = DateTime.now();

        // Check if it's a new day
        if (lastCompleted.day != now.day ||
            lastCompleted.month != now.month ||
            lastCompleted.year != now.year) {
          task.completed = false;
          task.lastCompletedDate = null;
          needsRefresh = true;
        }
      }
    }

    if (needsRefresh) {
      await saveTasks(tasks);
    }
  }
}
