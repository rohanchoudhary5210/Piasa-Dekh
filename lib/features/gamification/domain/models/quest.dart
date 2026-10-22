enum QuestType {
  logExpense,
  spendUnderAmount,
  noSpendDay,
  reviewDay,
  freshStartRecovery,
}

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final double targetValue;
  final double progressValue;
  final int rewardXp;
  final int rewardCoins;
  final int rewardHp;
  final bool isCompleted;
  final bool isClaimed;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.progressValue = 0.0,
    required this.rewardXp,
    required this.rewardCoins,
    this.rewardHp = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressRatio {
    if (targetValue <= 0) return isCompleted ? 1.0 : 0.0;
    final ratio = progressValue / targetValue;
    return ratio.clamp(0.0, 1.0);
  }

  DailyQuest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    double? targetValue,
    double? progressValue,
    int? rewardXp,
    int? rewardCoins,
    int? rewardHp,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      progressValue: progressValue ?? this.progressValue,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardHp: rewardHp ?? this.rewardHp,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
