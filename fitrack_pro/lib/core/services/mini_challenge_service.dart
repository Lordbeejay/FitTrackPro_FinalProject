import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mini_challenge.dart';

enum MiniChallengeStatus { notStarted, inProgress, completed }

class MiniChallengeService {
  final List<MiniChallenge> _challenges = [
    MiniChallenge(description: "Do 40 push ups today", xpReward: 50),
    MiniChallenge(description: "Do 50 sit ups today", xpReward: 30),
    MiniChallenge(description: "Run for 10 minutes", xpReward: 40),
    MiniChallenge(description: "Hold a plank for 3 minutes", xpReward: 25),
    MiniChallenge(description: "Do 20 burpees", xpReward: 35),
    MiniChallenge(description: "Do 100 jumping jacks", xpReward: 30),
    MiniChallenge(description: "Do 15 pull-ups", xpReward: 45),
    MiniChallenge(description: "Do 30 squats", xpReward: 35),
    MiniChallenge(description: "Stretch for 15 minutes", xpReward: 20),
    MiniChallenge(description: "Do 3 sets of 20 mountain climbers", xpReward: 30),
    MiniChallenge(description: "Hold a wall sit for 90 seconds", xpReward: 25),
    MiniChallenge(description: "Do 25 tricep dips", xpReward: 30),
    MiniChallenge(description: "Do 2 minutes of high knees", xpReward: 25),
    MiniChallenge(description: "Complete a 10-minute yoga flow", xpReward: 30),
    MiniChallenge(description: "Do 40 lunges (20 each leg)", xpReward: 35),
    MiniChallenge(description: "Do 3 sets of 15 bicycle crunches", xpReward: 30),
    MiniChallenge(description: "Do 25 push ups", xpReward: 15),
    MiniChallenge(description: "Take a brisk 20-minute walk", xpReward: 30),
    MiniChallenge(description: "Do 30 burpees", xpReward: 40),
  ];

  Future<MiniChallenge> getTodayChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString('mini_challenge_date');
    final lastDesc = prefs.getString('mini_challenge_desc');
    final lastXP = prefs.getInt('mini_challenge_xp');

    if (lastDate == today && lastDesc != null && lastXP != null) {
      return MiniChallenge(description: lastDesc, xpReward: lastXP);
    } else {
      final random = Random();
      final challenge = _challenges[random.nextInt(_challenges.length)];
      await prefs.setString('mini_challenge_date', today);
      await prefs.setString('mini_challenge_desc', challenge.description);
      await prefs.setInt('mini_challenge_xp', challenge.xpReward);
      await prefs.setBool('mini_challenge_completed', false);
      return challenge;
    }
  }

  Future<bool> isChallengeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('mini_challenge_completed') ?? false;
  }

  Future<MiniChallengeStatus> getChallengeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    String? lastDate = prefs.getString('mini_challenge_date');

    if (lastDate != today) return MiniChallengeStatus.notStarted;
    if (prefs.getBool('mini_challenge_completed') == true) {
      return MiniChallengeStatus.completed;
    }
    // --- NEW: Check if reps or timer > 0 for today ---
    final reps = prefs.getInt('mini_challenge_reps_$today') ?? 0;
    final timer = prefs.getInt('mini_challenge_timer_$today') ?? 0;
    if (reps > 0 || timer > 0) {
      return MiniChallengeStatus.inProgress;
    }
    // -------------------------------------------------
    if (prefs.getBool('mini_challenge_in_progress') == true) {
      return MiniChallengeStatus.inProgress;
    }
    return MiniChallengeStatus.notStarted;
  }

  Future<void> setChallengeInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mini_challenge_in_progress', true);
  }

  Future<void> completeChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mini_challenge_completed', true);
    await prefs.setBool('mini_challenge_in_progress', false);
  }
}
