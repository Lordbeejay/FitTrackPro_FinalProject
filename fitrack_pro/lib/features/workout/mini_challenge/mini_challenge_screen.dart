import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitrack_pro/core/models/mini_challenge.dart';
import 'package:fitrack_pro/core/services/mini_challenge_service.dart';
import 'package:fitrack_pro/core/services/xp_service.dart';

class MiniChallengeScreen extends StatefulWidget {
  final MiniChallenge challenge;
  final VoidCallback onComplete;

  const MiniChallengeScreen({Key? key, required this.challenge, required this.onComplete}) : super(key: key);

  @override
  State<MiniChallengeScreen> createState() => _MiniChallengeScreenState();
}

class _MiniChallengeScreenState extends State<MiniChallengeScreen> {
  Stopwatch _stopwatch = Stopwatch();
  int _reps = 0;
  bool _isCompleted = false;
  late TextEditingController _repsController;
  late TextEditingController _noteController;
  bool _loading = true;
  int _savedElapsed = 0;
  int? _targetReps;
  int? _targetSeconds;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: '$_reps');
    _noteController = TextEditingController();
    _parseTarget();
    _loadProgress();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _repsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Helper to determine if this is a timer challenge
  bool get _isTimerChallenge {
    final desc = widget.challenge.description.toLowerCase();
    return desc.contains('walk') ||
        desc.contains('run') ||
        desc.contains('yoga') ||
        desc.contains('stretch') ||
        desc.contains('minute') ||
        desc.contains('hold') ||
        desc.contains('plank') ||
        desc.contains('wall sit') ||
        desc.contains('flow');
  }

  // Parse target reps or seconds from description
  void _parseTarget() {
    final desc = widget.challenge.description.toLowerCase();
    final repMatch = RegExp(r'(\d+)\s*(push|sit|pull|burpee|jack|squat|lunge|dip|crunch|mountain|reps|stand|bicycle|tricep|pull-up|pull up|pullups|push-ups|pushups|sit-ups|situps|squats|lunges|dips|crunches|jacks|burpees|minutes|minute|seconds|second)').firstMatch(desc);
    if (repMatch != null) {
      final value = int.tryParse(repMatch.group(1)!);
      if (desc.contains('minute')) {
        _targetSeconds = value != null ? value * 60 : null;
      } else {
        _targetReps = value;
      }
    }
    // Default for timer-based challenges if not found: 10 minutes
    if (_isTimerChallenge && _targetSeconds == null) {
      _targetSeconds = 600;
    }
  }

  // Helper to determine if challenge is in progress
  bool get _isInProgress =>
      (!_isCompleted) &&
      ((_isTimerChallenge && (_stopwatch.elapsed.inSeconds + _savedElapsed) > 0) ||
          (!_isTimerChallenge && _reps > 0));

  // Save progress to SharedPreferences
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_isTimerChallenge) {
      await prefs.setInt('mini_challenge_timer_$today', _stopwatch.elapsed.inSeconds + _savedElapsed);
    } else {
      await prefs.setInt('mini_challenge_reps_$today', _reps);
    }
    await prefs.setString('mini_challenge_note_$today', _noteController.text);
    await prefs.setBool('mini_challenge_in_progress', _isInProgress);
  }

  // Load progress from SharedPreferences
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    int reps = prefs.getInt('mini_challenge_reps_$today') ?? 0;
    int timer = prefs.getInt('mini_challenge_timer_$today') ?? 0;
    bool completed = prefs.getBool('mini_challenge_completed') ?? false;
    String note = prefs.getString('mini_challenge_note_$today') ?? '';
    setState(() {
      _reps = reps;
      _repsController.text = '$_reps';
      _isCompleted = completed;
      _loading = false;
      _savedElapsed = timer;
      _noteController.text = note;
    });
  }

  void _startTimer() {
    setState(() {
      _stopwatch.start();
    });
    _tickTimer();
  }

  void _tickTimer() async {
    if (!_stopwatch.isRunning || _isCompleted) return;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {});
    final elapsed = _stopwatch.elapsed.inSeconds + _savedElapsed;
    if (_targetSeconds != null && elapsed >= _targetSeconds!) {
      _stopwatch.stop();
      await _saveProgress();
      _completeChallenge();
      return;
    }
    _tickTimer();
  }

  void _stopTimer() async {
    setState(() {
      _stopwatch.stop();
    });
    await _saveProgress();
  }

  void _incrementReps() async {
    setState(() {
      _reps++;
      _repsController.text = '$_reps';
    });
    await _saveProgress();
    if (_targetReps != null && _reps >= _targetReps!) {
      _completeChallenge();
    }
  }

  void _decrementReps() async {
    setState(() {
      if (_reps > 0) _reps--;
      _repsController.text = '$_reps';
    });
    await _saveProgress();
  }

  void _onRepsChanged(String val) async {
    final v = int.tryParse(val);
    if (v != null && v >= 0) {
      setState(() {
        _reps = v;
      });
      await _saveProgress();
      if (_targetReps != null && _reps >= _targetReps!) {
        _completeChallenge();
      }
    }
  }

  void _onNoteChanged(String val) async {
    await _saveProgress();
  }

  void _onStartOrContinue() async {
    await _saveProgress();
    if (_isTimerChallenge) {
      _startTimer();
    }
  }

  void _completeChallenge() async {
    if (_isCompleted) return;
    final prefs = await SharedPreferences.getInstance();
    await MiniChallengeService().completeChallenge();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setBool('mini_challenge_completed', true);
    await prefs.setBool('mini_challenge_in_progress', false);
    setState(() {
      _isCompleted = true;
    });
    widget.onComplete();

    // Show congratulation dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Color(0xFF7F53AC), size: 56),
            const SizedBox(height: 16),
            Text(
              "Congratulations!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F53AC),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You completed today's daily challenge!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              "+${widget.challenge.xpReward} XP earned!",
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7F53AC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(120, 40),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );

    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed.inSeconds + _savedElapsed;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text(
                    "Today's Mini Challenge",
                    style: TextStyle(
                      color: Color(0xFF7F53AC),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.challenge.description,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.yellow[700]),
                      const SizedBox(width: 6),
                      Text(
                        "+${widget.challenge.xpReward} XP",
                        style: TextStyle(
                          color: Colors.yellow[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_isTimerChallenge) ...[
                    Center(
                      child: Text(
                        "Timer",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F53AC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _stopwatch.isRunning ? null : _onStartOrContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF647DEE),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                          ),
                          child: Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _stopwatch.isRunning ? _stopTimer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7F53AC),
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(16),
                          ),
                          child: Icon(Icons.stop, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "Elapsed: ${_formatTime(elapsed)}",
                        style: TextStyle(
                          color: Color(0xFF647DEE),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Center(
                      child: Text(
                        "Reps Completed",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7F53AC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Color(0xFF647DEE), size: 36),
                          onPressed: _decrementReps,
                        ),
                        Container(
                          width: 60,
                          alignment: Alignment.center,
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7F53AC)),
                            controller: _repsController,
                            onChanged: _onRepsChanged,
                            decoration: InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Color(0xFF7F53AC), size: 36),
                          onPressed: _incrementReps,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_isCompleted) ...[
                    TextField(
                      controller: _noteController,
                      onChanged: _onNoteChanged,
                      decoration: InputDecoration(
                        labelText: "Add a note or name this achievement",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLength: 40,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Text(
                          "Challenge completed! Come back tomorrow for a new one.",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ParsedChallenge {
  final int sets;
  final List<ExerciseTarget> exercises;
  ParsedChallenge({required this.sets, required this.exercises});
}

class ExerciseTarget {
  final String name;
  final int reps;
  ExerciseTarget({required this.name, required this.reps});
}

ParsedChallenge parseChallenge(String description) {
  final lower = description.toLowerCase();
  int sets = 1;
  final setMatch = RegExp(r'(\d+)\s*sets?').firstMatch(lower);
  if (setMatch != null) {
    sets = int.parse(setMatch.group(1)!);
  }

  // Split by 'and' or commas for multiple exercises
  final exerciseParts = description
      .replaceAll(RegExp(r'\d+\s*sets? of'), '')
      .split(RegExp(r',| and '))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final List<ExerciseTarget> exercises = [];
  for (final part in exerciseParts) {
    final match = RegExp(r'(\d+)\s*([a-zA-Z \-]+)').firstMatch(part);
    if (match != null) {
      final reps = int.parse(match.group(1)!);
      final name = match.group(2)!.trim();
      exercises.add(ExerciseTarget(name: name, reps: reps));
    }
  }

  return ParsedChallenge(sets: sets, exercises: exercises);
}