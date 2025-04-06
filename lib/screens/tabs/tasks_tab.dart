import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';
import '../../screens/games/number_match_game.dart';
import '../../screens/games/speed_math_game.dart';
import '../../screens/games/pattern_game.dart';
import '../../screens/learning/numbers_basics.dart';
import '../../screens/learning/math_symbols.dart';
import '../../screens/learning/number_quiz.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final List<Task> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalPoints = 0;
  final TaskService _taskService = TaskService();
  String _lastRefreshDate = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeTasks();
    _loadPoints();
  }

  Future<void> _getLastRefreshDate() async {
    if (!mounted) return;

    try {
      final lastRefresh = await _taskService.getLastRefreshDate();

      if (!mounted) return;

      setState(() {
        if (lastRefresh != null) {
          _lastRefreshDate = DateFormat('MMM dd, yyyy').format(lastRefresh);
        } else {
          _lastRefreshDate = 'Not refreshed yet';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _lastRefreshDate = 'Error loading refresh date';
      });
    }
  }

  Future<void> _initializeTasks() async {
    if (!mounted) return;

    try {
      await _taskService.initializeDefaultTasks();
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error initializing tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPoints() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final points = prefs.getInt('totalPoints') ?? 0;

      if (!mounted) return;

      setState(() {
        _totalPoints = points;
      });
    } catch (e) {
      // Silently handle error
      print('Error loading points: $e');
    }
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _taskService.refreshDailyTasks();
      final tasks = await _taskService.getAllTasks();

      if (!mounted) return;

      setState(() {
        _tasks
          ..clear()
          ..addAll(tasks);
        _isLoading = false;
      });

      await _getLastRefreshDate();
      await _loadPoints();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _forceRefreshTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _taskService.forceRefreshTasks();
      await _loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks refreshed successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error refreshing tasks: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToTaskActivity(Task task) async {
    if (task.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This task has already been completed today!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final activityScreen = _getActivityScreen(task.learningActivityType);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => activityScreen),
    );

    await _toggleTaskCompletion(task.id);
  }

  Widget _getActivityScreen(String type) {
    switch (type) {
      case 'numbers':
        return const NumberBasics();
      case 'math_symbols':
        return const MathSymbols();
      case 'number_quiz':
        return const NumberQuiz();
      case 'number_match':
        return const NumberMatchGame();
      case 'speed_math':
        return const SpeedMathGame();
      case 'pattern_game':
        return const PatternGame();
      default:
        return const NumberBasics();
    }
  }

  Future<void> _toggleTaskCompletion(String id) async {
    if (!mounted) return;

    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) return;

    final task = _tasks[taskIndex];

    if (task.isCompleted) {
      _showTaskCompletedSnackBar();
      return;
    }

    try {
      await _taskService.completeTask(id);
      await _loadTasks();

      _showTaskSuccessSnackBar(task.points);
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar('Error completing task: $e');
    }
  }

  void _showTaskCompletedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This task has already been completed today!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTaskSuccessSnackBar(int points) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! You earned $points points!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteTask(String id) async {
    if (!mounted) return;

    try {
      await _taskService.deleteTask(id);
      await _loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar('Error deleting task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildRefreshDateHeader(),
          Expanded(child: _buildTasksList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.deepPurple[700],
      title: const Text('Daily Tasks', style: TextStyle(color: Colors.white)),
      actions: [
        _buildPointsDisplay(),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadTasks,
          tooltip: 'Refresh Tasks',
        ),
      ],
    );
  }

  Widget _buildPointsDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '$_totalPoints',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshDateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        'Tasks refresh daily. Last refresh: $_lastRefreshDate',
        style: const TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTasksList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorView();
    }

    if (_tasks.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _tasks.length,
      itemBuilder: (context, index) => _buildTaskCard(_tasks[index]),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[400],
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No tasks available yet!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 16),
          Text(
            'Tasks refresh daily. Check back tomorrow!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () => _navigateToTaskActivity(task),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: task.isCompleted ? Colors.green[400] : Colors.deepPurple[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskHeader(task),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) _buildTaskDescription(task),
              _buildTaskTime(task),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: task.isCompleted ? Colors.white : Colors.white70,
                    ),
                    onPressed:
                        task.isCompleted
                            ? null
                            : () => _toggleTaskCompletion(task.id),
                  ),
                  // Delete button removed
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(Task task) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        _buildPointsBadge(task.points),
      ],
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.yellow, size: 16),
          const SizedBox(width: 4),
          Text(
            '$points',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDescription(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        task.description,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildTaskTime(Task task) {
    return Text(
      'Time: ${task.timeMinutes} min',
      style: const TextStyle(color: Colors.white70),
    );
  }

  Widget _buildTaskActions(Task task) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            color: task.isCompleted ? Colors.white : Colors.white70,
          ),
          onPressed:
              task.isCompleted ? null : () => _toggleTaskCompletion(task.id),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white70),
          onPressed: () => _deleteTask(task.id),
        ),
      ],
    );
  }
}
