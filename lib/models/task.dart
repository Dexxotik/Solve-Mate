class Task {
  final String id;
  final String title;
  final String description;
  final int timeMinutes;
  final int points;
  bool isCompleted;
  DateTime? completedAt;
  final String learningActivityType; // Added field for activity type

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.timeMinutes,
    required this.points,
    this.isCompleted = false,
    this.completedAt,
    this.learningActivityType = '', // Default empty string
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timeMinutes': timeMinutes,
      'points': points,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'learningActivityType': learningActivityType,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeMinutes: json['timeMinutes'] ?? 0,
      points: json['points'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      learningActivityType: json['learningActivityType'] ?? '',
    );
  }
}
