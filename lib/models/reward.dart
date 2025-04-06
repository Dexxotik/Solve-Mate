class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final bool isClaimed;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    this.isClaimed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'isClaimed': isClaimed,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      pointsCost: map['pointsCost'],
      isClaimed: map['isClaimed'] ?? false,
    );
  }

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsCost,
    bool? isClaimed,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsCost: pointsCost ?? this.pointsCost,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
