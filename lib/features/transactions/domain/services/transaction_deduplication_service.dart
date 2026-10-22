import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/models/money.dart';
import '../models/transaction.dart';

class TransactionDeduplicationService {
  /// Cleans and normalizes merchant / transaction titles by stripping
  /// common bank SMS noise, payment gateway prefixes, reference numbers,
  /// card suffixes, and punctuation.
  static String normalizeMerchant(String rawTitle) {
    if (rawTitle.isEmpty) return '';

    var cleaned = rawTitle.toLowerCase();

    // Remove bank/UPI noise words & prefixes
    final noiseWords = [
      'paid to',
      'debited at',
      'debited for',
      'spent on',
      'payment to',
      'sent to',
      'transfer to',
      'via upi',
      'upi/p2m',
      'upi/p2p',
      'upi',
      'vpa',
      'ref no',
      'rrn',
      'txn',
      'inr',
      'rs.',
      'rs',
      'bank',
      'gpay',
      'phonepe',
      'paytm',
    ];

    for (final noise in noiseWords) {
      cleaned = cleaned.replaceAll(noise, ' ');
    }

    // Remove masked account numbers (e.g. xx1234 or XX8899)
    cleaned = cleaned.replaceAll(RegExp(r'[xX*]{2,}\d+'), ' ');

    // Remove numeric reference strings of 5+ digits
    cleaned = cleaned.replaceAll(RegExp(r'\b\d{5,}\b'), ' ');

    // Remove non-alphanumeric characters (keep single spaces)
    cleaned = cleaned.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    // Normalize multiple spaces to single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Calculates a quantized 10-minute time window index for a timestamp.
  static int get10MinuteBucket(DateTime timestamp) {
    const tenMinutesInMs = 10 * 60 * 1000;
    return timestamp.millisecondsSinceEpoch ~/ tenMinutesInMs;
  }

  /// Computes a deterministic SHA-256 deduplication key for a transaction.
  /// Quantizes the timestamp to a 10-minute window so that notifications
  /// arriving slightly apart map to the same bucket.
  static String computeDedupeKey({
    required Money amount,
    required DateTime timestamp,
    required String merchant,
    TransactionSource? source,
  }) {
    final normalized = normalizeMerchant(merchant);
    final bucket = get10MinuteBucket(timestamp);
    final sourcePart = source != null ? source.name : 'any';

    final payload = '${amount.paise}|$bucket|$normalized|$sourcePart';
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }

  /// Determines whether an incoming transaction is a duplicate of any existing transaction.
  /// Detects duplicates across bank SMS, UPI app notifications, and manual entries
  /// if they occur within a 10-minute window with the same amount and matching merchant.
  static bool isDuplicate({
    required Money amount,
    required DateTime timestamp,
    required String merchant,
    required List<Transaction> existingTransactions,
    int windowMinutes = 10,
    String? explicitDedupeKey,
  }) {
    final candidateNormalized = normalizeMerchant(merchant);
    final candidateWords = candidateNormalized
        .split(' ')
        .where((w) => w.length > 2)
        .toSet();

    for (final existing in existingTransactions) {
      // 1. Direct dedupeKey match (if both computed a key)
      if (explicitDedupeKey != null &&
          existing.dedupeKey != null &&
          explicitDedupeKey == existing.dedupeKey) {
        return true;
      }

      // 2. Exact amount match
      if (existing.amount != amount) continue;

      // 3. Time window check (within +/- windowMinutes, default 10 mins)
      final diffMinutes = existing.timestamp.difference(timestamp).inMinutes.abs();
      if (diffMinutes > windowMinutes) continue;

      // 4. Normalized merchant match
      final existingNormalized = normalizeMerchant(existing.title);
      if (candidateNormalized.isNotEmpty && existingNormalized.isNotEmpty) {
        if (candidateNormalized == existingNormalized) {
          return true;
        }

        // Token overlap check (e.g. "Swiggy Bangalore" and "Swiggy Delivery")
        final existingWords = existingNormalized
            .split(' ')
            .where((w) => w.length > 2)
            .toSet();

        final overlap = candidateWords.intersection(existingWords);
        if (overlap.isNotEmpty) {
          return true;
        }
      } else if (candidateNormalized.isEmpty && existingNormalized.isEmpty) {
        // Both merchants are blank/unspecified and occur within 10 minutes with same amount
        return true;
      }
    }

    return false;
  }
}
