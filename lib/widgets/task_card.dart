import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String) onTaskCompleted;
  final Function(String) onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTaskCompleted,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.green[400] : Colors.deepPurple[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time: ${task.timeMinutes} min',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${task.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!task.isCompleted)
                IconButton(
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  onPressed: () => onTaskCompleted(task.id),
                  tooltip: 'Mark as completed',
                ),
              if (task.isCompleted)
                const Icon(Icons.check_circle, color: Colors.white),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white70),
                onPressed: () => onDelete(task.id),
                tooltip: 'Delete task',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
