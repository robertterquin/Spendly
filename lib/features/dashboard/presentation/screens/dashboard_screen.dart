import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:spendly/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:spendly/features/dashboard/presentation/widgets/recent_transactions_list.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final summaryState = ref.watch(dashboardSummaryProvider);
    final firstName = user?.name.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: summaryState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          data: (summary) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _monthLabel(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Balance card
                BalanceCard(
                  totalBalance: summary.totalBalance,
                  totalIncome: summary.totalIncome,
                  totalExpense: summary.totalExpense,
                ),
                const SizedBox(height: 28),
                // Quick actions
                Row(
                  children: [
                    _QuickAction(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      color: AppColors.secondary,
                      onTap: () {
                        // TODO: navigate to add income
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expense',
                      color: AppColors.expense,
                      onTap: () {
                        // TODO: navigate to add expense
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.bar_chart_rounded,
                      label: 'Charts',
                      color: AppColors.tertiary,
                      onTap: () {
                        // TODO: navigate to charts
                      },
                    ),
                    const SizedBox(width: 12),
                    _QuickAction(
                      icon: Icons.history_rounded,
                      label: 'History',
                      color: AppColors.primary,
                      onTap: () {
                        // TODO: navigate to history
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Recent transactions header
                Row(
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // TODO: navigate to history
                      },
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RecentTransactionsList(
                  transactions: summary.recentTransactions,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthLabel() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
