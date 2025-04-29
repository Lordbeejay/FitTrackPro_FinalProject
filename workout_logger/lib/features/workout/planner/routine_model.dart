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

  Routine({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.exercises,
    required this.durationInMinutes,
    required this.associatedGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  // 👇 fromJson
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      daysOfWeek: List<String>.from(json['daysOfWeek']),
      exercises: List<String>.from(json['exercises']),
      durationInMinutes: json['durationInMinutes'],
      associatedGoal: Goal.fromJson(json['associatedGoal']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
    );
  }
}