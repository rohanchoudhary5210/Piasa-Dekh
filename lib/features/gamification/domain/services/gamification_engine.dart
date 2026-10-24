import 'dart:math';
import '../../../../core/models/money.dart';
import '../models/gamification_exceptions.dart';
import '../models/hero_character.dart';
import '../models/quest.dart';

class GamificationEngine {
  GamificationEngine._();

  /// Computes max XP required for the given level using an exponential RPG curve.
  static int xpRequiredForLevel(int level) {
    return (100 * pow(level, 1.35)).floor();
  }

  /// Adds XP to hero and triggers level ups if threshold crossed.
  static HeroCharacter awardXp(HeroCharacter hero, int xpAmount) {
    if (xpAmount <= 0) return hero;

    int newXp = hero.currentXp + xpAmount;
    int currentLevel = hero.level;
    int maxXp = hero.maxXp;

    while (newXp >= maxXp) {
      newXp -= maxXp;
      currentLevel += 1;
      maxXp = xpRequiredForLevel(currentLevel);
    }

    return hero.copyWith(
      level: currentLevel,
      currentXp: newXp,
      maxXp: maxXp,
    );
  }

  /// Deducts XP while guaranteeing that level never decreases.
  /// (Strict Level Floor: level and achievements are permanent).
  static HeroCharacter revertXp(HeroCharacter hero, int xpAmount) {
    if (xpAmount <= 0) return hero;
    final newXp = (hero.currentXp - xpAmount).clamp(0, hero.maxXp);
    return hero.copyWith(currentXp: newXp);
  }

  /// Adjusts Hero HP depending on today's spend ratio (spent / allocated).
  /// HP can drop to 0, which induces the "Fainted" state.
  static HeroCharacter evaluateDailyHealthImpact({
    required HeroCharacter hero,
    required double spentRatio,
  }) {
    int hpDelta;

    if (spentRatio == 0.0) {
      hpDelta = 25; // Iron will zero-spend bonus
    } else if (spentRatio <= 0.8) {
      hpDelta = 15; // Healthy under-budget
    } else if (spentRatio <= 1.0) {
      hpDelta = 5; // Safe exact
    } else if (spentRatio <= 1.25) {
      hpDelta = -15; // Light overspend penalty
    } else {
      hpDelta = -30; // Heavy overspend
    }

    final newHp = (hero.currentHp + hpDelta).clamp(0, hero.maxHp);
    return hero.copyWith(currentHp: newHp);
  }

  /// Evaluates streak for a closed day:
  /// - A zero-spend day maintains & increments the streak.
  /// - An under-budget day (actualSpent <= allocatedBudget) maintains & increments the streak.
  /// - An overspent day breaks the streak (saves previousStreakDays and resets streak to 0).
  static HeroCharacter evaluateDailyStreak({
    required HeroCharacter hero,
    required Money actualSpent,
    required Money allocatedBudget,
  }) {
    if (actualSpent.paise <= 0 || actualSpent <= allocatedBudget) {
      return hero.copyWith(streakDays: hero.streakDays + 1);
    } else {
      return hero.copyWith(
        previousStreakDays: hero.streakDays,
        streakDays: 0,
      );
    }
  }

  /// Repairs a broken streak using coins and the cycle's streak shield.
  /// Costs 50 coins and can only be used once per cycle.
  static HeroCharacter repairStreak(HeroCharacter hero, {int costCoins = 50}) {
    if (!hero.streakShieldAvailable) {
      throw const StreakAlreadyRepairedException(
          'Streak shield has already been used this cycle!');
    }
    if (hero.coins < costCoins) {
      throw const InsufficientCoinsException(
          'Not enough coins to repair streak! (Requires 50 coins)');
    }
    if (hero.previousStreakDays <= 0) {
      throw const NoBrokenStreakException('No broken streak to repair!');
    }

    return hero.copyWith(
      streakDays: hero.previousStreakDays,
      coins: hero.coins - costCoins,
      streakShieldAvailable: false,
    );
  }

  /// Calculates quest coin reward, penalizing coin earnings by 50% if the hero has fainted.
  static int calculateQuestCoinReward(
      HeroCharacter hero, int baseRewardCoins) {
    if (hero.isFainted) {
      return (baseRewardCoins * 0.5).floor();
    }
    return baseRewardCoins;
  }

  /// Checks if consecutive overspend days reach or exceed 10 days.
  /// Triggers a Soft Recovery / Fresh Start Quest so the player is not trapped in death spiral,
  /// with level floor protection guaranteeing hero level never decreases.
  static DailyQuest? checkSoftRecoveryTrigger({
    required int consecutiveOverspendDays,
    required HeroCharacter hero,
  }) {
    if (consecutiveOverspendDays >= 10) {
      return const DailyQuest(
        id: 'quest_fresh_start_recovery',
        title: '🌱 Fresh Start Recovery',
        description:
            'Complete today under budget to regain 30 HP and restore morale.',
        type: QuestType.freshStartRecovery,
        targetValue: 1.0,
        progressValue: 0.0,
        rewardXp: 50,
        rewardCoins: 20,
        rewardHp: 30,
      );
    }
    return null;
  }

  /// Default starter daily quests
  static List<DailyQuest> getStarterQuests() {
    return const [
      DailyQuest(
        id: 'quest_log_first',
        title: 'Frugal Scout',
        description: 'Log your first expense or verify daily spending',
        type: QuestType.logExpense,
        targetValue: 1.0,
        progressValue: 0.0,
        rewardXp: 25,
        rewardCoins: 10,
      ),
      DailyQuest(
        id: 'quest_under_target',
        title: 'Guardian Shield',
        description: 'Keep total daily spend under budget today (reward added automatically at midnight)',
        type: QuestType.spendUnderAmount,
        targetValue: 1.0,
        progressValue: 0.0,
        rewardXp: 50,
        rewardCoins: 20,
      ),
      DailyQuest(
        id: 'quest_no_spend',
        title: 'Iron Will Sanctuary',
        description: 'Spend nothing today (reward added automatically at midnight)',
        type: QuestType.noSpendDay,
        targetValue: 1.0,
        progressValue: 0.0,
        rewardXp: 100,
        rewardCoins: 40,
      ),
    ];
  }
}
