class UserStats {
  int totalWorkouts;
  int totalExercises;
  int workoutsPerformed;
  String? lastWorkoutName;
  DateTime? lastWorkoutDate;

  UserStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.workoutsPerformed,
    this.lastWorkoutName,
    this.lastWorkoutDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      workoutsPerformed: json['workoutsPerformed'] ?? 0,
      lastWorkoutName: json['lastWorkoutName'],
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.tryParse(json['lastWorkoutDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'workoutsPerformed': workoutsPerformed,
      'lastWorkoutName': lastWorkoutName,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    };
  }

  UserStats copyWith({
    int? totalWorkouts,
    int? totalExercises,
    int? workoutsPerformed,
    String? lastWorkoutName,
    DateTime? lastWorkoutDate,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalExercises: totalExercises ?? this.totalExercises,
      workoutsPerformed: workoutsPerformed ?? this.workoutsPerformed,
      lastWorkoutName: lastWorkoutName ?? this.lastWorkoutName,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }
}