import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:spendly/shared/theme/app_theme.dart';

const _incomeCategories = ['Allowance', 'Salary', 'Gift', 'Side Hustle'];
const _expenseCategories = [
  'Food',
  'Transport',
  'School',
  'Bills',
  'Entertainment',
  'Others',
];

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  late bool _isIncome;
  late String? _selectedCategory;
  late String? _selectedAccountId;
  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  bool _isSaving = false;

  List<String> get _categories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _isIncome = tx.isIncome;
    _selectedCategory = tx.category;
    _selectedAccountId = tx.accountId;
    _selectedDate = tx.date;
    _amountController =
        TextEditingController(text: tx.amount.toStringAsFixed(2));
    _notesController = TextEditingController(text: tx.notes ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnackBar('Please enter an amount');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Enter a valid amount');
      return;
    }
    if (_selectedCategory == null) {
      _showSnackBar('Please select a category');
      return;
    }

    setState(() => _isSaving = true);

    final updated = TransactionModel(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      type: _isIncome ? 'income' : 'expense',
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
      accountId: _selectedAccountId,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: widget.transaction.createdAt,
    );

    await ref.read(transactionsProvider.notifier).updateTransaction(updated);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Transaction',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(transactionsProvider.notifier)
          .delete(widget.transaction.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Transaction',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.expense),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _TypeTab(
                    label: 'Income',
                    isSelected: _isIncome,
                    color: AppColors.income,
                    onTap: () => setState(() {
                      _isIncome = true;
                      if (!_incomeCategories.contains(_selectedCategory)) {
                        _selectedCategory = null;
                      }
                    }),
                  ),
                  _TypeTab(
                    label: 'Expense',
                    isSelected: !_isIncome,
                    color: AppColors.expense,
                    onTap: () => setState(() {
                      _isIncome = false;
                      if (!_expenseCategories.contains(_selectedCategory)) {
                        _selectedCategory = null;
                      }
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Amount
            _SectionLabel(label: 'AMOUNT'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: '₱ ',
                  prefixStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _isIncome ? AppColors.income : AppColors.expense,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category
            _SectionLabel(label: 'CATEGORY'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final color =
                    _isIncome ? AppColors.income : AppColors.expense;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Account
            _SectionLabel(label: 'ACCOUNT (OPTIONAL)'),
            const SizedBox(height: 8),
            _AccountSelector(
              selectedAccountId: _selectedAccountId,
              onChanged: (id) =>
                  setState(() => _selectedAccountId = id),
            ),
            const SizedBox(height: 24),

            // Date
            _SectionLabel(label: 'DATE'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            _SectionLabel(label: 'NOTES (OPTIONAL)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSelector extends ConsumerWidget {
  const _AccountSelector({
    required this.selectedAccountId,
    required this.onChanged,
  });

  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;

  static const _typeIcons = <String, IconData>{
    'bank': Icons.account_balance_rounded,
    'digital': Icons.phone_android_rounded,
    'cash': Icons.wallet_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountsProvider);
    return accountsState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        if (accounts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No accounts added yet',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: () => onChanged(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selectedAccountId == null
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedAccountId == null
                        ? AppColors.primary
                        : AppColors.border,
                    width: selectedAccountId == null ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  'None',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selectedAccountId == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: selectedAccountId == null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            ...accounts.map((account) {
              final isSelected = selectedAccountId == account.id;
              final icon = _typeIcons[account.type] ??
                  Icons.account_balance_rounded;
              return GestureDetector(
                onTap: () => onChanged(account.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        account.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}
