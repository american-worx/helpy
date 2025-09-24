import '../entities/conversation.dart';
import '../entities/message.dart';

/// Repository interface for chat operations
abstract class IChatRepository {
  /// Create a new conversation
  Future<Conversation> createConversation({
    required String title,
    required String type,
    List<String>? participantIds,
  });

  /// Get all conversations for a user
  Future<List<Conversation>> getConversations(String userId);

  /// Get a specific conversation by ID
  Future<Conversation?> getConversation(String conversationId);

  /// Send a message to a conversation
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    required String senderId,
    required String senderType,
    String? contentType,
    Map<String, dynamic>? metadata,
  });

  /// Get messages for a conversation
  Future<List<Message>> getMessages(
    String conversationId, {
    int? limit,
    String? lastMessageId,
  });

  /// Update message (edit)
  Future<Message> updateMessage(String messageId, String newContent);

  /// Delete message
  Future<void> deleteMessage(String messageId);

  /// Add reaction to message
  Future<void> addReaction(String messageId, String reaction, String userId);

  /// Remove reaction from message
  Future<void> removeReaction(String messageId, String reaction, String userId);

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId, String userId);

  /// Set typing indicator
  Future<void> setTyping(String conversationId, String userId, bool isTyping);

  /// Stream messages for real-time updates
  Stream<List<Message>> watchMessages(String conversationId);

  /// Stream conversation updates
  Stream<Conversation> watchConversation(String conversationId);
}