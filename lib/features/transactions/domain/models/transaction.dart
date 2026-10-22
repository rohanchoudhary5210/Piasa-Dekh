import '../../../../core/models/money.dart';

enum TransactionType {
  expense,
  income,
  refund,
  transfer, // self-transfer between own accounts
  walletTopup,
  creditCardBillPayment,
  splitShare,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.transfer:
        return 'Self Transfer';
      case TransactionType.walletTopup:
        return 'Wallet Top-up';
      case TransactionType.creditCardBillPayment:
        return 'Credit Card Bill';
      case TransactionType.splitShare:
        return 'Split Bill';
    }
  }

  /// Whether this transaction affects the user's daily discretionary budget.
  /// Standard expenses, refunds, and split bill shares affect daily budget.
  /// Self-transfers, wallet top-ups, and CC bill payments are neutral (0 impact).
  /// Income adds to the cycle discretionary pool, not day-to-day spending.
  bool get affectsDailyBudget {
    switch (this) {
      case TransactionType.expense:
      case TransactionType.refund:
      case TransactionType.splitShare:
        return true;
      case TransactionType.transfer:
      case TransactionType.walletTopup:
      case TransactionType.creditCardBillPayment:
      case TransactionType.income:
        return false;
    }
  }
}

enum TransactionCategory {
  food,
  transport,
  groceries,
  entertainment,
  bills,
  shopping,
  health,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.transport:
        return 'Commute';
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.entertainment:
        return 'Fun & Gaming';
      case TransactionCategory.bills:
        return 'Bills & Utilities';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Health & Fitness';
      case TransactionCategory.other:
        return 'Misc';
    }
  }

  String get iconSymbol {
    switch (this) {
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚇';
      case TransactionCategory.groceries:
        return '🛒';
      case TransactionCategory.entertainment:
        return '🎮';
      case TransactionCategory.bills:
        return '⚡';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.health:
        return '💊';
      case TransactionCategory.other:
        return '✨';
    }
  }
}

enum TransactionSource {
  manual,
  smsAuto,
  upiNotification,
}

class Transaction {
  final String id;
  final String cycleId;
  final Money amount;
  final String title;
  final TransactionCategory category;
  final DateTime timestamp;
  final TransactionSource source;
  final bool isFixedExpense;
  final TransactionType type;
  final String? dedupeKey;
  final int earnedXp;
  final int earnedCoins;

  // Split bill fields
  final Money? splitTotal;
  final Money? splitUserShare;
  final Money? pendingReimbursement;
  final bool isReimbursement;
  final String? parentTransactionId;

  const Transaction({
    required this.id,
    required this.cycleId,
    required this.amount,
    required this.title,
    required this.category,
    required this.timestamp,
    this.source = TransactionSource.manual,
    this.isFixedExpense = false,
    this.type = TransactionType.expense,
    this.dedupeKey,
    this.earnedXp = 0,
    this.earnedCoins = 0,
    this.splitTotal,
    this.splitUserShare,
    this.pendingReimbursement,
    this.isReimbursement = false,
    this.parentTransactionId,
  });

  /// Computes the net impact of this transaction on the daily budget.
  /// - Positive value increases daily spent (consumes budget).
  /// - Negative value decreases daily spent (refund or reimbursement credited back).
  /// - Zero value means neutral (self-transfer, wallet top-up, CC bill payment, fixed expense).
  Money get netDailyBudgetImpact {
    // Fixed expenses are already deducted from salary upfront at cycle creation.
    if (isFixedExpense) {
      return const Money.zero();
    }

    switch (type) {
      case TransactionType.expense:
        return amount;

      case TransactionType.refund:
        return -amount;

      case TransactionType.splitShare:
        if (isReimbursement) {
          // Incoming reimbursement credits back spent money
          return -amount;
        }
        return amount;

      case TransactionType.transfer:
      case TransactionType.walletTopup:
      case TransactionType.creditCardBillPayment:
      case TransactionType.income:
        return const Money.zero();
    }
  }

  Transaction copyWith({
    String? id,
    String? cycleId,
    Money? amount,
    String? title,
    TransactionCategory? category,
    DateTime? timestamp,
    TransactionSource? source,
    bool? isFixedExpense,
    TransactionType? type,
    String? dedupeKey,
    int? earnedXp,
    int? earnedCoins,
    Money? splitTotal,
    Money? splitUserShare,
    Money? pendingReimbursement,
    bool? isReimbursement,
    String? parentTransactionId,
  }) {
    return Transaction(
      id: id ?? this.id,
      cycleId: cycleId ?? this.cycleId,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      isFixedExpense: isFixedExpense ?? this.isFixedExpense,
      type: type ?? this.type,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      earnedXp: earnedXp ?? this.earnedXp,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      splitTotal: splitTotal ?? this.splitTotal,
      splitUserShare: splitUserShare ?? this.splitUserShare,
      pendingReimbursement: pendingReimbursement ?? this.pendingReimbursement,
      isReimbursement: isReimbursement ?? this.isReimbursement,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycleId': cycleId,
      'amountPaise': amount.paise,
      'title': title,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'source': source.name,
      'isFixedExpense': isFixedExpense,
      'type': type.name,
      'dedupeKey': dedupeKey,
      'earnedXp': earnedXp,
      'earnedCoins': earnedCoins,
      'splitTotalPaise': splitTotal?.paise,
      'splitUserSharePaise': splitUserShare?.paise,
      'pendingReimbursementPaise': pendingReimbursement?.paise,
      'isReimbursement': isReimbursement,
      'parentTransactionId': parentTransactionId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      cycleId: json['cycleId'] as String? ?? 'default_cycle',
      amount: Money.fromPaise(json['amountPaise'] as int? ?? 0),
      title: json['title'] as String? ?? '',
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: TransactionSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => TransactionSource.manual,
      ),
      isFixedExpense: json['isFixedExpense'] as bool? ?? false,
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      dedupeKey: json['dedupeKey'] as String?,
      earnedXp: json['earnedXp'] as int? ?? 0,
      earnedCoins: json['earnedCoins'] as int? ?? 0,
      splitTotal: json['splitTotalPaise'] != null
          ? Money.fromPaise(json['splitTotalPaise'] as int)
          : null,
      splitUserShare: json['splitUserSharePaise'] != null
          ? Money.fromPaise(json['splitUserSharePaise'] as int)
          : null,
      pendingReimbursement: json['pendingReimbursementPaise'] != null
          ? Money.fromPaise(json['pendingReimbursementPaise'] as int)
          : null,
      isReimbursement: json['isReimbursement'] as bool? ?? false,
      parentTransactionId: json['parentTransactionId'] as String?,
    );
  }
}
