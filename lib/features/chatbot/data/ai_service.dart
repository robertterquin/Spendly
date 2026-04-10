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

  static const _apiKey = 'YOUR_GROQ_API_KEY';
  static const _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.1-8b-instant';

  final List<Map<String, String>> _history = [];

  static const _systemPrompt = '''
You are Spendly AI, a friendly and concise budget assistant inside the Spendly personal finance app.

You help users:
• Track income and expenses
• Get financial summaries and advice
• Add or remove transactions via chat

CATEGORIES:
Income: Allowance, Salary, Gift, Side Hustle
Expense: Food, Transport, School, Bills, Entertainment, Others

ACCOUNTS:
The user has multiple accounts (e.g. Gcash, Wallet, Metrobank). Their account IDs and names will be provided in the context. Always ask which account if the user doesn't specify one.

─── ADDING A TRANSACTION ───
When the user clearly wants to add a transaction, respond with ONLY a valid JSON object (no markdown fences, no extra text):
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "add_transaction",
    "data": {
      "type": "income" or "expense",
      "amount": <number>,
      "category": "<exact category from the lists above>",
      "account_id": "<the account UUID from the context>",
      "notes": "<brief description or empty string>"
    }
  }
}

─── DELETING A TRANSACTION ───
When the user clearly wants to delete/remove a transaction, respond with ONLY a valid JSON object:
{
  "message": "<friendly confirmation>",
  "action": {
    "type": "delete_transaction",
    "data": {
      "transaction_id": "<the transaction UUID from the context>"
    }
  }
}
If the user is vague (e.g. "delete my last food expense"), match it to the closest transaction in the context by type, category, amount, and date. If multiple match, list them and ask which one.

─── ALL OTHER RESPONSES ───
Reply with plain text only. Be concise, helpful, and friendly.

RULES:
• Only use the exact category names listed above.
• If the user is vague about amount, category, or account, ask a short clarifying question.
• Always include account_id when adding a transaction. Match account names case-insensitively.
• When summarising, reference the transaction data provided in the context.
• Keep responses short and mobile-friendly.
• Today's date context will be provided with each message.
''';

  Future<AiResponse> sendMessage(
    String message, {
    String? transactionContext,
  }) async {
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
        final jsonStr = cleaned.substring(jsonStart, jsonEnd + 1);
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

