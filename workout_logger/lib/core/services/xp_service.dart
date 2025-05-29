import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fitrack_pro/core/models/xp_progress.dart';

class XPService with ChangeNotifier {
  final String username;
  late XPProgress _progress;

  XPService({required this.username}) {
    _progress = XPProgress(currentXP: 0, level: 1, badges: []);
    loadProgress(); // Preload XP data
  }

  XPProgress get progress => _progress;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/xp_$username.json');
  }

  Future<void> loadProgress() async {
    final file = await _file;
    if (await file.exists()) {
      final content = await file.readAsString();
      _progress = XPProgress.fromJson(json.decode(content));
      notifyListeners();
    }
  }

  Future<void> saveProgress() async {
    final file = await _file;
    await file.writeAsString(json.encode(_progress.toJson()));
  }

  Future<void> addXP(int xp) async {
    _progress.currentXP += xp;

    while (_progress.currentXP >= 100) {
      _progress.currentXP -= 100;
      _progress.level += 1;
      _progress.badges.add('Level ${_progress.level} Achieved!');
    }

    await saveProgress();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _progress = XPProgress(currentXP: 0, level: 1, badges: []);
    await saveProgress();
    notifyListeners();
  }
}