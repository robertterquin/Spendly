import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/domain/account_model.dart';
import 'package:spendly/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class AccountsSection extends ConsumerWidget {
  const AccountsSection({super.key});

  static const _typeIcons = <String, IconData>{
    'bank': Icons.account_balance_rounded,
    'digital': Icons.phone_android_rounded,
    'cash': Icons.wallet_rounded,
  };

  static const _typeColors = <String, Color>{
    'bank': AppColors.primary,
    'digital': AppColors.tertiary,
    'cash': AppColors.secondary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsState = ref.watch(accountsProvider);
    final totalBalance = ref.watch(totalAccountsBalanceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'My Accounts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddAccountSheet(context, ref),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Total: ₱${totalBalance.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        accountsState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
          error: (_, __) => const Text('Failed to load accounts'),
          data: (accounts) {
            if (accounts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 32,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No accounts yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + Add to track your money',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                for (int i = 0; i < accounts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _AccountTile(
                    account: accounts[i],
                    icon: _typeIcons[accounts[i].type] ??
                        Icons.account_balance_rounded,
                    color: _typeColors[accounts[i].type] ?? AppColors.primary,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAccountSheet(ref: ref),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    required this.account,
    required this.icon,
    required this.color,
  });

  final AccountModel account;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account.type == 'digital'
                      ? 'Digital Wallet'
                      : account.type == 'cash'
                          ? 'Cash'
                          : 'Bank',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${account.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case 'add':
                  _showAdjustDialog(context, ref, isAdding: true);
                case 'withdraw':
                  _showAdjustDialog(context, ref, isAdding: false);
                case 'edit':
                  _showEditSheet(context, ref);
                case 'delete':
                  _confirmDelete(context, ref);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text('Add Money', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.remove_rounded, size: 18, color: AppColors.expense),
                    SizedBox(width: 8),
                    Text('Withdraw', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.tertiary),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.expense),
                    SizedBox(width: 8),
                    Text('Delete',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.expense)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAdjustDialog(BuildContext context, WidgetRef ref,
      {required bool isAdding}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAdding ? 'Add Money' : 'Withdraw Money',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current balance: ₱${account.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '₱ ',
                prefixStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final adjustedAmount = isAdding ? amount : -amount;
              if (!isAdding && amount > account.balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insufficient balance')),
                );
                return;
              }
              ref
                  .read(accountsProvider.notifier)
                  .adjustBalance(account.id, adjustedAmount);
              Navigator.pop(ctx);
            },
            child: Text(
              isAdding ? 'Add' : 'Withdraw',
              style: TextStyle(
                color: isAdding ? AppColors.secondary : AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAccountSheet(ref: ref, existing: account),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Remove "${account.name}"? This cannot be undone.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(accountsProvider.notifier).delete(account.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                  color: AppColors.expense, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet({required this.ref, this.existing});

  final WidgetRef ref;
  final AccountModel? existing;

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedType;

  bool get _isEditing => widget.existing != null;

  static const _types = <String, _AccountTypeInfo>{
    'bank': _AccountTypeInfo(
      label: 'Bank',
      icon: Icons.account_balance_rounded,
      color: AppColors.primary,
    ),
    'digital': _AccountTypeInfo(
      label: 'Digital',
      icon: Icons.phone_android_rounded,
      color: AppColors.tertiary,
    ),
    'cash': _AccountTypeInfo(
      label: 'Cash',
      icon: Icons.wallet_rounded,
      color: AppColors.secondary,
    ),
  };

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.balance.toStringAsFixed(2)
          : '',
    );
    _selectedType = widget.existing?.type ?? 'bank';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isEditing ? 'Edit Account' : 'Add Account',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ACCOUNT TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _types.entries.map((entry) {
              final isSelected = _selectedType == entry.key;
              final info = entry.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: entry.key != 'cash' ? 10 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? info.color.withValues(alpha: 0.1)
                          : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? info.color
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(info.icon,
                            size: 22,
                            color:
                                isSelected ? info.color : AppColors.textSecondary),
                        const SizedBox(height: 6),
                        Text(
                          info.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? info.color
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'ACCOUNT NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. BDO, GCash, PayMaya',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isEditing ? 'BALANCE' : 'INITIAL BALANCE',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _balanceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '₱ ',
              prefixStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Add Account',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    if (name.isEmpty) return;

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        name: name,
        balance: balance,
        type: _selectedType,
      );
      widget.ref.read(accountsProvider.notifier).updateAccount(updated);
    } else {
      final user =
          widget.ref.read(authProvider).valueOrNull;
      if (user == null) return;
      final account = AccountModel(
        userId: user.id,
        name: name,
        balance: balance,
        type: _selectedType,
      );
      widget.ref.read(accountsProvider.notifier).add(account);
    }
    Navigator.pop(context);
  }
}

class _AccountTypeInfo {
  const _AccountTypeInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
