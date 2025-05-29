class Goal {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.createdAt,
    required this.updatedAt,
  });

  // 👇 fromJson
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // 👇 toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy method to update fields easily
  Goal copyWith({
    String? title,
    String? description,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}