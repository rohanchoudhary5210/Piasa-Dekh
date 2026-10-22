import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';

void main() {
  final parser = SmsParserService();

  test('UPI Mandate sent amount and merchant parsing', () {
    final testCases = [
      (
        'Dear SBI UPI User, mandate has been set successfully for Netflix. Sent amount Rs 499.00. Ref 123456.',
        'Netflix',
        499.0
      ),
      (
        'UPI Mandate set: Max limit Rs 5000. Sent amount: Rs 199.00 to Spotify India. Next debit 23-Nov.',
        'Spotify',
        199.0
      ),
      (
        'Mandate set for Rs 1200.00 towards Hotstar. Rs 1200.00 sent from A/c XX1234.',
        'Hotstar',
        1200.0
      ),
      (
        'AutoPay set for YouTube Premium. Amount sent: Rs 149.00 from Kotak Bank A/c 5678.',
        'YouTube',
        149.0
      ),
      (
        'UPI AutoPay: Mandate created for Tata Mutual Fund. Sent Rs 1000.00. Auth code: 998811.',
        'Tata Mutual Fund',
        1000.0
      ),
      (
        'Your mandate request for Rs. 299 towards Hotstar is successful. Rs 299 debited. Next execution pending.',
        'Hotstar',
        299.0
      ),
    ];

    for (final tc in testCases) {
      final body = tc.$1;
      final expectedMerchantKeyword = tc.$2;
      final expectedAmount = tc.$3;

      final res = parser.parse(sender: 'HDFC-BANK', body: body);
      expect(res.isFinancial, isTrue, reason: 'Must be financial: $body');
      expect(res.isIgnored, isFalse, reason: 'Must not be ignored: $body');
      expect(res.type, equals(ParsedSmsType.debit), reason: 'Must be debit: $body');
      expect(res.amount?.inWholeRupees, equals(expectedAmount.toInt()), reason: 'Amount mismatch for: $body');
      expect(res.cleanedMerchant.toLowerCase(), contains(expectedMerchantKeyword.toLowerCase()),
          reason: 'Merchant should contain $expectedMerchantKeyword in ${res.cleanedMerchant}');
    }
  });

  test('AutoPay & Mandate intelligent category classification', () {
    final catCases = [
      ('HDFC Bank: Rs 499.00 debited for Netflix subscription.', TransactionCategory.entertainment),
      ('SBI: Mandate set for Spotify. Sent amount: Rs 199.00.', TransactionCategory.entertainment),
      ('Kotak: Rs 149 debited for YouTube Premium auto-debit.', TransactionCategory.entertainment),
      ('Axis: Mandate set for Tata Mutual Fund. Sent Rs 1000.00.', TransactionCategory.bills),
      ('ICICI: Rs 799 debited for Airtel broadband bill payment.', TransactionCategory.bills),
      ('SBI: Rs 340 debited for Swiggy food order.', TransactionCategory.food),
      ('HDFC: Rs 520 debited at Blinkit grocery store.', TransactionCategory.groceries),
      ('Axis: Rs 240 debited for Uber ride payment.', TransactionCategory.transport),
      ('SBI: Rs 1499 debited for Amazon order.', TransactionCategory.shopping),
      ('ICICI: Rs 650 debited at Apollo Pharmacy.', TransactionCategory.health),
    ];

    for (final tc in catCases) {
      final res = parser.parse(sender: 'BANK', body: tc.$1);
      expect(res.inferredCategory, equals(tc.$2),
          reason: 'Category mismatch for: "${tc.$1}" (got ${res.inferredCategory.name}, expected ${tc.$2.name})');
    }
  });

  test('UPI Mandate Cancellation / Revocation detection', () {
    final revokeCases = [
      'Dear SBI UPI User, mandate for Netflix (UMN: 123456) has been cancelled successfully.',
      'Your UPI AutoPay mandate towards Tata Mutual Fund of Rs 2000 has been revoked.',
      'HDFC Bank: e-mandate cancelled for Hotstar on 22-OCT-26.',
      'UPI AutoPay mandate for YouTube has been paused.',
      'Mandate deleted successfully for merchant Spotify.',
    ];

    for (final body in revokeCases) {
      final res = parser.parse(sender: 'HDFC-BANK', body: body);
      expect(res.isMandateRevoked, isTrue, reason: 'Must be recognized as mandate revocation: $body');
      expect(res.type, equals(ParsedSmsType.mandateRevoked), reason: 'Type must be mandateRevoked: $body');
      expect(res.isFinancial, isFalse, reason: 'Cancellation should not be debit expense: $body');
      expect(res.isIgnored, isFalse, reason: 'Must not be ignored as failed txn: $body');
      expect(res.cleanedMerchant, isNot(equals('Unknown merchant')), reason: 'Merchant must be identified: $body');
    }
  });
}
