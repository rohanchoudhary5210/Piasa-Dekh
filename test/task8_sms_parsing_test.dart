import 'package:flutter_test/flutter_test.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/transactions/domain/services/sms_parser_service.dart';

void main() {
  group('TASK 8 - SECTION C: SMS & Notification Parsing Tests', () {
    late SmsParserService parser;

    setUp(() {
      parser = SmsParserService();
    });

    test('1. Bank Formats: Correctly extracts amounts from Rs., INR, and ₹ symbols', () {
      final now = DateTime(2026, 10, 15, 12, 0);

      // Rs. format (HDFC)
      final hdfc = parser.parse(
        sender: 'VK-HDFCBK',
        body: 'Rs. 1,450.50 debited from a/c XX1029 on 15-10-26 towards Amazon.',
        timestamp: now,
      );
      expect(hdfc.amount, equals(Money.fromRupees(1450.50)));
      expect(hdfc.type, equals(ParsedSmsType.debit));
      expect(hdfc.cleanedMerchant, equals('Amazon'));

      // INR format (ICICI)
      final icici = parser.parse(
        sender: 'BZ-ICICIB',
        body: 'Acct XX5543 debited for INR 99.50 on 15-Oct-26. Info: Uber.',
        timestamp: now,
      );
      expect(icici.amount, equals(Money.fromRupees(99.50)));
      expect(icici.type, equals(ParsedSmsType.debit));
      expect(icici.cleanedMerchant, equals('Uber'));

      // ₹ symbol (SBI / UPI)
      final sbi = parser.parse(
        sender: 'SBIINB',
        body: 'Dear SBI User, your A/c ending 8812 debited by ₹3,500 on 15Oct26 transfer to Zomato.',
        timestamp: now,
      );
      expect(sbi.amount, equals(Money.fromRupees(3500)));
      expect(sbi.type, equals(ParsedSmsType.debit));
      expect(sbi.cleanedMerchant, equals('Zomato'));

      // Very large amount (₹1,00,00,000)
      final largeSms = parser.parse(
        sender: 'KOTAKB',
        body: 'Alert: Rs 1,00,00,000 debited from A/c XX9999 towards Property Purchase.',
        timestamp: now,
      );
      expect(largeSms.amount, equals(Money.fromRupees(10000000)));
    });

    test('2. Debit keywords: debited, spent, sent, paid to all categorized as Debit', () {
      final now = DateTime.now();

      final s1 = parser.parse(sender: 'HDFC', body: 'Rs 500 debited from card XX1234', timestamp: now);
      final s2 = parser.parse(sender: 'Axis', body: 'You have spent INR 1200 at Starbucks', timestamp: now);
      final s3 = parser.parse(sender: 'GPay', body: 'Sent ₹300 to Chai Point', timestamp: now);
      final s4 = parser.parse(sender: 'PhonePe', body: 'Paid to Blinkit ₹450', timestamp: now);

      expect(s1.type, equals(ParsedSmsType.debit));
      expect(s2.type, equals(ParsedSmsType.debit));
      expect(s3.type, equals(ParsedSmsType.debit));
      expect(s4.type, equals(ParsedSmsType.debit));
    });

    test('3. Credit Received: Refund, Salary, P2P Money received categorized as Credit (not Debit)', () {
      final now = DateTime.now();

      // Salary credit
      final salary = parser.parse(
        sender: 'HDFC',
        body: 'Your salary of Rs 1,20,000.00 is credited to account XX1234.',
        timestamp: now,
      );
      expect(salary.type, equals(ParsedSmsType.credit));
      expect(salary.amount, equals(Money.fromRupees(120000)));

      // Refund
      final refund = parser.parse(
        sender: 'ICICI',
        body: 'Refund of INR 850.00 credited back to your account XX5678.',
        timestamp: now,
      );
      expect(refund.type, equals(ParsedSmsType.credit));
      expect(refund.amount, equals(Money.fromRupees(850)));

      // Friend transferred money to me
      final p2p = parser.parse(
        sender: 'SBI',
        body: 'A/c XX4321 credited by ₹2,000 received from Amit Sharma.',
        timestamp: now,
      );
      expect(p2p.type, equals(ParsedSmsType.credit));
      expect(p2p.amount, equals(Money.fromRupees(2000)));
    });

    test('4. Noise Filtering: OTP, Promotional, and Fraud Alerts are strictly ignored', () {
      final now = DateTime.now();

      // OTP SMS
      final otp = parser.parse(
        sender: 'VK-HDFCBK',
        body: '123456 is your secret OTP for transaction of Rs 500.00 at Swiggy. Do not share.',
        timestamp: now,
      );
      expect(otp.isIgnored, isTrue);
      expect(otp.isFinancial, isFalse);
      expect(otp.type, equals(ParsedSmsType.otpPromoSpam));

      // Promotional Spam
      final promo = parser.parse(
        sender: 'DM-LOANS',
        body: 'Congratulations! You are pre-approved for a personal loan of Rs. 5,00,000. Apply now!',
        timestamp: now,
      );
      expect(promo.isIgnored, isTrue);
      expect(promo.isFinancial, isFalse);
      expect(promo.type, equals(ParsedSmsType.otpPromoSpam));

      // Fraud Security Warning
      final securityAlert = parser.parse(
        sender: 'SBIINB',
        body: 'Fraud alert: If you did not request internet banking password reset, call immediately.',
        timestamp: now,
      );
      expect(securityAlert.isIgnored, isTrue);
      expect(securityAlert.isFinancial, isFalse);
    });

    test('5. Failed and Pending UPI Transactions are detected and marked ignored', () {
      final now = DateTime.now();

      final failed = parser.parse(
        sender: 'PhonePe',
        body: 'Payment of ₹1,500 to Uber failed. If debited, amount will be refunded in 3 business days.',
        timestamp: now,
      );

      expect(failed.type, equals(ParsedSmsType.failedOrPending));
      expect(failed.isIgnored, isTrue);
      expect(failed.isFinancial, isFalse);

      final declined = parser.parse(
        sender: 'Axis',
        body: 'Your txn of Rs 250 at Cafe Coffee Day was declined due to insufficient balance.',
        timestamp: now,
      );
      expect(declined.type, equals(ParsedSmsType.failedOrPending));
      expect(declined.isIgnored, isTrue);
    });

    test('6. Merchant Cleaning: UPI IDs and crypted merchant codes are cleaned, gibberish falls back to Unknown', () {
      final now = DateTime.now();

      // Raw UPI ID cleaned to brand name
      final upi1 = parser.parse(
        sender: 'GPay',
        body: 'Paid ₹280 to swiggy@hdfcbank on 15-Oct-26.',
        timestamp: now,
      );
      expect(upi1.cleanedMerchant, equals('Swiggy'));

      // POS machine prefix stripped
      final upi2 = parser.parse(
        sender: 'Paytm',
        body: 'Paid ₹85 to PAYTM-UBER1234 on 15-Oct-26.',
        timestamp: now,
      );
      expect(upi2.cleanedMerchant, equals('Uber'));

      // Unparseable / gibberish merchant falls back to Unknown merchant and marks needsReview
      final gibberish = parser.parse(
        sender: 'VK-BANK',
        body: 'Rs 500 debited from a/c XX1234 on 15-Oct-26 to 0000000000.',
        timestamp: now,
      );
      expect(gibberish.cleanedMerchant, equals('Unknown merchant'));
      expect(gibberish.needsReview, isTrue);
    });

    test('7. Unknown new bank format goes to needs review inbox instead of guessing or silent drop', () {
      final now = DateTime.now();

      final weirdFormat = parser.parse(
        sender: 'NEWCOOPBK',
        body: 'Account notice: Transaction token 8829 recorded on system.',
        timestamp: now,
      );

      expect(weirdFormat.type, equals(ParsedSmsType.unknown));
      expect(weirdFormat.isFinancial, isFalse);
      expect(weirdFormat.needsReview, isTrue);
    });

    test('8. OEM Background Kill: Detects silence > 72 hours and returns manufacturer whitelist instructions', () {
      final now = DateTime(2026, 10, 20, 10, 0);

      // Last event 4 days ago (> 72 hours)
      final fourDaysAgo = now.subtract(const Duration(days: 4));
      expect(
        OemBackgroundDetector.isListenerSilent(lastReceivedEvent: fourDaysAgo, now: now),
        isTrue,
      );

      // Last event 10 hours ago (< 72 hours)
      final tenHoursAgo = now.subtract(const Duration(hours: 10));
      expect(
        OemBackgroundDetector.isListenerSilent(lastReceivedEvent: tenHoursAgo, now: now),
        isFalse,
      );

      // Whitelist instructions for Xiaomi, Samsung, Oppo, Vivo
      final xiaomi = OemBackgroundDetector.getWhitelistInstructions('Xiaomi');
      expect(xiaomi, contains('MIUI aggressive battery saver'));
      expect(xiaomi, contains('Autostart'));

      final samsung = OemBackgroundDetector.getWhitelistInstructions('Samsung');
      expect(samsung, contains('Never sleeping apps'));

      final oppo = OemBackgroundDetector.getWhitelistInstructions('OnePlus');
      expect(oppo, contains('Allow background activity'));

      final vivo = OemBackgroundDetector.getWhitelistInstructions('Vivo');
      expect(vivo, contains('High background power consumption'));
    });

    test('9. Bulk History Import: 6 months of historical SMS parsed in batched micro-chunks with progress reporting', () async {
      // Simulate 200 SMS messages
      final messages = List.generate(
        200,
        (i) => RawSmsMessage(
          sender: 'VK-HDFCBK',
          body: 'Rs ${100 + i}.00 debited from A/c XX1234 towards Swiggy on 15-Oct-26.',
          timestamp: DateTime(2026, 10, 15).subtract(Duration(hours: i)),
        ),
      );

      int progressReports = 0;
      int lastReportedTotal = 0;

      final results = await parser.parseBatch(
        messages,
        chunkSize: 50,
        onProgress: (processed, total) {
          progressReports++;
          lastReportedTotal = total;
        },
      );

      expect(results.length, equals(200));
      expect(progressReports, equals(4)); // 200 / 50 = 4 chunks
      expect(lastReportedTotal, equals(200));
      expect(results.every((r) => r.isFinancial && r.cleanedMerchant == 'Swiggy'), isTrue);
    });
  });
}
