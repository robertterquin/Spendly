import 'package:flutter/material.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onDelete,
  });

  final List<TransactionModel> transactions;
  final void Function(TransactionModel)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 26,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No transactions yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + to add your first one',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(transactions.length, (index) {
        final tx = transactions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index < transactions.length - 1 ? 10 : 0),
          child: _TransactionTile(
            transaction: tx,
            onDelete: onDelete != null ? () => onDelete!(tx) : null,
          ),
        );
      }),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, this.onDelete});

  final TransactionModel transaction;
  final VoidCallback? onDelete;

  String get _dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(
        transaction.date.year, transaction.date.month, transaction.date.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
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

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                '$sign₱${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
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
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: tile,
    );
  }
}
