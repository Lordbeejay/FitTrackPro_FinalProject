import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_logger/core/models/goal.dart';

class GoalService with ChangeNotifier {
  final List<Goal> _goals = [];
  late File _goalsFile;

  GoalService() {
    _init();
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _goalsFile = File('${dir.path}/goals.json');

    if (await _goalsFile.exists()) {
      final content = await _goalsFile.readAsString();
      final List<dynamic> decoded = json.decode(content);
      _goals.clear();
      _goals.addAll(decoded.map((e) => Goal.fromJson(e)));
    } else {
      await _goalsFile.create();
      await _goalsFile.writeAsString(json.encode([]));
    }
    notifyListeners();
  }

  List<Goal> getGoals() => _goals;

  Goal createGoal(String title, String description, double targetValue) {
    final now = DateTime.now();
    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      description: description,
      targetValue: targetValue,
      currentValue: 0.0,
      createdAt: now,
      updatedAt: now,
    );
    _goals.add(goal);
    _saveGoals();
    notifyListeners();
    return goal;
  }

  void updateGoal(String id, String newTitle, String newDescription, double newTargetValue) {
    final goalIndex = _goals.indexWhere((goal) => goal.id == id);
    if (goalIndex != -1) {
      final oldGoal = _goals[goalIndex];
      _goals[goalIndex] = oldGoal.copyWith(
        title: newTitle,
        description: newDescription,
        targetValue: newTargetValue,
        updatedAt: DateTime.now(),
      );
      _saveGoals();
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((goal) => goal.id == id);
    _saveGoals();
    notifyListeners();
  }

  void updateProgress(String id, double newCurrentValue) {
    final goalIndex = _goals.indexWhere((goal) => goal.id == id);
    if (goalIndex != -1) {
      final oldGoal = _goals[goalIndex];
      _goals[goalIndex] = oldGoal.copyWith(
        currentValue: newCurrentValue,
        updatedAt: DateTime.now(),
      );
      _saveGoals();
      notifyListeners();
    }
  }

  Goal? getGoalById(String id) {
    try {
      return _goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveGoals() async {
    await _goalsFile.writeAsString(json.encode(_goals.map((g) => g.toJson()).toList()));
  }
}
