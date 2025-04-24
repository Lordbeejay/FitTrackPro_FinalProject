class UserStats {
  int totalWorkouts;
  int totalExercises;
  int workoutsPerformed;           // Legacy field, you might rename this later
  int totalWorkoutsPerformed;      // New field for actual workout completions
  String? lastWorkoutName;

  UserStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.workoutsPerformed,
    this.totalWorkoutsPerformed = 0,
    this.lastWorkoutName,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      workoutsPerformed: json['workoutsPerformed'] ?? 0,
      totalWorkoutsPerformed: json['totalWorkoutsPerformed'] ?? 0,
      lastWorkoutName: json['lastWorkoutName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'workoutsPerformed': workoutsPerformed,
      'totalWorkoutsPerformed': totalWorkoutsPerformed,
      'lastWorkoutName': lastWorkoutName,
    };
  }
}
