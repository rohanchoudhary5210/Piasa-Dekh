import 'dart:async';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';

/// Nature of an incoming parsed message.
enum ParsedSmsType {
  debit,
  credit,
  failedOrPending,
  otpPromoSpam,
  mandateRevoked,
  unknown,
}

/// Represents the extracted structured data from an Indian banking SMS or push notification.
class ParsedSmsResult {
  final bool isFinancial;
  final ParsedSmsType type;
  final Money? amount;
  final String cleanedMerchant;
  final String? rawMerchant;
  final String? accountReference;
  final DateTime timestamp;
  final bool needsReview;
  final bool isIgnored;
  final String? ignoreReason;
  final String dedupeKey;
  final TransactionSource source;
  final TransactionCategory inferredCategory;
  final bool isMandateRevoked;

  const ParsedSmsResult({
    required this.isFinancial,
    required this.type,
    this.amount,
    required this.cleanedMerchant,
    this.rawMerchant,
    this.accountReference,
    required this.timestamp,
    this.needsReview = false,
    this.isIgnored = false,
    this.ignoreReason,
    required this.dedupeKey,
    required this.source,
    this.inferredCategory = TransactionCategory.other,
    this.isMandateRevoked = false,
  });

  /// Converts this parsed SMS to a domain [Transaction] ready for ingestion.
  Transaction? toTransaction({
    required String cycleId,
    TransactionCategory? category,
  }) {
    if (!isFinancial || amount == null || isIgnored) return null;

    final resolvedCategory = category ?? inferredCategory;

    TransactionType txType;
    switch (type) {
      case ParsedSmsType.debit:
        txType = TransactionType.expense;
        break;
      case ParsedSmsType.credit:
        txType = TransactionType.refund;
        break;
      default:
        return null;
    }

    return Transaction(
      id: 'tx_sms_${timestamp.millisecondsSinceEpoch}_${amount!.paise}',
      cycleId: cycleId,
      amount: amount!,
      title: cleanedMerchant,
      category: resolvedCategory,
      timestamp: timestamp,
      type: txType,
      dedupeKey: dedupeKey,
    );
  }
}

/// Pure Dart testable parser for Indian Bank SMS and UPI Push Notifications.
/// Supports HDFC, SBI, ICICI, Axis, Kotak, PNB, Paytm, PhonePe, GPay, Cred, etc.
class SmsParserService {
  // Common OTP / Promo / Spam / Security alert keywords
  static final RegExp _otpRegex = RegExp(
    r'\b(otp|one[- ]time password|verification code|secret code|is your login code)\b',
    caseSensitive: false,
  );

  static final RegExp _promoSpamRegex = RegExp(
    r'\b(congratulations|pre-approved|apply now|win up to|discount|cashback coupon|offer valid|lottery|free gift)\b',
    caseSensitive: false,
  );

  static final RegExp _fraudSecurityRegex = RegExp(
    r'\b(fraud alert|unauthorized|call immediately|compromised|block your card|if not you)\b',
    caseSensitive: false,
  );

  // Failure / Pending indicators
  static final RegExp _failedPendingRegex = RegExp(
    r'\b(declined|failed|unsuccessful|could not be processed|reversed|cancelled)\b',
    caseSensitive: false,
  );

  // Mandate revocation / cancellation indicators
  static final RegExp _mandateRevokeRegex = RegExp(
    r'\b(?:mandate|autopay|e-mandate)\b.*?\b(?:cancelled|revoked|deleted|terminated|stopped|paused)\b|\b(?:cancelled|revoked|deleted|terminated|stopped|paused)\b.*?\b(?:mandate|autopay|e-mandate)\b',
    caseSensitive: false,
  );

  static final RegExp _transactionPendingRegex = RegExp(
    r'\b(payment pending|transaction pending|request pending approval)\b',
    caseSensitive: false,
  );

  // Debit indicators
  static final RegExp _debitRegex = RegExp(
    r'\b(debited|spent|sent|paid|payment|transferred|vpa|purchase|withdrawn|mandate set|autopay set|e-mandate set|mandate created)\b',
    caseSensitive: false,
  );

  // Credit indicators (Refund, Salary, P2P received)
  static final RegExp _creditRegex = RegExp(
    r'\b(credited|refunded|refund|salary|deposited|received|cashback)\b',
    caseSensitive: false,
  );

