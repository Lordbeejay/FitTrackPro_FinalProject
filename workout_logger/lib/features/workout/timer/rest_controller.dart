import 'dart:async';
import 'package:flutter/material.dart';

class RestTimerController extends ChangeNotifier {
  bool isResting = false;
  int secondsRemaining = 30;
  Timer? _timer;

  void startRest({int duration = 30}) {
    isResting = true;
    secondsRemaining = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        stopRest();
      }
    });
    notifyListeners();
  }

  void stopRest() {
    _timer?.cancel();
    isResting = false;
    notifyListeners();
  }

  void skipRest() {
    stopRest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}