class UserStats {
  final int totalWorkouts;
  final int workoutsPerformed;
  final int totalExercises;
  final String? lastWorkoutName;
  final DateTime? lastWorkoutDate;

  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String dateOfBirth;
  final String weight;
  final String height;

  UserStats({
    required this.totalWorkouts,
    required this.workoutsPerformed,
    required this.totalExercises,
    this.lastWorkoutName,
    this.lastWorkoutDate,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['totalWorkouts'] ?? 0,
      workoutsPerformed: json['workoutsPerformed'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      lastWorkoutName: json['lastWorkoutName'],
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.tryParse(json['lastWorkoutDate'])
          : null,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      weight: json['weight'] ?? '',
      height: json['height'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'workoutsPerformed': workoutsPerformed,
      'totalExercises': totalExercises,
      'lastWorkoutName': lastWorkoutName,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'weight': weight,
      'height': height,
    };
  }

  UserStats copyWith({
    int? totalWorkouts,
    int? workoutsPerformed,
    int? totalExercises,
    String? lastWorkoutName,
    DateTime? lastWorkoutDate,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    String? dateOfBirth,
    String? weight,
    String? height,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      workoutsPerformed: workoutsPerformed ?? this.workoutsPerformed,
      totalExercises: totalExercises ?? this.totalExercises,
      lastWorkoutName: lastWorkoutName ?? this.lastWorkoutName,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}