import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

/// Handles data synchronization and backup conflict resolution between two devices or
/// between local SQLite storage and a cloud backup file.
///
/// Conflict Strategy:
/// 1. Primary Key identity merge: Each transaction is uniquely identified by its [Transaction.id].
/// 2. If a transaction exists on only one device, it is seamlessly merged without data loss.
/// 3. If a transaction exists on both devices, the "Latest-Edit-Wins" rule applies:
///    The version with the latest timestamp is preserved.
/// 4. Deduplication key collision: If two distinct IDs share the exact same deduplication key,
///    the earlier record is preserved and duplicate is suppressed.
class DataConflictResolver {
  /// Resolves conflicts and merges local transactions with imported backup transactions.
  static List<Transaction> mergeTransactions({
    required List<Transaction> localTransactions,
    required List<Transaction> incomingTransactions,
  }) {
    final Map<String, Transaction> mergedById = {};

    // 1. Seed with local transactions
    for (final tx in localTransactions) {
      mergedById[tx.id] = tx;
    }

    // 2. Merge incoming transactions using Latest-Edit-Wins
    for (final incoming in incomingTransactions) {
      if (!mergedById.containsKey(incoming.id)) {
        mergedById[incoming.id] = incoming;
      } else {
        final existing = mergedById[incoming.id]!;
        // Latest-edit-wins rule
        if (incoming.timestamp.isAfter(existing.timestamp)) {
          mergedById[incoming.id] = incoming;
        }
      }
    }

    // 3. Deduplicate by dedupeKey if both transactions have non-empty keys
    final Map<String, Transaction> deduplicated = {};
    for (final tx in mergedById.values) {
      final key = tx.dedupeKey;
      if (key != null && key.isNotEmpty) {
        if (!deduplicated.containsKey(key)) {
          deduplicated[key] = tx;
        } else {
          // If dedupe collision, prefer the one with more metadata or earlier timestamp
          final existing = deduplicated[key]!;
          if (tx.timestamp.isBefore(existing.timestamp)) {
            deduplicated[key] = tx;
          }
        }
      } else {
        // Without dedupeKey, ID is unique
        deduplicated[tx.id] = tx;
      }
    }

    final result = deduplicated.values.toList();
    // Sort descending by timestamp (newest first)
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }
}
