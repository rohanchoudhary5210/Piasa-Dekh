import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/models/daily_budget.dart';
import 'package:salary_quest/features/gamification/domain/models/achievement.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

class AchievementEngine {
  AchievementEngine._();

  static const List<Achievement> allCatalogBadges = [
    Achievement(
      id: 'first_log',
      title: 'Novice Tracker',
      description: 'Logged your first expense in SalaryQuest.',
      icon: '🏆',
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintained an unbroken 7-day budget streak.',
      icon: '🔥',
    ),
    Achievement(
      id: 'streak_30',
      title: 'Legendary Saver',
      description: 'Maintained a 30-day unbroken budget streak.',
      icon: '⚡',
    ),
    Achievement(
      id: 'no_spend_day',
      title: 'Iron Will',
      description: 'Completed a Zero-Spend day with ₹0 expenses.',
      icon: '🛡️',
    ),
    Achievement(
      id: 'first_goal_done',
      title: 'Goal Crusher',
      description: 'Successfully reached your target on a savings goal.',
      icon: '🎯',
    ),
    Achievement(
      id: 'boss_defeated',
      title: 'Titan Slayer',
      description: 'Reduced the monthly Inflation Boss HP to 0 by saving.',
      icon: '⚔️',
    ),
    Achievement(
      id: 'thrift_master',
      title: 'Thrift Master',
      description: 'Saved more than 20% of your monthly in-hand salary.',
      icon: '💰',
    ),
    Achievement(
      id: 'shop_collector',
      title: 'Collector',
      description: 'Unlocked a hero skin or custom UI theme in the Coin Shop.',
      icon: '🛍️',
    ),
  ];

  /// Evaluates current user game state and returns list of newly unlocked achievements.
  /// Rule: Once unlocked, an achievement is permanent and never revoked.
  static List<Achievement> evaluate({
    required List<Achievement> currentUnlocked,
    required List<Transaction> transactions,
    required HeroCharacter hero,
    required List<DailyBudget> dailyBudgets,
    required List<SavingsGoal> savingsGoals,
    required BudgetCycle cycle,
    required int bossCurrentHp,
  }) {
    final Set<String> alreadyUnlockedIds =
        currentUnlocked.where((a) => a.isUnlocked).map((a) => a.id).toSet();

    final List<Achievement> newlyUnlocked = [];

    void checkAndUnlock(String id) {
      if (!alreadyUnlockedIds.contains(id)) {
        final catalogEntry =
            allCatalogBadges.firstWhere((a) => a.id == id, orElse: () => allCatalogBadges.first);
        newlyUnlocked.add(catalogEntry.copyWith(unlockedAt: DateTime.now()));
      }
    }

    // 1. First transaction logged
    if (transactions.isNotEmpty) {
      checkAndUnlock('first_log');
    }

    // 2. 7-day streak
    if (hero.streakDays >= 7) {
      checkAndUnlock('streak_7');
    }

    // 3. 30-day streak
    if (hero.streakDays >= 30) {
      checkAndUnlock('streak_30');
    }

    // 4. Zero-Spend Day
    final hasZeroSpendDay =
        dailyBudgets.any((b) => b.isClosed && b.actualSpent.isZero);
    if (hasZeroSpendDay) {
      checkAndUnlock('no_spend_day');
    }

    // 5. First Goal Completed
    final hasCompletedGoal = savingsGoals.any((g) => g.isCompleted);
    if (hasCompletedGoal) {
      checkAndUnlock('first_goal_done');
    }

    // 6. Boss Defeated (Boss HP <= 0)
    if (bossCurrentHp <= 0) {
      checkAndUnlock('boss_defeated');
    }

    // 7. Thrift Master (Savings target >= 20% of salary)
    if (cycle.savingsTargetAmount.paise >= (cycle.inHandSalary.paise * 0.20)) {
      checkAndUnlock('thrift_master');
    }

    // 8. Shop Collector (Has unlocked custom skins or themes)
    if (hero.unlockedSkins.length > 1 || hero.unlockedThemes.length > 1) {
      checkAndUnlock('shop_collector');
    }

    return newlyUnlocked;
  }
}
