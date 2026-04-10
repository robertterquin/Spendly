import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/features/chatbot/data/ai_service.dart';
import 'package:spendly/features/chatbot/domain/chat_message_model.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatbotProvider = NotifierProvider<ChatbotNotifier, ChatState>(
  ChatbotNotifier.new,
);

class ChatbotNotifier extends Notifier<ChatState> {
  late final AiService _aiService;

  @override
  ChatState build() {
    _aiService = AiService();
    return const ChatState();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final context = _buildTransactionContext();
      final response = await _aiService.sendMessage(
        text.trim(),
        transactionContext: context,
      );

      if (response.action != null) {
        await _handleAction(response.action!);
      }

      final aiMessage = ChatMessage(
        text: response.message,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (_) {
      final errorMessage = ChatMessage(
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  String _buildTransactionContext() {
    final transactions =
        ref.read(transactionsProvider).valueOrNull ?? [];
    if (transactions.isEmpty) return 'No transactions yet.';

    final now = DateTime.now();
    final monthTx = transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final totalIncome = monthTx
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = monthTx
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final buffer = StringBuffer()
      ..writeln('Today: ${now.toIso8601String().split('T').first}')
      ..writeln('Current month: ${now.month}/${now.year}')
      ..writeln('Total income this month: $totalIncome')
      ..writeln('Total expenses this month: $totalExpense')
      ..writeln('Net: ${totalIncome - totalExpense}')
      ..writeln('Recent transactions (last 10):');

    for (final t in transactions.take(10)) {
      buffer.writeln(
        '- ${t.type}: ${t.amount} | ${t.category} | '
        '${t.date.toIso8601String().split('T').first} | ${t.notes ?? ''}',
      );
    }

    return buffer.toString();
  }

  Future<void> _handleAction(Map<String, dynamic> action) async {
    final type = action['type'] as String?;
    final data = action['data'] as Map<String, dynamic>?;
    if (type == null || data == null) return;

    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    switch (type) {
      case 'add_transaction':
        final transaction = TransactionModel(
          userId: user.id,
          type: data['type'] as String,
          amount: (data['amount'] as num).toDouble(),
          category: data['category'] as String,
          date: DateTime.now(),
          notes: data['notes'] as String?,
        );
        await ref.read(transactionsProvider.notifier).add(transaction);
    }
  }
}
