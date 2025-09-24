import '../../core/storage/hive_repository_base.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';

/// Offline-first chat repository implementation using Hive
class OfflineChatRepositoryImpl {
  final HiveMessageRepository _messageRepository;
  final HiveConversationRepository _conversationRepository;

  OfflineChatRepositoryImpl()
      : _messageRepository = getIt<HiveMessageRepository>(),
        _conversationRepository = getIt<HiveConversationRepository>();

  /// Save message locally
  Future<void> saveMessage(Message message) async {
    await _messageRepository.save(message.id, message);
  }

  /// Get messages for a conversation
  List<Message> getMessagesForConversation(String conversationId) {
    final messages = _messageRepository.getByConversationId(conversationId);
    return messages.cast<Message>().toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Save conversation locally
  Future<void> saveConversation(Conversation conversation) async {
    await _conversationRepository.save(conversation.id, conversation);
  }

  /// Get conversation by ID
  Conversation? getConversation(String conversationId) {
    return _conversationRepository.get(conversationId) as Conversation?;
  }

  /// Get all conversations
  List<Conversation> getAllConversations() {
    return _conversationRepository.getAll().cast<Conversation>().toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get recent messages across all conversations
  List<Message> getRecentMessages({int limit = 50}) {
    return _messageRepository.getRecent(limit).cast<Message>().toList();
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    await _messageRepository.delete(messageId);
  }

  /// Delete conversation and all its messages
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages in the conversation
    final messages = getMessagesForConversation(conversationId);
    for (final message in messages) {
      await deleteMessage(message.id);
    }
    
    // Delete the conversation itself
    await _conversationRepository.delete(conversationId);
  }

  /// Clear all chat data
  Future<void> clearAllData() async {
    await _messageRepository.clear();
    await _conversationRepository.clear();
  }

  /// Get conversations count
  int get conversationsCount => _conversationRepository.length;

  /// Get messages count
  int get messagesCount => _messageRepository.length;

  /// Listen to conversation changes
  Stream<dynamic> watchConversations() {
    return _conversationRepository.watch();
  }

  /// Listen to message changes for a specific conversation
  Stream<dynamic> watchMessages(String conversationId) {
    return _messageRepository.watch();
  }
}