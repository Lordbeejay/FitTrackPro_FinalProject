import 'package:workout_logger/core/models/goal.dart';

class Routine {
  final String id;
  final String name;
  final List<String> daysOfWeek;
  final List<String> exercises;
  final int durationInMinutes;
  final Goal associatedGoal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime scheduledDate;
  final String difficulty;

  Routine({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.exercises,
    required this.durationInMinutes,
    required this.associatedGoal,
    required this.createdAt,
    required this.updatedAt,
    required this.scheduledDate,
    required this.difficulty,
  });

  // 👇 fromJson
  factory Routine.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.parse(value.toString());
    }

    return Routine(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      daysOfWeek:
          (json['daysOfWeek'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      exercises:
          (json['exercises'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      durationInMinutes: json['durationInMinutes'] ?? 0,
      associatedGoal: Goal.fromJson(json['associatedGoal']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      scheduledDate: parseDate(json['scheduledDate']),
      difficulty: json['difficulty'] ?? 'Beginner',
    );
  }

  // 👇 toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'daysOfWeek': daysOfWeek,
      'exercises': exercises,
      'durationInMinutes': durationInMinutes,
      'associatedGoal': associatedGoal.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'difficulty': difficulty,
    };
  }

  // Copy method to update fields easily
  Routine copyWith({
    String? name,
    List<String>? daysOfWeek,
    List<String>? exercises,
    int? durationInMinutes,
    Goal? associatedGoal,
    DateTime? updatedAt,
    DateTime? scheduledDate,
    String? difficulty,
  }) {
    return Routine(
      id: id,
      name: name ?? this.name,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      exercises: exercises ?? this.exercises,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      associatedGoal: associatedGoal ?? this.associatedGoal,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}