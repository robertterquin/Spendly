import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiResponse {
  const AiResponse({required this.message, this.action});

  final String message;
  final Map<String, dynamic>? action;
}

class AiService {
  AiService();

  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final List<Map<String, String>> _history = [];

  static const _systemPrompt = '''
You are Spendly AI, a friendly and concise budget assistant inside the Spendly personal finance app.

You help users:
• Track income and expenses
• Get financial summaries and personalised advice
• Add, edit, delete, or transfer transactions via chat

CATEGORIES:
Income: Allowance, Salary, Gift, Side Hustle
Expense: Food, Transport, School, Bills, Entertainment, Others

ACCOUNTS:
The user's accounts are listed in the context in this format:
  ACCOUNT_NAME (type) | balance: AMOUNT | id: UUID

When the user mentions an account name (e.g. "Wallet", "Gcash", "Metrobank"), look up that name in the account list and copy its UUID exactly as-is into the JSON. Never use placeholder text like "Wallet UUID" — always use the real UUID string from the context.
Only ask which account when the user gives no hint at all about which one to use.

─── ADDING A TRANSACTION ───
When the user clearly wants to add a transaction, respond with ONLY a valid JSON object (no markdown, no extra text):
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "add_transaction",
    "data": {
      "type": "income" or "expense",
      "amount": <number>,
      "category": "<exact category from the lists above>",
      "account_id": "<account UUID from context>",
      "notes": "<brief description or empty string>"
    }
  }
}

─── EDITING A TRANSACTION ───
When the user wants to correct or update a transaction (e.g. "change that ₱100 food to ₱150", "update the notes on my salary"), respond with ONLY a valid JSON object:
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "edit_transaction",
    "data": {
      "transaction_id": "<UUID from context>",
      "amount": <new number, or omit if unchanged>,
      "category": "<new category, or omit if unchanged>",
      "notes": "<new notes, or omit if unchanged>"
    }
  }
}
Match the transaction by amount, category, and date from the context. Ask for clarification if multiple match.

─── DELETING A TRANSACTION ───
When the user clearly wants to delete/remove a transaction, respond with ONLY a valid JSON object:
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "delete_transaction",
    "data": {
      "transaction_id": "<UUID from context>"
    }
  }
}
If vague, match the closest by type/category/amount/date. If multiple match, list them and ask which one.

─── EDITING AN ACCOUNT BALANCE ───
When the user wants to set/update/edit an account balance directly (e.g. "edit my Gcash account make it 140", "set my Wallet balance to 500"), respond with ONLY a valid JSON object:
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "edit_account",
    "data": {
      "account_id": "<UUID from context>",
      "balance": <new balance as a number>
    }
  }
}

─── TRANSFERRING BETWEEN ACCOUNTS ───
When the user wants to move money between accounts (e.g. "transfer ₱500 from Wallet to Gcash"), respond with ONLY a valid JSON object:
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "transfer",
    "data": {
      "amount": <number>,
      "from_account_id": "<source account UUID from context>",
      "to_account_id": "<destination account UUID from context>",
      "notes": "<e.g. Transfer to Gcash>"
    }
  }
}

─── ANSWERING FINANCIAL QUERIES ───
For any question about spending, income, or balances use the transaction data in the context. Examples:
• "How much did I spend on food?" → sum all food expenses from context
• "What's my biggest expense?" → find highest category total
• "How much is in my Gcash?" → read from the accounts section
• "Am I overspending?" → compare total expenses vs total income
• "How many transactions this week?" → count by date
• "Where can I cut costs?" → identify highest expense category
• "What's left after bills?" → net = income - expenses
Always cite specific numbers from the context. If data is insufficient, say so.

─── ALL OTHER RESPONSES ───
Reply with plain text only. Be concise, helpful, and friendly.

RULES:
• Only use the exact category names listed above.
• If vague about amount or category, ask one short clarifying question.
• Always include a real UUID for account_id — copy it directly from the context, never write a placeholder.
• Never add comments (# ...) inside JSON — JSON must be pure and valid.
• For transfers, always use both from_account_id and to_account_id as real UUIDs.
• Keep responses short and mobile-friendly.
• Never fabricate data — always base answers on the provided context.
• Today's date and full transaction context are provided with each message.
''';

  Future<AiResponse> sendMessage(
    String message, {
    String? transactionContext,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GROQ_API_KEY') {
      return const AiResponse(
        message:
            'Groq API key is not configured. Please add GROQ_API_KEY to your .env file and run with --dart-define-from-file=.env.',
      );
    }

    final userContent = transactionContext != null
        ? '[Transaction Data]\n$transactionContext\n\n[User Message]\n$message'
        : message;

    _history.add({'role': 'user', 'content': userContent});

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            ..._history,
          ],
          'max_tokens': 512,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            (data['choices'] as List).first['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': text});
        return _parseResponse(text);
      } else {
        final error = jsonDecode(response.body);
        debugPrint('Groq API error: $error');
        return AiResponse(
          message: 'Sorry, something went wrong: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Groq API error: $e');
      return AiResponse(message: 'Sorry, something went wrong: $e');
    }
  }

  AiResponse _parseResponse(String text) {
    try {
      final cleaned = text.trim();
      final jsonStart = cleaned.indexOf('{');
      final jsonEnd = cleaned.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        var jsonStr = cleaned.substring(jsonStart, jsonEnd + 1);
        // Strip single-line comments that the model may incorrectly insert
        jsonStr = jsonStr.replaceAll(RegExp(r'//[^\n]*'), '');
        jsonStr = jsonStr.replaceAll(RegExp(r'#[^\n"]*'), '');
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (json.containsKey('message')) {
          return AiResponse(
            message: json['message'] as String,
            action: json['action'] as Map<String, dynamic>?,
          );
        }
      }
    } catch (_) {}
    return AiResponse(message: text);
  }
}

