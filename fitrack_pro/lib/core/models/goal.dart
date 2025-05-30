class Goal {
  final String id;
  final String userId; // <-- Add this
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId, // <-- Add this
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        userId: json['userId'], // <-- Add this
        title: json['title'],
        description: json['description'],
        targetValue: (json['targetValue'] as num).toDouble(),
        currentValue: (json['currentValue'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId, // <-- Add this
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}