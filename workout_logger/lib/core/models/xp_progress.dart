class XPProgress {
  int currentXP;
  int level;
  List<String> badges;

  XPProgress({
    required this.currentXP,
    required this.level,
    required this.badges,
  });

  factory XPProgress.fromJson(Map<String, dynamic> json) {
    return XPProgress(
      currentXP: json['currentXP'],
      level: json['level'],
      badges: List<String>.from(json['badges']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentXP': currentXP,
      'level': level,
      'badges': badges,
    };
  }
}