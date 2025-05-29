import 'package:flutter/material.dart';
import 'package:fitrack_pro/core/models/mini_challenge.dart';
import 'package:fitrack_pro/core/services/mini_challenge_service.dart';
import 'package:fitrack_pro/features/workout/mini_challenge/mini_challenge_screen.dart';

class MiniChallengeCard extends StatefulWidget {
  final MiniChallenge challenge;
  final VoidCallback onStart;

  const MiniChallengeCard({
    Key? key,
    required this.challenge,
    required this.onStart,
  }) : super(key: key);

  @override
  State<MiniChallengeCard> createState() => _MiniChallengeCardState();
}

class _MiniChallengeCardState extends State<MiniChallengeCard> {
  MiniChallengeStatus _status = MiniChallengeStatus.notStarted;
  final MiniChallengeService _service = MiniChallengeService();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _service.getChallengeStatus();
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = _status == MiniChallengeStatus.inProgress ? "Continue Challenge" : "Start Challenge";
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Mini Challenge",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.challenge.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.stars, color: Colors.yellow[300]),
                const SizedBox(width: 6),
                Text(
                  "+${widget.challenge.xpReward} XP",
                  style: TextStyle(
                    color: Colors.yellow[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (_status != MiniChallengeStatus.completed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF7F53AC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => MiniChallengeScreen(
                          challenge: widget.challenge,
                          onComplete: () {
                            _loadStatus(); // <-- Immediately refresh status when challenge is started or progressed
                            setState(() {});
                          },
                        ),
                      );
                      _loadStatus(); // Also refresh after modal closes
                    },
                    child: Text(buttonText),
                  ),
              ],
            ),
            if (_status == MiniChallengeStatus.completed)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "Today's challenge done! Come back tomorrow.",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}