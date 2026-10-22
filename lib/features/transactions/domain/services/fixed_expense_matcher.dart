class FixedExpenseMatcher {
  /// Well-known patterns and keywords for recurring fixed expenses in India.
  static const List<String> defaultKeywords = [
    'rent',
    'house rent',
    'emi',
    'loan',
    'home loan',
    'car loan',
    'personal loan',
    'sip',
    'mutual fund',
    'lic',
    'insurance',
    'premium',
    'wifi',
    'broadband',
    'electricity',
    'bescom',
    'tneb',
    'water bill',
    'gas bill',
    'piped gas',
    'maintenance',
    'society maintenance',
  ];

  /// Checks whether a given transaction title matches known fixed expense patterns
  /// or any user-registered fixed expense names.
  static bool isLikelyFixedExpense(
    String title, {
    List<String> registeredExpenseNames = const [],
  }) {
    if (title.isEmpty) return false;

    final lowerTitle = title.toLowerCase().trim();

    // 1. Check against registered fixed expense names if provided
    for (final registered in registeredExpenseNames) {
      final lowerRegistered = registered.toLowerCase().trim();
      if (lowerRegistered.isNotEmpty && lowerTitle.contains(lowerRegistered)) {
        return true;
      }
    }

    // 2. Check against keyword patterns with word-boundary matching
    // Extract distinct word tokens (letters & digits)
    final words = lowerTitle.split(RegExp(r'[^a-z0-9]+')).toSet();

    for (final keyword in defaultKeywords) {
      if (keyword.contains(' ')) {
        // Multi-word phrase like "house rent", "car loan"
        if (lowerTitle.contains(keyword)) {
          return true;
        }
      } else {
        // Single word like "emi", "sip", "rent", "loan"
        if (words.contains(keyword)) {
          return true;
        }
      }
    }

    return false;
  }
}
