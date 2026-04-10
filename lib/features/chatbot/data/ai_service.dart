import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponse {
  const AiResponse({required this.message, this.action});

  final String message;
  final Map<String, dynamic>? action;
}

class AiService {
  AiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  static const _apiKey = 'YOUR_GEMINI_API_KEY';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  static const _systemPrompt = '''
You are Spendly AI, a friendly and concise budget assistant inside the Spendly personal finance app.

You help users:
• Track income and expenses
• Get financial summaries and advice
• Add new transactions via chat

CATEGORIES:
Income: Allowance, Salary, Gift, Side Hustle
Expense: Food, Transport, School, Bills, Entertainment, Others

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
      "notes": "<brief description or empty string>"
    }
  }
}

─── ALL OTHER RESPONSES ───
Reply with plain text only. Be concise, helpful, and friendly.

RULES:
• Only use the exact category names listed above.
• If the user is vague about amount or category, ask a short clarifying question.
• When summarising, reference the transaction data provided in the context.
• Keep responses short and mobile-friendly.
• Today's date context will be provided with each message.
''';

  Future<AiResponse> sendMessage(
    String message, {
    String? transactionContext,
  }) async {
    final prompt = transactionContext != null
        ? '[Transaction Data]\n$transactionContext\n\n[User Message]\n$message'
        : message;

    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      final text = response.text ?? 'Sorry, I could not generate a response.';
      return _parseResponse(text);
    } catch (e) {
      debugPrint('Gemini API error: $e');
      return AiResponse(
        message: 'Sorry, something went wrong: $e',
      );
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
