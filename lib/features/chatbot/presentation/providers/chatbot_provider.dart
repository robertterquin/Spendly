import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/features/chatbot/data/ai_service.dart';
import 'package:spendly/features/chatbot/data/chatbot_repository.dart';
import 'package:spendly/features/chatbot/domain/chat_message_model.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotRepository();
});

class ChatState {
  const ChatState({
    this.sessions = const [],
    this.currentSession,
    this.messages = const [],
    this.isLoading = false,
  });

  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    bool clearSession = false,
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatbotProvider = NotifierProvider<ChatbotNotifier, ChatState>(
  ChatbotNotifier.new,
);

class ChatbotNotifier extends Notifier<ChatState> {
  late AiService _aiService;
  ChatbotRepository get _repo => ref.read(chatbotRepositoryProvider);

  @override
  ChatState build() {
    _aiService = AiService();
    _loadSessions();
    return const ChatState();
  }

  Future<void> _loadSessions() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    final sessions = await _repo.getSessions(user.id);
    state = state.copyWith(sessions: sessions);

    if (sessions.isNotEmpty) {
      await selectSession(sessions.first);
    }
  }

  Future<void> selectSession(ChatSession session) async {
    final messages = await _repo.getMessages(session.id);
    _aiService = AiService();
    state = state.copyWith(
      currentSession: session,
      messages: messages,
    );
  }

  Future<void> startNewChat() async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    final session = await _repo.createSession(
      ChatSession(userId: user.id, title: 'New Chat'),
    );
    _aiService = AiService();
    state = state.copyWith(
      sessions: [session, ...state.sessions],
      currentSession: session,
      messages: [],
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _repo.deleteSession(sessionId);
    final updated = state.sessions.where((s) => s.id != sessionId).toList();
    if (state.currentSession?.id == sessionId) {
      if (updated.isNotEmpty) {
        await selectSession(updated.first);
        state = state.copyWith(sessions: updated);
      } else {
        state = state.copyWith(
          sessions: updated,
          clearSession: true,
          messages: [],
        );
      }
    } else {
      state = state.copyWith(sessions: updated);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    // Auto-create session if none exists
    if (state.currentSession == null) {
      final session = await _repo.createSession(
        ChatSession(userId: user.id, title: text.trim().length > 30
            ? '${text.trim().substring(0, 30)}...'
            : text.trim()),
      );
      state = state.copyWith(
        sessions: [session, ...state.sessions],
        currentSession: session,
      );
    }

    final sessionId = state.currentSession!.id;

    // Update session title from first message
    if (state.messages.isEmpty) {
      final title = text.trim().length > 30
          ? '${text.trim().substring(0, 30)}...'
          : text.trim();
      await _repo.updateSessionTitle(sessionId, title);
      final updatedSessions = state.sessions.map((s) {
        if (s.id == sessionId) {
          return ChatSession(
            id: s.id,
            userId: s.userId,
            title: title,
            createdAt: s.createdAt,
          );
        }
        return s;
      }).toList();
      state = state.copyWith(sessions: updatedSessions);
    }

    final userMessage = ChatMessage(
      sessionId: sessionId,
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    await _repo.addMessage(userMessage);

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final context = await _buildTransactionContext();
      final response = await _aiService.sendMessage(
        text.trim(),
        transactionContext: context,
      );

      if (response.action != null) {
        await _handleAction(response.action!);
      }

      final aiMessage = ChatMessage(
        sessionId: sessionId,
        text: response.message,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _repo.addMessage(aiMessage);

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (_) {
      final errorMessage = ChatMessage(
        sessionId: sessionId,
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _repo.addMessage(errorMessage);

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  Future<String> _buildTransactionContext() async {
    final transactions =
        ref.read(transactionsProvider).valueOrNull ?? [];

    // Always await accounts to ensure they are loaded
    final accounts = await ref.read(accountsProvider.future);

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
      ..writeln('')
      ..writeln('User accounts (use the UUID field exactly when adding transactions):');

    if (accounts.isEmpty) {
      buffer.writeln('  (no accounts found)');
    } else {
      for (final a in accounts) {
        buffer.writeln('  NAME="${a.name}" TYPE="${a.type}" BALANCE=${a.balance} UUID=${a.id}');
      }
    }

    final categoryTotals = <String, double>{};
    for (final t in monthTx.where((t) => t.isExpense)) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    buffer
      ..writeln('')
      ..writeln('This month expense breakdown by category:');
    for (final entry in sortedCategories) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }

    if (transactions.isEmpty) {
      buffer.writeln('');
      buffer.writeln('Recent transactions: none yet.');
    } else {
      buffer
        ..writeln('')
        ..writeln('Recent transactions (last 20):');
      for (final t in transactions.take(20)) {
        buffer.writeln(
          '- id: ${t.id} | ${t.type}: ${t.amount} | ${t.category} | '
          '${t.date.toIso8601String().split('T').first} | ${t.notes ?? ''}',
        );
      }
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
          accountId: data['account_id'] as String?,
          notes: data['notes'] as String?,
        );
        await ref.read(transactionsProvider.notifier).add(transaction);
      case 'delete_transaction':
        final transactionId = data['transaction_id'] as String?;
        if (transactionId != null && transactionId.isNotEmpty) {
          await ref.read(transactionsProvider.notifier).delete(transactionId);
        }
      case 'edit_transaction':
        final txId = data['transaction_id'] as String?;
        if (txId == null || txId.isEmpty) return;
        final allTx = ref.read(transactionsProvider).valueOrNull ?? [];
        final existing = allTx.where((t) => t.id == txId).firstOrNull;
        if (existing == null) return;
        final updated = TransactionModel(
          id: existing.id,
          userId: existing.userId,
          type: existing.type,
          amount: data['amount'] != null
              ? (data['amount'] as num).toDouble()
              : existing.amount,
          category: data['category'] as String? ?? existing.category,
          date: existing.date,
          accountId: existing.accountId,
          notes: data['notes'] as String? ?? existing.notes,
          createdAt: existing.createdAt,
        );
        await ref.read(transactionsProvider.notifier).updateTransaction(updated);
      case 'transfer':
        final amount = (data['amount'] as num).toDouble();
        final fromAccountId = data['from_account_id'] as String?;
        final toAccountId = data['to_account_id'] as String?;
        final notes = data['notes'] as String? ?? 'Transfer';
        final expense = TransactionModel(
          userId: user.id,
          type: 'expense',
          amount: amount,
          category: 'Others',
          date: DateTime.now(),
          accountId: fromAccountId,
          notes: notes,
        );
        final income = TransactionModel(
          userId: user.id,
          type: 'income',
          amount: amount,
          category: 'Allowance',
          date: DateTime.now(),
          accountId: toAccountId,
          notes: notes,
        );
        await ref.read(transactionsProvider.notifier).add(expense);
        await ref.read(transactionsProvider.notifier).add(income);
    }
  }
}
