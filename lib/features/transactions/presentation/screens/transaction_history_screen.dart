import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:spendly/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all' | 'income' | 'expense'
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All your transactions',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _typeFilter == 'all',
                          onTap: () => setState(() => _typeFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Income',
                          isSelected: _typeFilter == 'income',
                          color: AppColors.income,
                          onTap: () =>
                              setState(() => _typeFilter = 'income'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Expense',
                          isSelected: _typeFilter == 'expense',
                          color: AppColors.expense,
                          onTap: () =>
                              setState(() => _typeFilter = 'expense'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            // Transactions list
            Expanded(
              child: txState.when(
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                data: (transactions) {
                  var filtered = transactions;

                  // Type filter
                  if (_typeFilter == 'income') {
                    filtered = filtered
                        .where((t) => t.isIncome)
                        .toList();
                  } else if (_typeFilter == 'expense') {
                    filtered = filtered
                        .where((t) => t.isExpense)
                        .toList();
                  }

                  // Category filter
                  if (_categoryFilter != 'All') {
                    filtered = filtered
                        .where((t) => t.category == _categoryFilter)
                        .toList();
                  }

                  // Search filter
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = filtered
                        .where((t) =>
                            t.category.toLowerCase().contains(q) ||
                            (t.notes?.toLowerCase().contains(q) ?? false) ||
                            t.amount.toStringAsFixed(2).contains(q))
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return _EmptyState(hasFilters: _typeFilter != 'all' ||
                        _searchQuery.isNotEmpty);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return _TransactionCard(
                        transaction: tx,
                        onTap: () => _openEdit(tx),
                        onDelete: () => _confirmDelete(tx),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(TransactionModel tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: tx),
      ),
    );
  }

  void _confirmDelete(TransactionModel tx) {
    showDialog(
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
          'Are you sure you want to delete this transaction?',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(transactionsProvider.notifier).delete(tx.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? activeColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Transaction card ───────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String get _dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(
        transaction.date.year, transaction.date.month, transaction.date.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${transaction.date.day} ${months[transaction.date.month - 1]}';
  }

  IconData get _categoryIcon {
    switch (transaction.category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'bills':
        return Icons.receipt_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'salary':
        return Icons.work_outline;
      case 'allowance':
        return Icons.wallet_outlined;
      case 'gift':
        return Icons.card_giftcard_outlined;
      case 'side hustle':
        return Icons.trending_up_outlined;
      default:
        return Icons.attach_money_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final sign = isIncome ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (transaction.notes != null &&
                    transaction.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      transaction.notes!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasFilters
                  ? Icons.filter_list_off_rounded
                  : Icons.receipt_long_outlined,
              size: 26,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasFilters ? 'No matching transactions' : 'No transactions yet',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasFilters
                ? 'Try adjusting your filters'
                : 'Add your first transaction to get started',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