  // Priority amount patterns for Mandate / AutoPay sent amounts:
  // e.g. "Sent amount Rs 499.00", "Amount sent: Rs. 149", "Rs. 499 sent", "debited Rs 1200"
  static final RegExp _sentAmountRegex = RegExp(
    r'(?:sent\s*(?:amount|amt)?|amount\s*sent|(?:first\s*)?(?:payment|deduction|debit)\s*(?:of)?)\s*[:\-]?\s*(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  static final RegExp _amountSentReversedRegex = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)\s*(?:sent|debited)',
    caseSensitive: false,
  );

  // General Amount extraction: supports Rs., INR, ₹, with commas and paise decimals
  // e.g. Rs. 1,500.50, INR 99.50, ₹10000, Rs 1,00,00,000
  static final RegExp _amountRegex = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // Account reference extraction (A/c XX1234, card ending 4321)
  static final RegExp _accountRegex = RegExp(
    r'(?:a\/c|acct|acc|card|ending)\s*(?:no\.?)?\s*[*xX]*(\d{3,4})',
    caseSensitive: false,
  );

  /// Parses a raw incoming SMS or push notification text.
  ParsedSmsResult parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    TransactionSource source = TransactionSource.smsAuto,
  }) {
    final now = timestamp ?? DateTime.now();
    final lowerBody = body.toLowerCase();
    final hasDebitKeyword = _debitRegex.hasMatch(lowerBody);

    // 1. Filter Out OTPs, Security alerts, Promos, Spam
    // Completed transactions with auth codes must NOT be ignored as login OTPs
    if (_otpRegex.hasMatch(lowerBody) && !hasDebitKeyword) {
      return ParsedSmsResult(
        isFinancial: false,
        type: ParsedSmsType.otpPromoSpam,
        cleanedMerchant: 'OTP Message',
        timestamp: now,
        isIgnored: true,
        ignoreReason: 'OTP / Verification Code message ignored for privacy.',
        dedupeKey: '',
        source: source,
      );
    }

    if (_promoSpamRegex.hasMatch(lowerBody)) {
      return ParsedSmsResult(
        isFinancial: false,
        type: ParsedSmsType.otpPromoSpam,
        cleanedMerchant: 'Promotional Offer',
        timestamp: now,
        isIgnored: true,
        ignoreReason: 'Promotional SMS ignored.',
        dedupeKey: '',
        source: source,
      );
    }

    if (_fraudSecurityRegex.hasMatch(lowerBody) && !hasDebitKeyword) {
      return ParsedSmsResult(
        isFinancial: false,
        type: ParsedSmsType.otpPromoSpam,
        cleanedMerchant: 'Security Warning',
        timestamp: now,
        isIgnored: true,
        ignoreReason: 'Security alert ignored.',
        dedupeKey: '',
        source: source,
      );
    }

    // 2. Extract Amount (Priority given to explicit "sent amount" over mandate limits)
    Money? parsedAmount;
    final sentMatch = _sentAmountRegex.firstMatch(body) ??
        _amountSentReversedRegex.firstMatch(body);
    if (sentMatch != null) {
      final rawAmountStr = sentMatch.group(1)?.replaceAll(',', '');
      if (rawAmountStr != null) {
        parsedAmount = Money.parse(rawAmountStr);
      }
    }

    if (parsedAmount == null) {
      final amountMatch = _amountRegex.firstMatch(body);
      if (amountMatch != null) {
        final rawAmountStr = amountMatch.group(1)?.replaceAll(',', '');
        if (rawAmountStr != null) {
          parsedAmount = Money.parse(rawAmountStr);
        }
      }
    }

    // 3. Extract Account Reference
    String? accountRef;
    final acctMatch = _accountRegex.firstMatch(body);
    if (acctMatch != null) {
      accountRef = acctMatch.group(1);
    }

    // 4. Check for Mandate / AutoPay Revocation or Cancellation FIRST
    // Must precede general failure/cancellation check so active mandate state is updated
    if (_mandateRevokeRegex.hasMatch(lowerBody)) {
      final rawMerchant = _extractRawMerchant(body);
      final cleanMerchant = _cleanMerchantName(rawMerchant);
      final cat = inferCategory(cleanMerchant, body);
      final dedupe = parsedAmount != null
          ? 'REVOKED_${parsedAmount.paise}_${_tenMinuteWindow(now)}_${cleanMerchant.toLowerCase().replaceAll(RegExp(r'\s+'), '')}'
          : 'REVOKED_${_tenMinuteWindow(now)}_${cleanMerchant.toLowerCase().replaceAll(RegExp(r'\s+'), '')}';

      return ParsedSmsResult(
        isFinancial: false,
        type: ParsedSmsType.mandateRevoked,
        amount: parsedAmount,
        cleanedMerchant: cleanMerchant,
        rawMerchant: rawMerchant,
        accountReference: accountRef,
        timestamp: now,
        isIgnored: false,
        ignoreReason: 'UPI Mandate cancelled/revoked for $cleanMerchant',
        dedupeKey: dedupe,
        source: source,
        inferredCategory: cat,
        isMandateRevoked: true,
      );
    }

    // 5. Check for Failed or Pending transactions
    // In mandates, "next execution pending" is a future cycle, NOT current failure
    final hasCompletedDebit = (lowerBody.contains('sent') ||
            lowerBody.contains('debited') ||
            lowerBody.contains('successful')) &&
        parsedAmount != null;
    final isFailedOrPending = _failedPendingRegex.hasMatch(lowerBody) ||
        (_transactionPendingRegex.hasMatch(lowerBody) && !hasCompletedDebit);

    if (isFailedOrPending) {
      final dedupe = parsedAmount != null
          ? 'FAILED_${parsedAmount.paise}_${_tenMinuteWindow(now)}'
          : '';
      return ParsedSmsResult(
        isFinancial: false,
        type: ParsedSmsType.failedOrPending,
        amount: parsedAmount,
        cleanedMerchant: 'Failed / Pending Transaction',
        timestamp: now,
        isIgnored: true,
        ignoreReason: 'Failed, declined, or reversed transaction ignored.',
        dedupeKey: dedupe,
        source: source,
      );
    }

    // 6. Determine Debit vs Credit
    final isDebit = hasDebitKeyword;
    final isCredit = _creditRegex.hasMatch(lowerBody);

    ParsedSmsType smsType;
    if (isDebit && !isCredit) {
      smsType = ParsedSmsType.debit;
    } else if (isCredit && !isDebit) {
      smsType = ParsedSmsType.credit;
    } else if (isDebit && isCredit) {
      // If body contains both e.g. "debited for refund", prioritize debit if "debited" appears first
      final debitIdx = lowerBody.indexOf(_debitRegex);
      final creditIdx = lowerBody.indexOf(_creditRegex);
      smsType = debitIdx < creditIdx ? ParsedSmsType.debit : ParsedSmsType.credit;
    } else {
      smsType = ParsedSmsType.unknown;
    }

    // 7. Extract & Clean Merchant Name
    final rawMerchant = _extractRawMerchant(body);
    final cleanMerchant = _cleanMerchantName(rawMerchant);

    // 8. Infer Category based on Merchant and SMS contents
    final inferredCat = inferCategory(cleanMerchant, body);

    // 9. Check if unknown new bank format
    final isUnknownFormat = smsType == ParsedSmsType.unknown || parsedAmount == null;

    // 10. Generate cross-source Deduplication Key
    // Standard format: AMOUNT_10MIN_WINDOW_CLEANMERCHANT_DEBIT/CREDIT
    final dedupeKey = parsedAmount != null
        ? '${parsedAmount.paise}_${_tenMinuteWindow(now)}_${cleanMerchant.toLowerCase().replaceAll(RegExp(r'\s+'), '')}_${smsType.name}'
        : '';

    return ParsedSmsResult(
      isFinancial: !isUnknownFormat,
      type: smsType,
      amount: parsedAmount,
      cleanedMerchant: cleanMerchant,
      rawMerchant: rawMerchant,
      accountReference: accountRef,
      timestamp: now,
      needsReview: isUnknownFormat || cleanMerchant == 'Unknown merchant',
      dedupeKey: dedupeKey,
      source: source,
      inferredCategory: inferredCat,
    );
  }

  /// Parses 6 months of historical SMS in batched micro-chunks to ensure zero UI frame drops.
  Future<List<ParsedSmsResult>> parseBatch(
    List<RawSmsMessage> messages, {
    int chunkSize = 50,
    void Function(int processed, int total)? onProgress,
  }) async {
    final results = <ParsedSmsResult>[];
    final total = messages.length;

    for (var i = 0; i < total; i += chunkSize) {
      final end = (i + chunkSize < total) ? i + chunkSize : total;
      for (var j = i; j < end; j++) {
        final msg = messages[j];
        final parsed = parse(
          sender: msg.sender,
          body: msg.body,
          timestamp: msg.timestamp,
        );
        results.add(parsed);
      }
      onProgress?.call(results.length, total);

      // Yield execution to the Flutter event loop so frame rendering continues smoothly
      await Future<void>.delayed(Duration.zero);
    }

    return results;
  }

  /// Extracts the potential raw merchant substring from the SMS body.
  String? _extractRawMerchant(String body) {
    // Patterns like: "paid to <merchant>", "spent at <merchant>", "vpa <upi_id>", "info: <merchant>", "for <merchant>"
    final matches = RegExp(
      r'(?:to|at|vpa|info[:\/]?|towards|merchant[:\s]|for(?:\s+merchant)?)\s+([A-Za-z0-9_\-\.\@\s]{2,30}?)(?:\s+on|\s+ref|\s+txn|\s+sent|\s+debited|\s+amount|\s+has|\s+is|\s+of|\s*\(|\.|\,|$)',
      caseSensitive: false,
    ).allMatches(body);

    for (final match in matches) {
      final candidate = match.group(1)?.trim();
      if (candidate != null &&
          candidate.isNotEmpty &&
          !RegExp(r'^(?:rs\.?|inr|₹|\d+)', caseSensitive: false).hasMatch(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  /// Cleans raw UPI IDs, cryptic POS strings, or merchant noise.
  /// e.g. "swiggy@hdfcbank" -> "Swiggy"
  /// "PAYTM-UBER1234" -> "Uber"
  /// "XYZ_999@okaxis" -> "Unknown merchant" (if gibberish)
  String _cleanMerchantName(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Unknown merchant';
    }

    var text = raw.trim();

    // Strip trailing punctuation like dots, commas, colons
    text = text.replaceAll(RegExp(r'[\.\,\:\;]+$'), '').trim();

    // Strip UPI handle like @hdfcbank, @icici, @paytm, @okaxis
    if (text.contains('@')) {
      text = text.split('@').first;
    }

    // Strip leading vendor prefixes like PAYTM- or RAZORPAY-
    text = text.replaceAll(RegExp(r'^(paytm|razorpay|phonepe|billdesk|bharatpe)[-_]', caseSensitive: false), '');

    // Strip trailing transaction numbers / gibberish IDs like UBER1234 -> Uber
    text = text.replaceAll(RegExp(r'\d+$'), '');

    // Replace underscores/dashes with spaces
    text = text.replaceAll(RegExp(r'[-_]+'), ' ').trim();

    // Known common brand normalizations
    final lower = text.toLowerCase();
    if (lower.contains('swiggy')) return 'Swiggy';
    if (lower.contains('zomato')) return 'Zomato';
    if (lower.contains('uber')) return 'Uber';
    if (lower.contains('ola')) return 'Ola';
    if (lower.contains('amazon')) return 'Amazon';
    if (lower.contains('flipkart')) return 'Flipkart';
    if (lower.contains('blinkit') || lower.contains('grofers')) return 'Blinkit';
    if (lower.contains('zepto')) return 'Zepto';
    if (lower.contains('starbucks')) return 'Starbucks';
    if (lower.contains('netflix')) return 'Netflix';
    if (lower.contains('spotify')) return 'Spotify';
    if (lower.contains('hotstar') || lower.contains('disney')) return 'Hotstar';
    if (lower.contains('youtube')) return 'YouTube';
    if (lower.contains('tata mutual fund') || lower.contains('mutual fund')) return 'Tata Mutual Fund';
    if (lower.contains('zerodha')) return 'Zerodha';
    if (lower.contains('groww')) return 'Groww';
    if (lower.contains('airtel')) return 'Airtel';
    if (lower.contains('jio')) return 'Jio';
    if (lower.contains('tata play')) return 'Tata Play';
    if (lower.contains('cred')) return 'CRED';

    // If result is empty or just random hex/numbers, fall back to "Unknown merchant"
    if (text.length < 2 || RegExp(r'^[0-9a-fA-F]+$').hasMatch(text) || RegExp(r'^[0-9]+$').hasMatch(text)) {
      return 'Unknown merchant';
    }

    // Capitalize first letter of each word
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).join(' ');
  }

  /// Predicts the transaction category based on merchant name and SMS body contents.
  static TransactionCategory inferCategory(String merchant, [String? body]) {
    final text = '${merchant.toLowerCase()} ${(body ?? '').toLowerCase()}';

    // Entertainment: OTT, Streaming, Movies, Music, Gaming
    if (RegExp(r'\b(netflix|spotify|hotstar|disney|prime video|youtube|bookmyshow|pvr|inox|steam|sonyliv|zee5|gaana|jiocinema|apple music|playstation|xbox|audible|subscription|ott|cinema|theatre|gaming)\b').hasMatch(text)) {
      return TransactionCategory.entertainment;
    }

    // Groceries: Quick commerce, Supermarkets, Dairy
    if (RegExp(r'\b(blinkit|zepto|instamart|bigbasket|grofers|dmart|grocery|supermarket|mart|provisions|milk|fruits|vegetables|nature.s basket|country delight|reliance fresh)\b').hasMatch(text)) {
      return TransactionCategory.groceries;
    }

    // Food & Dining: Delivery, Restaurants, Cafes
    if (RegExp(r'\b(swiggy|zomato|starbucks|mcdonald|kfc|burger king|domino|pizza|chai point|cafe coffee day|haldiram|subway|rebel foods|behrouz|faasos|restaurant|cafe|dining|bakery|bakes)\b').hasMatch(text)) {
      return TransactionCategory.food;
    }

    // Commute & Transport: Cabs, Fuel, Metro, Toll, Flights, Rail
    if (RegExp(r'\b(uber|ola|rapido|metro|dmrc|bmrcl|irctc|railway|makemytrip|yatra|indigo|air india|fastag|shell|hpcl|bpcl|iocl|petrol|fuel|diesel|toll|cab|taxi|flight|train|bus)\b').hasMatch(text)) {
      return TransactionCategory.transport;
    }

    // Health & Fitness: Pharmacies, Labs, Clinics, Gyms
    if (RegExp(r'\b(apollo|pharmeasy|1mg|practo|cult\.fit|gym|medplus|netmeds|dr lal|metropolis|hospital|clinic|pharmacy|medicine|diagnostic|fitness)\b').hasMatch(text)) {
      return TransactionCategory.health;
    }

    // Shopping & Retail: E-commerce, Clothing, Electronics
    if (RegExp(r'\b(amazon|flipkart|myntra|ajio|nykaa|meesho|zara|h&m|tata cliq|uniqlo|shoppers stop|lifestyle|westside|decathlon|croma|reliance digital|vijay sales|retail|clothing|fashion)\b').hasMatch(text)) {
      return TransactionCategory.shopping;
    }

    // Bills & Utilities & Investments: Telecom, Electricity, Gas, Mutual Funds, SIP, Insurance, Loans, BBPS, AutoPay
    if (RegExp(r'\b(tata play|airtel|jio|vi|vodafone|idea|mtnl|bsnl|bescom|mseb|adani|tata power|torrent|mahanagar gas|igl|indane|bharat gas|hp gas|lic|hdfc life|max life|sbi life|icici pru|star health|acko|digit|bajaj|emi|loan|cred|billdesk|bbps|recharge|bill|electricity|broadband|wifi|utility|insurance|premium|mutual fund|sip|zerodha|groww|angelone|upstox|mandate|autopay|e-mandate)\b').hasMatch(text)) {
      return TransactionCategory.bills;
    }

    return TransactionCategory.other;
  }

  /// Groups timestamps into identical 10-minute buckets for cross-source deduplication.
  int _tenMinuteWindow(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return ms - (ms % (10 * 60 * 1000));
  }
}

/// Raw SMS input structure for bulk history processing.
class RawSmsMessage {
  final String sender;
  final String body;
  final DateTime timestamp;

  const RawSmsMessage({
    required this.sender,
    required this.body,
    required this.timestamp,
  });
}

/// OEM Background Killer Detector for Xiaomi (MIUI), Oppo (ColorOS), Vivo (Funtouch), Samsung (OneUI).
class OemBackgroundDetector {
  /// Checks if background listener has been dormant for longer than threshold (e.g. 72 hours).
  static bool isListenerSilent({
    required DateTime? lastReceivedEvent,
    required DateTime now,
    Duration threshold = const Duration(hours: 72),
  }) {
    if (lastReceivedEvent == null) return false;
    return now.difference(lastReceivedEvent) > threshold;
  }

  /// Returns actionable, OEM-specific battery optimization whitelist instructions.
  static String getWhitelistInstructions(String manufacturer) {
    final m = manufacturer.toLowerCase();
    if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
      return 'Xiaomi/MIUI aggressive battery saver may kill the SMS listener. Go to Settings > Apps > SalaryQuest > Battery saver > Select "No restrictions", and enable "Autostart".';
    } else if (m.contains('samsung')) {
      return 'Samsung OneUI puts unused apps to sleep. Go to Settings > Battery and device care > Battery > Background usage limits > Add SalaryQuest to "Never sleeping apps".';
    } else if (m.contains('oppo') || m.contains('realme') || m.contains('oneplus')) {
      return 'ColorOS/OxygenOS restricts background tasks. Go to Settings > Battery > App Battery Management > SalaryQuest > Allow background activity & Auto-launch.';
    } else if (m.contains('vivo') || m.contains('iqoo')) {
      return 'Vivo Funtouch OS kills background services. Go to Settings > Battery > High background power consumption > Allow SalaryQuest.';
    }
    return 'Ensure SalaryQuest is excluded from system battery optimizations so automatic SMS tracking functions seamlessly.';
  }
}
