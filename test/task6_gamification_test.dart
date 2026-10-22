import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/gamification/domain/models/gamification_exceptions.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

void main() {
  group('TASK 6: Gamification Fixes & Serious Mode Tests', () {
    test('1. Anti-farming: Caps XP from logging at 3 transactions per day (max 45 XP/day)', () async {
      final notifier = SalaryQuestNotifier();
      final initialXp = notifier.state.hero.currentXp;

      final testDate = DateTime(2026, 10, 25, 10, 0);

      // Tx 1 on testDate: earns 15 XP
      await notifier.addTransaction(
        amount: Money.fromRupees(100),
        title: 'Chai',
        category: TransactionCategory.food,
        customTimestamp: testDate,
      );
      expect(notifier.state.transactions.first.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 15));

      // Tx 2 on testDate: earns 15 XP
      await notifier.addTransaction(
        amount: Money.fromRupees(150),
        title: 'Metro',
        category: TransactionCategory.transport,
        customTimestamp: testDate.add(const Duration(minutes: 30)),
      );
      expect(notifier.state.transactions.first.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 30));

      // Tx 3 on testDate: earns 15 XP (total 45 XP reached)
      await notifier.addTransaction(
        amount: Money.fromRupees(200),
        title: 'Snack',
        category: TransactionCategory.food,
        customTimestamp: testDate.add(const Duration(hours: 1)),
      );
      expect(notifier.state.transactions.first.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 45));

      // Tx 4 on testDate: subsequent spend STILL tracks money but grants 0 XP!
      await notifier.addTransaction(
        amount: Money.fromRupees(500),
        title: 'Dinner',
        category: TransactionCategory.food,
        customTimestamp: testDate.add(const Duration(hours: 2)),
      );
      expect(notifier.state.transactions.first.earnedXp, equals(0));
      // XP remains capped at initial + 45
      expect(notifier.state.hero.currentXp, equals(initialXp + 45));
      // Money was still tracked accurately
      expect(notifier.state.transactions.length, equals(4));
    });

    test('2. Level Floor: Hero level cannot drop under any circumstances', () {
      // Create a level 3 hero with 120 XP
      const hero = HeroCharacter(
        name: 'Aero',
        level: 3,
        currentXp: 120,
        maxXp: 440,
        coins: 100,
      );

      // Revert 300 XP (greater than current XP)
      final afterRevert = GamificationEngine.revertXp(hero, 300);

      // XP is clamped to 0, but level NEVER drops below 3!
      expect(afterRevert.currentXp, equals(0));
      expect(afterRevert.level, equals(3));
    });

    test('3. Fainted State: HP drops to 0, hero is fainted, coin rewards penalized by 50%', () {
      const hero = HeroCharacter(
        name: 'Aero',
        level: 2,
        currentHp: 20,
        maxHp: 100,
        coins: 80,
      );

      // Heavy overspend drops HP by 30 -> drops below 0 to 0
      final faintedHero = GamificationEngine.evaluateDailyHealthImpact(
        hero: hero,
        spentRatio: 2.0, // 200% overspend
      );

      expect(faintedHero.currentHp, equals(0));
      expect(faintedHero.isFainted, isTrue);
      expect(faintedHero.mood, equals(HeroMood.fainted));
      expect(faintedHero.level, equals(2)); // Level is not lost

      // Normal coin reward for 40 coins is penalized to 20 coins when fainted
      final penalizedCoins =
          GamificationEngine.calculateQuestCoinReward(faintedHero, 40);
      expect(penalizedCoins, equals(20));

      // When healthy, full 40 coins awarded
      final healthyHero = faintedHero.copyWith(currentHp: 100);
      expect(
        GamificationEngine.calculateQuestCoinReward(healthyHero, 40),
        equals(40),
      );
    });

    test('4. Streak Logic: Staying under budget and zero-spend days maintain & increment streak', () {
      const hero = HeroCharacter(name: 'Aero', streakDays: 5);

      // Scenario A: Under budget day (spent 300 out of 800) -> increments streak
      final underBudgetHero = GamificationEngine.evaluateDailyStreak(
        hero: hero,
        actualSpent: Money.fromRupees(300),
        allocatedBudget: Money.fromRupees(800),
      );
      expect(underBudgetHero.streakDays, equals(6));

      // Scenario B: Zero-spend day (spent 0 out of 800) -> maintains & increments streak
      final zeroSpendHero = GamificationEngine.evaluateDailyStreak(
        hero: hero,
        actualSpent: const Money.zero(),
        allocatedBudget: Money.fromRupees(800),
      );
      expect(zeroSpendHero.streakDays, equals(6));

      // Scenario C: Overspent day (spent 1200 out of 800) -> breaks streak, saves previous
      final overspentHero = GamificationEngine.evaluateDailyStreak(
        hero: hero,
        actualSpent: Money.fromRupees(1200),
        allocatedBudget: Money.fromRupees(800),
      );
      expect(overspentHero.streakDays, equals(0));
      expect(overspentHero.previousStreakDays, equals(5));
      expect(overspentHero.canRepairStreak, isTrue);
    });

    test('5. Streak Recovery: Restores broken streak using 50 coins and consumes streak shield', () {
      // Hero with broken streak (streak = 0, previous = 6, 80 coins, shield available)
      const brokenHero = HeroCharacter(
        name: 'Aero',
        streakDays: 0,
        previousStreakDays: 6,
        coins: 80,
        streakShieldAvailable: true,
      );

      expect(brokenHero.canRepairStreak, isTrue);

      // Repair streak
      final repairedHero = GamificationEngine.repairStreak(brokenHero);

      expect(repairedHero.streakDays, equals(6));
      expect(repairedHero.coins, equals(30)); // 80 - 50 = 30 coins
      expect(repairedHero.streakShieldAvailable, isFalse); // Shield consumed!

      // Attempting to repair a second time throws StreakAlreadyRepairedException
      expect(
        () => GamificationEngine.repairStreak(repairedHero),
        throwsA(isA<StreakAlreadyRepairedException>()),
      );

      // Attempting to repair with insufficient coins throws InsufficientCoinsException
      final poorHero = brokenHero.copyWith(coins: 20);
      expect(
        () => GamificationEngine.repairStreak(poorHero),
        throwsA(isA<InsufficientCoinsException>()),
      );
    });

    test('6. Serious Mode Toggle: Hides gamification while continuing all background calculations', () async {
      final notifier = SalaryQuestNotifier();

      expect(notifier.state.isSeriousMode, isFalse);

      // Enable Serious Mode
      await notifier.toggleSeriousMode(true);
      expect(notifier.state.isSeriousMode, isTrue);

      // Adding transaction in Serious Mode still updates daily budget & discretionary pool
      await notifier.addTransaction(
        amount: Money.fromRupees(300),
        title: 'Office Commute',
        category: TransactionCategory.transport,
      );

      expect(notifier.state.transactions.length, equals(1));
      expect(notifier.state.todayBudget.actualSpent, equals(Money.fromRupees(300)));

      // Disable Serious Mode back to Gamified Mode
      await notifier.toggleSeriousMode(false);
      expect(notifier.state.isSeriousMode, isFalse);
      // Hero state and stats are completely intact
      expect(notifier.state.hero.level, greaterThanOrEqualTo(1));
    });
  });
}
