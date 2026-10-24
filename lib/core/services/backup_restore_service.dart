import 'dart:convert';
import 'package:salary_quest/core/services/data_conflict_resolver.dart';
import 'package:salary_quest/core/services/local_security_service.dart';
import 'package:salary_quest/features/budget/domain/models/budget_cycle.dart';
import 'package:salary_quest/features/budget/domain/services/cycle_date_calculator.dart';
import 'package:salary_quest/features/transactions/domain/services/transaction_event_recomputer.dart';
import 'package:salary_quest/features/gamification/domain/models/achievement.dart';
import 'package:salary_quest/features/gamification/domain/models/hero_character.dart';
import 'package:salary_quest/features/home/presentation/providers/salary_quest_provider.dart';
import 'package:salary_quest/features/savings_goals/domain/models/savings_goal.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

class BackupDecryptionException implements Exception {
  final String message;
  const BackupDecryptionException(this.message);

  @override
  String toString() => 'BackupDecryptionException: $message';
}

class BackupValidationException implements Exception {
  final String message;
  const BackupValidationException(this.message);

  @override
  String toString() => 'BackupValidationException: $message';
}

class BackupRestoreResult {
  final SalaryQuestState restoredState;
  final int totalTransactions;
  final int mergedFromBackupCount;

  const BackupRestoreResult({
    required this.restoredState,
    required this.totalTransactions,
    required this.mergedFromBackupCount,
  });
}

class BackupRestoreService {
  static const int currentSchemaVersion = 1;

  /// Serializes and encrypts the complete app state into an AES ciphertext string.
  static Future<String> exportEncryptedBackup({
    required SalaryQuestState state,
    required LocalSecurityService securityService,
    String? password,
  }) async {
    final payloadMap = {
      'schemaVersion': currentSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'cycle': state.cycle.toJson(),
      'dailyBudgets': state.dailyBudgets.map((b) => b.toJson()).toList(),
      'transactions': state.transactions.map((t) => t.toJson()).toList(),
      'hero': state.hero.toJson(),
      'savingsGoals': state.savingsGoals.map((g) => g.toJson()).toList(),
      'achievements': state.achievements.map((a) => a.toJson()).toList(),
      'userSettings': {
        'isSeriousMode': state.isSeriousMode,
        'isBiometricLockEnabled': state.isBiometricLockEnabled,
        'isReduceMotion': state.isReduceMotion,
        'notificationsEnabled': state.notificationsEnabled,
        'isAutoFlowSavingsEnabled': state.isAutoFlowSavingsEnabled,
        'autoFlowGoalId': state.autoFlowGoalId,
        'languageCode': state.languageCode,
      },
    };

    final plainJson = jsonEncode(payloadMap);
    if (password != null && password.isNotEmpty) {
      // Portable: works on a new phone with the same password
      return await securityService.encryptWithPassword(plainJson, password);
    }
    return await securityService.encrypt(plainJson);
  }

