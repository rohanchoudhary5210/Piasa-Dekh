import 'package:flutter/material.dart';
import 'package:salary_quest/core/constants/app_colors.dart';
import 'package:salary_quest/core/models/money.dart';
import 'package:salary_quest/features/transactions/domain/models/transaction.dart';
import 'package:salary_quest/features/transactions/domain/services/fixed_expense_matcher.dart';

class AddTransactionSheet extends StatefulWidget {
  final Function({
    required Money amount,
    required String title,
    required TransactionCategory category,
    TransactionType type,
    bool isFixedExpense,
    Money? splitTotal,
    Money? splitUserShare,
  }) onAdd;

  const AddTransactionSheet({super.key, required this.onAdd});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _myShareController = TextEditingController();

  TransactionCategory _selectedCategory = TransactionCategory.food;
  TransactionType _selectedType = TransactionType.expense;
  bool _isFixedExpense = false;

  final List<Map<String, dynamic>> _quickPresets = [
    {
      'title': 'Chai / Coffee',
      'money': Money.fromRupees(20),
      'cat': TransactionCategory.food
    },
    {
      'title': 'Quick Lunch',
      'money': Money.fromRupees(150),
      'cat': TransactionCategory.food
    },
    {
      'title': 'Metro / Auto',
      'money': Money.fromRupees(60),
      'cat': TransactionCategory.transport
    },
    {
      'title': 'Grocery',
      'money': Money.fromRupees(350),
      'cat': TransactionCategory.groceries
    },
    {
      'title': 'Quick Cash',
      'money': Money.fromRupees(100),
      'cat': TransactionCategory.other
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _myShareController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    final money = preset['money'] as Money;
    setState(() {
      _amountController.text = money.inWholeRupees.toString();
      _titleController.text = preset['title'] as String;
      _selectedCategory = preset['cat'] as TransactionCategory;
      _checkFixedExpenseMatch(preset['title'] as String);
    });
  }

  void _checkFixedExpenseMatch(String title) {
    if (FixedExpenseMatcher.isLikelyFixedExpense(title)) {
      setState(() => _isFixedExpense = true);
    }
  }

  void _submit() {
    final money = Money.tryParse(_amountController.text.trim());
    if (money == null || money.paise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory.displayName
        : _titleController.text.trim();

    Money? splitTotal;
    Money? splitUserShare;

    if (_selectedType == TransactionType.splitShare) {
      splitTotal = money;
      final parsedShare = Money.tryParse(_myShareController.text.trim());
      if (parsedShare != null && parsedShare > money) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your personal share cannot exceed the total bill amount'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        return;
      }
      splitUserShare = parsedShare ?? money;
    }

    widget.onAdd(
      amount: money,
      title: title,
      category: _selectedCategory,
      type: _selectedType,
      isFixedExpense: _isFixedExpense,
      splitTotal: splitTotal,
      splitUserShare: splitUserShare,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFixedExpense
              ? 'Fixed Expense Recorded (Pre-budgeted)'
              : _selectedType == TransactionType.refund
                  ? 'Refund Logged (Daily spend reduced)'
                  : _selectedType == TransactionType.transfer
                      ? 'Self Transfer Logged (Neutral impact)'
                      : 'Transaction Logged (+15 XP)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LOG PAYMENT',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    _isFixedExpense
                        ? 'Fixed (0 Spent)'
                        : _selectedType == TransactionType.expense
                            ? '+15 XP'
                            : _selectedType.displayName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Transaction Type Selector Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('Expense', TransactionType.expense),
                  const SizedBox(width: 8),
                  _buildTypeChip('Split Bill', TransactionType.splitShare),
                  const SizedBox(width: 8),
                  _buildTypeChip('Refund', TransactionType.refund),
                  const SizedBox(width: 8),
                  _buildTypeChip('Self Transfer', TransactionType.transfer),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Quick presets
            if (_selectedType == TransactionType.expense)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickPresets.map((preset) {
                    final money = preset['money'] as Money;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: AppColors.surfaceElevated,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: Text(
                          '${preset['title']} ${money.format()}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _applyPreset(preset),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Amount field
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),

            // Split Bill - User's share field
            if (_selectedType == TransactionType.splitShare) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _myShareController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: 'Your Personal Share (₹)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'e.g. 500 (balance will be tracked as pending)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Title field
            TextField(
              controller: _titleController,
              onChanged: _checkFixedExpenseMatch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Merchant / Description',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Swiggy, Uber, Chai Point, Rent',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Fixed Expense Checkbox
            Theme(
              data: ThemeData(unselectedWidgetColor: AppColors.textMuted),
              child: CheckboxListTile(
                value: _isFixedExpense,
                activeColor: Colors.white,
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text(
                  'Fixed Expense (Pre-budgeted)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Pre-allocated from salary; does not reduce daily discretionary budget.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                onChanged: (val) {
                  setState(() => _isFixedExpense = val ?? false);
                },
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'CATEGORY',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransactionCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.displayName),
                  selected: isSelected,
                  selectedColor: Colors.white,
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.white
                        : AppColors.surfaceBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'CONFIRM PAYMENT',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.white,
      backgroundColor: AppColors.surfaceElevated,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textSecondary,
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? Colors.white : AppColors.surfaceBorder,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
    );
  }
}
