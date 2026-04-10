import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/chatbot/domain/chat_message_model.dart';

class ChatbotRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ChatSession>> getSessions(String userId) async {
    final data = await _client
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ChatSession.fromJson)
        .toList();
  }

  Future<ChatSession> createSession(ChatSession session) async {
    final data = await _client
        .from('chat_sessions')
        .insert(session.toJson())
        .select()
        .single();

    return ChatSession.fromJson(data);
  }

  Future<void> updateSessionTitle(String sessionId, String title) async {
    await _client
        .from('chat_sessions')
        .update({'title': title})
        .eq('id', sessionId);
  }

  Future<void> deleteSession(String sessionId) async {
    await _client.from('chat_messages').delete().eq('session_id', sessionId);
    await _client.from('chat_sessions').delete().eq('id', sessionId);
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList();
  }

  Future<void> addMessage(ChatMessage message) async {
    await _client.from('chat_messages').insert(message.toJson());
  }
}
