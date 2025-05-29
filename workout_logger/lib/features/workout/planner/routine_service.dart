import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_logger/features/workout/planner/routine_model.dart';
import 'package:workout_logger/core/models/goal.dart';

class RoutineService with ChangeNotifier {
  final List<Routine> _routines = [];
  late File _routinesFile;

  RoutineService() {
    _init();
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _routinesFile = File('${dir.path}/routines.json');

    if (await _routinesFile.exists()) {
      final content = await _routinesFile.readAsString();
      final List<dynamic> decoded = json.decode(content);
      _routines.clear();
      _routines.addAll(decoded.map((e) => Routine.fromJson(e)));
    } else {
      await _routinesFile.create();
      await _routinesFile.writeAsString(json.encode([]));
    }
    notifyListeners();
  }

  List<Routine> getRoutines() => _routines;

  Routine createRoutine(
      String name,
      List<String> daysOfWeek,
      List<String> exercises,
      int durationInMinutes,
      Goal associatedGoal,
      DateTime scheduledDate,
      String difficulty,
      ) {
    final routine = Routine(
      id: const Uuid().v4(),
      name: name,
      daysOfWeek: daysOfWeek.map((day) => day.trim()).toList(),
      exercises: exercises.map((exercise) => exercise.trim()).toList(),
      durationInMinutes: durationInMinutes,
      associatedGoal: associatedGoal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      scheduledDate: scheduledDate,
      difficulty: difficulty,
    );
    _routines.add(routine);
    _saveRoutines();
    notifyListeners();
    return routine;
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((routine) => routine.id == id);
    _saveRoutines();
    notifyListeners();
  }

  void updateRoutine(
      String id, {
        String? newName,
        List<String>? newDaysOfWeek,
        List<String>? newExercises,
        int? newDurationInMinutes,
        Goal? newAssociatedGoal,
      }) {
    final index = _routines.indexWhere((routine) => routine.id == id);
    if (index != -1) {
      final oldRoutine = _routines[index];
      _routines[index] = oldRoutine.copyWith(
        name: newName ?? oldRoutine.name,
        daysOfWeek: newDaysOfWeek ?? oldRoutine.daysOfWeek,
        exercises: newExercises ?? oldRoutine.exercises,
        durationInMinutes: newDurationInMinutes ?? oldRoutine.durationInMinutes,
        associatedGoal: newAssociatedGoal ?? oldRoutine.associatedGoal,
        updatedAt: DateTime.now(),
      );
      _saveRoutines();
      notifyListeners();
    }
  }

  Routine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((routine) => routine.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveRoutines() async {
    await _routinesFile.writeAsString(json.encode(_routines.map((r) => r.toJson()).toList()));
  }
}
