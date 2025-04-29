import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:workout_logger/core/models/xp_progress.dart';

class XPService {
  final String username;
  late XPProgress _progress;

  XPService({required this.username}) {
    _progress = XPProgress(currentXP: 0, level: 1, badges: []);
  }

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/xp_$username.json');
  }

  Future<void> loadProgress() async {
    final file = await _file;
    if (await file.exists()) {
      final content = await file.readAsString();
      _progress = XPProgress.fromJson(json.decode(content));
    }
  }

  Future<void> saveProgress() async {
    final file = await _file;
    await file.writeAsString(json.encode(_progress.toJson()));
  }

  XPProgress get progress => _progress;

  Future<void> addXP(int xp) async {
    _progress.currentXP += xp;

    // Level up every 100 XP
    while (_progress.currentXP >= 100) {
      _progress.currentXP -= 100;
      _progress.level += 1;
      _progress.badges.add('Level ${_progress.level} Achieved!');
    }

    await saveProgress();
  }

  /// Resets XP progress to initial state and saves to file
  Future<void> resetProgress() async {
    _progress = XPProgress(currentXP: 0, level: 1, badges: []);
    await saveProgress();
  }
}
