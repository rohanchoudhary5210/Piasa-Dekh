import 'dart:async';
import 'package:flutter/services.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';

class NativeSmsService {
  static const MethodChannel _methodChannel =
      MethodChannel('com.salaryquest.salary_quest/sms');
  static const EventChannel _eventChannel =
      EventChannel('com.salaryquest.salary_quest/sms_stream');

  final SmsParserService _parser;
  StreamSubscription? _smsSubscription;

  NativeSmsService({SmsParserService? parser})
      : _parser = parser ?? SmsParserService();

  /// Check whether RECEIVE_SMS and READ_SMS permissions are granted.
  Future<bool> checkPermission() async {
    try {
      final bool? isGranted =
          await _methodChannel.invokeMethod<bool>('checkSmsPermission');
      return isGranted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request SMS permissions from the user.
  Future<bool> requestPermission() async {
    try {
      final bool? isGranted =
          await _methodChannel.invokeMethod<bool>('requestSmsPermission');
      return isGranted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Start listening for real-time incoming bank SMS messages.
  void startListening({
    required Function(ParsedSmsResult result) onTransactionDetected,
  }) {
    _smsSubscription?.cancel();
    try {
      _smsSubscription = _eventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            final sender = event['sender']?.toString() ?? '';
            final body = event['body']?.toString() ?? '';
            final timestampMillis = event['timestamp'] as int?;
            final timestamp = timestampMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(timestampMillis)
                : DateTime.now();

            final parsed = _parser.parse(
              sender: sender,
              body: body,
              timestamp: timestamp,
            );

            if ((parsed.isFinancial && !parsed.isIgnored && parsed.amount != null) ||
                parsed.isMandateRevoked) {
              onTransactionDetected(parsed);
            }
          }
        },
        onError: (_) {},
      );
    } catch (_) {
      // Event channel unavailable (e.g. running in test or desktop environment)
    }
  }

  /// Stop listening for incoming SMS messages.
  void stopListening() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
  }

  /// Reads bank SMS received today (from 12:00 AM midnight onwards).
  Future<List<ParsedSmsResult>> syncTodayBankSms({DateTime? since}) async {
    final now = DateTime.now();
    final todayMidnight = since ?? DateTime(now.year, now.month, now.day);
    return syncBankSmsSince(todayMidnight);
  }

  /// Scan bank messages received since the exact [since] DateTime.
  Future<List<ParsedSmsResult>> syncBankSmsSince(
    DateTime since, {
    int limit = 100,
  }) async {
    final results = <ParsedSmsResult>[];
    try {
      final rawList = await _methodChannel.invokeMethod<List<dynamic>>(
        'readRecentBankSms',
        {
          'sinceTimestamp': since.millisecondsSinceEpoch,
          'limit': limit,
        },
      );

      if (rawList != null) {
        for (final item in rawList) {
          if (item is Map) {
            final sender = item['sender']?.toString() ?? '';
            final body = item['body']?.toString() ?? '';
            final timestampMillis = item['timestamp'] as int?;
            final timestamp = timestampMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(timestampMillis)
                : DateTime.now();

            final parsed = _parser.parse(
              sender: sender,
              body: body,
              timestamp: timestamp,
            );

            if (parsed.isFinancial &&
                !parsed.isIgnored &&
                parsed.amount != null) {
              results.add(parsed);
            }
          }
        }
      }
    } catch (_) {
      // Graceful fallback
    }
    return results;
  }

  /// Scan recent inbox messages from the past [days] days for financial bank debits/credits.
  Future<List<ParsedSmsResult>> syncRecentBankSms({int days = 7, int limit = 50}) async {
    final results = <ParsedSmsResult>[];
    try {
      final rawList = await _methodChannel.invokeMethod<List<dynamic>>(
        'readRecentBankSms',
        {'days': days, 'limit': limit},
      );

      if (rawList != null) {
        for (final item in rawList) {
          if (item is Map) {
            final sender = item['sender']?.toString() ?? '';
            final body = item['body']?.toString() ?? '';
            final timestampMillis = item['timestamp'] as int?;
            final timestamp = timestampMillis != null
                ? DateTime.fromMillisecondsSinceEpoch(timestampMillis)
                : DateTime.now();

            final parsed = _parser.parse(
              sender: sender,
              body: body,
              timestamp: timestamp,
            );

            if (parsed.isFinancial && !parsed.isIgnored && parsed.amount != null) {
              results.add(parsed);
            }
          }
        }
      }
    } catch (_) {
      // Graceful fallback if permission denied or query fails
    }
    return results;
  }
}
