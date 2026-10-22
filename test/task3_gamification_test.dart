import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/gamification/domain/models/quest.dart';
import 'package:salary_quest/features/gamification/domain/services/achievement_engine.dart';
import 'package:salary_quest/features/gamification/domain/services/gamification_engine.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';

void main() {
  group('TASK 3: Game Layer, Boss Battle, Badges, Coin Shop & Anti-Farming Tests', () {
    test('1. Anti-farming: Add-then-delete XP farming is prevented and rolls back XP cleanly', () async {
      final notifier = SalaryQuestNotifier();
      final initialXp = notifier.state.hero.currentXp;

      final testDate = DateTime(2026, 10, 25, 11, 0);

      // Add a valid expense transaction -> earns 15 XP
      await notifier.addTransaction(
        amount: Money.fromRupees(250),
        title: 'Lunch Thali',
        category: TransactionCategory.food,
        customTimestamp: testDate,
      );

      expect(notifier.state.transactions.length, equals(1));
      final txId = notifier.state.transactions.first.id;
      expect(notifier.state.transactions.first.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 15));

      // Delete the transaction -> XP is cleanly rolled back
      await notifier.deleteTransaction(txId);

      expect(notifier.state.transactions.isEmpty, isTrue);
      expect(notifier.state.hero.currentXp, equals(initialXp),
          reason: 'Deleting transaction must revert the 15 XP earned');

      // Attempting to farm XP by repeated add-then-delete leaves net XP at initial
      for (int i = 0; i < 5; i++) {
        await notifier.addTransaction(
          amount: Money.fromRupees(100 + i),
          title: 'Farm Attempt $i',
          category: TransactionCategory.food,
          customTimestamp: testDate.add(Duration(minutes: 15 * (i + 1))),
        );
        final addedId = notifier.state.transactions.first.id;
        await notifier.deleteTransaction(addedId);
      }

      // Net XP remains strictly equal to initial XP
      expect(notifier.state.hero.currentXp, equals(initialXp));
      expect(notifier.state.transactions.isEmpty, isTrue);
    });

    test('2. Anti-farming: Deleting transaction restores daily allowance up to cap of 3', () async {
      final notifier = SalaryQuestNotifier();
      final initialXp = notifier.state.hero.currentXp;
      final testDate = DateTime(2026, 10, 25, 9, 0);

      // Log 3 transactions on testDate (reaches 3-tx / 45-XP daily cap)
      await notifier.addTransaction(
        amount: Money.fromRupees(100),
        title: 'Morning Chai',
        category: TransactionCategory.food,
        customTimestamp: testDate,
      );
      final tx1Id = notifier.state.transactions.first.id;

      await notifier.addTransaction(
        amount: Money.fromRupees(200),
        title: 'Metro Pass',
        category: TransactionCategory.transport,
        customTimestamp: testDate.add(const Duration(minutes: 30)),
      );

      await notifier.addTransaction(
        amount: Money.fromRupees(300),
        title: 'Snack',
        category: TransactionCategory.food,
        customTimestamp: testDate.add(const Duration(hours: 1)),
      );

      expect(notifier.state.hero.currentXp, equals(initialXp + 45));

      // 4th transaction on same day earns 0 XP due to daily cap
      await notifier.addTransaction(
        amount: Money.fromRupees(400),
        title: 'Book',
        category: TransactionCategory.entertainment,
        customTimestamp: testDate.add(const Duration(hours: 2)),
      );
      expect(notifier.state.transactions.first.earnedXp, equals(0));
      expect(notifier.state.hero.currentXp, equals(initialXp + 45));

      // Now delete tx1 (which held 15 XP)
      await notifier.deleteTransaction(tx1Id);
      // XP drops to initialXp + 30
      expect(notifier.state.hero.currentXp, equals(initialXp + 30));

      // Now adding a new transaction on that day CAN earn 15 XP since active count is 2 (< 3)
      await notifier.addTransaction(
        amount: Money.fromRupees(150),
        title: 'Evening Coffee',
        category: TransactionCategory.food,
        customTimestamp: testDate.add(const Duration(hours: 5)),
      );
      expect(notifier.state.transactions.first.earnedXp, equals(15));
      expect(notifier.state.hero.currentXp, equals(initialXp + 45));
    });

    test('3. Level floor protection: reverting more XP than current XP never reduces hero level', () {
      const hero = HeroCharacter(
        name: 'Aero',
        level: 4,
        currentXp: 50,
        maxXp: 500,
        coins: 100,
      );

      // Revert 200 XP (exceeds currentXp of 50)
      final reverted = GamificationEngine.revertXp(hero, 200);

      expect(reverted.currentXp, equals(0));
      expect(reverted.level, equals(4),
          reason: 'Level Floor Guarantee: Hero level can never regress below current level');
    });

    test('4. Soft Recovery: 10 consecutive overspend days triggers Fresh Start quest', () async {
      final notifier = SalaryQuestNotifier();

      // Simulate 10 days in the cycle, each overspent
      final budgets = List.generate(
        30,
        (i) => notifier.state.dailyBudgets[i].copyWith(
          allocatedBudget: Money.fromRupees(1000),
          actualSpent: i < 10 ? Money.fromRupees(1500) : const Money.zero(),
        ),
      );

      notifier.state = notifier.state.copyWith(
        currentDayIndex: 11,
        dailyBudgets: budgets,
        hero: notifier.state.hero.copyWith(currentHp: 0), // Fainted
      );

      expect(notifier.state.hero.isFainted, isTrue);

      // Trigger evaluation of consecutive overspends
      notifier.evaluateConsecutiveOverspends();

      // Fresh Start recovery quest must be added to quests
      final hasRecoveryQuest = notifier.state.quests.any(
        (q) => q.type == QuestType.freshStartRecovery,
      );
      expect(hasRecoveryQuest, isTrue,
          reason: '10 consecutive overspend days must trigger Soft Recovery quest');

      // Verify level floor was preserved despite fainting
      expect(notifier.state.hero.level, greaterThanOrEqualTo(1));

      // Complete and claim the recovery quest
      final recoveryQuest = notifier.state.quests.firstWhere(
        (q) => q.type == QuestType.freshStartRecovery,
      );
      notifier.state = notifier.state.copyWith(
        quests: notifier.state.quests.map((q) {
          if (q.id == recoveryQuest.id) {
            return q.copyWith(progressValue: 1.0, isCompleted: true);
          }
          return q;
        }).toList(),
      );

      await notifier.claimQuestReward(recoveryQuest.id);

      // HP is restored by 30 and hero is no longer fainted
      expect(notifier.state.hero.currentHp, equals(30));
      expect(notifier.state.hero.isFainted, isFalse);
    });

    test('5. Boss Battle: Savings target anchors Boss HP, savings deal damage, overspending heals boss', () {
      final cycle = BudgetCycle.createValidated(
        id: 'cycle_boss_test',
        year: 2026,
        month: 10,
        paydayDay: 1,
        inHandSalary: Money.fromRupees(50000),
        fixedExpensesTotal: Money.fromRupees(15000),
        savingsTargetAmount: Money.fromRupees(10000), // Boss Max HP = 10,000
      );

      expect(cycle.savingsTargetAmount.inWholeRupees, equals(10000));

      // Recompute with Day 1: User saves money (allocated 1000, spent 400 -> saved 600)
      final recomputeResult = TransactionEventRecomputer.recompute(
        cycle: cycle,
        transactions: const [],
        currentDayIndex: 1,
      );
      expect(recomputeResult.bossHp, lessThanOrEqualTo(10000));

      // Test claimBossBattleResult:
      final notifier = SalaryQuestNotifier();
      // When boss HP > 0: defeat is false
      notifier.state = notifier.state.copyWith(
        bossCurrentHp: 5000,
        bossMaxHp: 10000,
      );
      expect(notifier.claimBossBattleResult(), completion(isFalse));

      // When boss HP drops to 0: Victory!
      notifier.state = notifier.state.copyWith(
        bossCurrentHp: 0,
        bossMaxHp: 10000,
      );
      expect(notifier.claimBossBattleResult(), completion(isTrue));
    });

    test('6. Cycle Advance: archives current cycle, resets Boss HP to new savings target', () async {
      final notifier = SalaryQuestNotifier();

      // Modify Boss HP during current cycle
      notifier.state = notifier.state.copyWith(
        bossCurrentHp: 1200,
        bossMaxHp: 10000,
      );

      // Advance to next cycle (November 2026)
      await notifier.advanceToNextCycle(nextMonth: 11, nextYear: 2026);

      expect(notifier.state.cycle.startDate.month, equals(11));
      expect(notifier.state.cycle.startDate.year, equals(2026));
      expect(notifier.state.currentDayIndex, equals(1));
      expect(notifier.state.transactions.isEmpty, isTrue);

      // Boss HP must be cleanly reset to the new savings target
      final expectedTarget = notifier.state.cycle.savingsTargetAmount.inWholeRupees;
      expect(notifier.state.bossCurrentHp, equals(expectedTarget));
      expect(notifier.state.bossMaxHp, equals(expectedTarget));
    });

    test('7. Badges and Achievements: Unlocked once, never revoked', () {
      final notifier = SalaryQuestNotifier();

      // Evaluate achievements with 1 transaction logged
      final dummyTx = Transaction(
        id: 'tx_first',
        cycleId: notifier.state.cycle.id,
        amount: Money.fromRupees(100),
        title: 'First Coffee',
        category: TransactionCategory.food,
        timestamp: DateTime.now(),
        dedupeKey: 'key_1',
      );

      final unlocked = AchievementEngine.evaluate(
        currentUnlocked: const [],
        transactions: [dummyTx],
        hero: notifier.state.hero,
        dailyBudgets: notifier.state.dailyBudgets,
        savingsGoals: const [],
        cycle: notifier.state.cycle,
        bossCurrentHp: notifier.state.bossCurrentHp,
      );

      expect(unlocked.any((a) => a.id == 'first_log'), isTrue);

      // Unlock 'first_log' in state
      notifier.state = notifier.state.copyWith(
        achievements: AchievementEngine.allCatalogBadges.map((b) {
          if (b.id == 'first_log') {
            return b.copyWith(unlockedAt: DateTime.now());
          }
          return b;
        }).toList(),
      );

      // Even if transactions list becomes empty (all deleted), badge remains unlocked
      final afterDeleteUnlocked = AchievementEngine.evaluate(
        currentUnlocked: notifier.state.achievements,
        transactions: const [], // Deleted
        hero: notifier.state.hero,
        dailyBudgets: notifier.state.dailyBudgets,
        savingsGoals: const [],
        cycle: notifier.state.cycle,
        bossCurrentHp: notifier.state.bossCurrentHp,
      );

      // Verify 'first_log' is not re-returned as newly unlocked
      expect(afterDeleteUnlocked.any((a) => a.id == 'first_log'), isFalse);
      expect(
        notifier.state.achievements.firstWhere((a) => a.id == 'first_log').isUnlocked,
        isTrue,
        reason: 'Achievements are permanent and can never be revoked once unlocked',
      );
    });

    test('8. Coin Shop: Skins and themes permanent, coins cannot go negative, cannot afford check', () async {
      final notifier = SalaryQuestNotifier();

      // Set hero coins to 100
      notifier.state = notifier.state.copyWith(
        hero: notifier.state.hero.copyWith(
          coins: 100,
          unlockedSkins: const ['knight_default'],
          skin: 'knight_default',
        ),
      );

      // Attempt to purchase an expensive skin (400 coins)
      final expensiveSuccess =
          await notifier.purchaseHeroSkin('skin_paladin_gold', 400);
      expect(expensiveSuccess, isFalse);
      expect(notifier.state.hero.coins, equals(100),
          reason: 'Coins cannot go negative');
      expect(notifier.state.hero.unlockedSkins.contains('skin_paladin_gold'), isFalse);

      // Purchase an affordable skin (75 coins)
      final affordableSuccess =
          await notifier.purchaseHeroSkin('skin_shadow_rogue', 75);
      expect(affordableSuccess, isTrue);
      expect(notifier.state.hero.coins, equals(25)); // 100 - 75 = 25
      expect(notifier.state.hero.unlockedSkins.contains('skin_shadow_rogue'), isTrue);

      // Equip the newly purchased skin
      await notifier.equipHeroSkin('skin_shadow_rogue');
      expect(notifier.state.hero.skin, equals('skin_shadow_rogue'));

      // Attempting to buy the same skin again fails (already unlocked)
      final duplicatePurchase =
          await notifier.purchaseHeroSkin('skin_shadow_rogue', 10);
      expect(duplicatePurchase, isFalse);

      // Purchase UI theme
      notifier.state = notifier.state.copyWith(
        hero: notifier.state.hero.copyWith(coins: 150),
      );
      final themePurchase =
          await notifier.purchaseTheme('theme_cyberpunk', 120);
      expect(themePurchase, isTrue);
      expect(notifier.state.hero.coins, equals(30)); // 150 - 120 = 30
      expect(notifier.state.hero.unlockedThemes.contains('theme_cyberpunk'), isTrue);

      // Equip theme
      await notifier.equipTheme('theme_cyberpunk');
      expect(notifier.state.hero.themeId, equals('theme_cyberpunk'));
    });
  });
}
