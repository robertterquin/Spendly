import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/features/chatbot/data/ai_service.dart';

void main() {
  group('AiService Configuration Tests', () {
    test('handles unconfigured or configured GROQ_API_KEY gracefully', () async {
      final service = AiService();
      final response = await service.sendMessage('Hello');
      expect(response.message.isNotEmpty, isTrue);
    });
  });
}