  /// Decrypts ciphertext and merges incoming transactions with existing local records
  /// using [DataConflictResolver] (Latest-Edit-Wins with zero duplicate creation).
  static Future<BackupRestoreResult> restoreEncryptedBackup({
    required String encryptedData,
    required SalaryQuestState currentState,
    required LocalSecurityService securityService,
    String? password,
  }) async {
    if (encryptedData.trim().isEmpty) {
      throw const BackupValidationException('Encrypted backup string is empty.');
    }

    String plainJson;
    try {
      if (LocalSecurityService.isPasswordProtected(encryptedData)) {
        if (password == null || password.isEmpty) {
          throw const BackupDecryptionException(
            'This backup is password-protected. Enter the backup password.',
          );
        }
        plainJson = await securityService.decryptWithPassword(
            encryptedData.trim(), password);
      } else {
        plainJson = await securityService.decrypt(encryptedData.trim());
      }
    } on BackupDecryptionException {
      rethrow;
    } catch (e) {
      throw BackupDecryptionException(
        'Decryption failed: invalid security key or corrupted backup data. ($e)',
      );
    }

    if (plainJson.isEmpty || !plainJson.startsWith('{')) {
      throw const BackupDecryptionException(
        'Decryption failed: decrypted content is not valid JSON or key mismatch.',
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(plainJson) as Map<String, dynamic>;
    } catch (e) {
      throw BackupValidationException('Corrupted backup structure: $e');
    }

    final version = data['schemaVersion'] as int? ?? 0;
    if (version < 1) {
      throw const BackupValidationException(
        'Unsupported backup version. Please update the application.',
      );
    }

    // 1. Parse incoming transactions
    final incomingTxList = (data['transactions'] as List<dynamic>?)
            ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // 2. Conflict Resolution: Merge using DataConflictResolver (Latest-Edit-Wins)
    final mergedTransactions = DataConflictResolver.mergeTransactions(
      localTransactions: currentState.transactions,
      incomingTransactions: incomingTxList,
    );

    // 3. Restore or merge BudgetCycle
    BudgetCycle restoredCycle;
    if (data['cycle'] != null) {
      restoredCycle =
          BudgetCycle.fromJson(data['cycle'] as Map<String, dynamic>);
    } else {
      restoredCycle = currentState.cycle;
    }

    // 4. Determine current day index
    final now = DateTime.now();
    final currentDayIndex = CycleDateCalculator.getDayIndexForTimestamp(
      timestamp: now,
      cycleStartDate: restoredCycle.startDate,
      totalDays: restoredCycle.totalDays,
    );

    // 5. Recompute daily budgets, transactions, and boss HP using merged transactions
    final recomputeResult = TransactionEventRecomputer.recompute(
      cycle: restoredCycle,
      transactions: mergedTransactions,
      currentDayIndex: currentDayIndex,
    );

    // 6. Merge Savings Goals (preserve local goals, add/update incoming)
    final Map<String, SavingsGoal> goalMap = {
      for (final g in currentState.savingsGoals) g.id: g,
    };
    if (data['savingsGoals'] != null) {
      for (final gJson in data['savingsGoals'] as List<dynamic>) {
        final incomingGoal =
            SavingsGoal.fromJson(gJson as Map<String, dynamic>);
        if (!goalMap.containsKey(incomingGoal.id)) {
          goalMap[incomingGoal.id] = incomingGoal;
        } else {
          // If goal exists in both, keep the one with higher saved amount
          final existing = goalMap[incomingGoal.id]!;
          if (incomingGoal.savedAmount > existing.savedAmount) {
            goalMap[incomingGoal.id] = incomingGoal;
          }
        }
      }
    }

    // 6. Merge Hero Character stats (take higher progress)
    HeroCharacter restoredHero;
    if (data['hero'] != null) {
      final incomingHero =
          HeroCharacter.fromJson(data['hero'] as Map<String, dynamic>);
      final skinSet = {
        ...currentState.hero.unlockedSkins,
        ...incomingHero.unlockedSkins,
      }.toList();
      final themeSet = {
        ...currentState.hero.unlockedThemes,
        ...incomingHero.unlockedThemes,
      }.toList();

      restoredHero = currentState.hero.copyWith(
        level: incomingHero.level > currentState.hero.level
            ? incomingHero.level
            : currentState.hero.level,
        currentXp: incomingHero.currentXp > currentState.hero.currentXp
            ? incomingHero.currentXp
            : currentState.hero.currentXp,
        coins: incomingHero.coins > currentState.hero.coins
            ? incomingHero.coins
            : currentState.hero.coins,
        streakDays: incomingHero.streakDays > currentState.hero.streakDays
            ? incomingHero.streakDays
            : currentState.hero.streakDays,
        unlockedSkins: skinSet,
        unlockedThemes: themeSet,
      );
    } else {
      restoredHero = currentState.hero;
    }

    // 7. Merge Achievements
    final Map<String, Achievement> achMap = {
      for (final a in currentState.achievements) a.id: a,
    };
    if (data['achievements'] != null) {
      for (final aJson in data['achievements'] as List<dynamic>) {
        final incomingAch =
            Achievement.fromJson(aJson as Map<String, dynamic>);
        if (!achMap.containsKey(incomingAch.id) ||
            (incomingAch.isUnlocked && !achMap[incomingAch.id]!.isUnlocked)) {
          achMap[incomingAch.id] = incomingAch;
        }
      }
    }

    // 8. User Settings
    final settingsJson = data['userSettings'] as Map<String, dynamic>?;
    final isSeriousMode = settingsJson?['isSeriousMode'] as bool? ??
        currentState.isSeriousMode;
    final isReduceMotion = settingsJson?['isReduceMotion'] as bool? ??
        currentState.isReduceMotion;
    final isAutoFlow = settingsJson?['isAutoFlowSavingsEnabled'] as bool? ??
        currentState.isAutoFlowSavingsEnabled;
    final autoFlowGoalId = settingsJson?['autoFlowGoalId'] as String? ??
        currentState.autoFlowGoalId;
    final languageCode = settingsJson?['languageCode'] as String? ??
        currentState.languageCode;

    final targetRupees = restoredCycle.savingsTargetAmount.inWholeRupees > 0
        ? restoredCycle.savingsTargetAmount.inWholeRupees
        : restoredCycle.discretionaryPool.inWholeRupees;

    final restoredState = currentState.copyWith(
      cycle: restoredCycle,
      dailyBudgets: recomputeResult.budgets,
      transactions: recomputeResult.updatedTransactions,
      savingsGoals: goalMap.values.toList(),
      hero: restoredHero,
      achievements: achMap.values.toList(),
      bossCurrentHp: recomputeResult.bossHp,
      bossMaxHp: targetRupees,
      currentDayIndex: currentDayIndex,
      isSeriousMode: isSeriousMode,
      isReduceMotion: isReduceMotion,
      isAutoFlowSavingsEnabled: isAutoFlow,
      autoFlowGoalId: autoFlowGoalId,
      languageCode: languageCode,
      isOnboarded: true,
    );

    return BackupRestoreResult(
      restoredState: restoredState,
      totalTransactions: mergedTransactions.length,
      mergedFromBackupCount: incomingTxList.length,
    );
  }
}
