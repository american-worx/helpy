import 'package:injectable/injectable.dart';

import '../../entities/message.dart';
import '../../repositories/i_chat_repository.dart';

/// Use case for sending a message
@injectable
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase(this._chatRepository);

  /// Execute send message
  Future<Message> execute({
    required String conversationId,
    required String content,
    required String senderId,
    required String senderType,
    String? contentType,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate input
    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty');
    }

    if (content.trim().isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }

    if (senderId.trim().isEmpty) {
      throw ArgumentError('Sender ID cannot be empty');
    }

    if (senderType.trim().isEmpty) {
      throw ArgumentError('Sender type cannot be empty');
    }

    // Validate message length
    if (content.length > 2000) {
      throw ArgumentError('Message cannot exceed 2000 characters');
    }

    // Validate sender type
    final validSenderTypes = ['human', 'helpy'];
    if (!validSenderTypes.contains(senderType.toLowerCase())) {
      throw ArgumentError('Invalid sender type. Must be either "human" or "helpy"');
    }

    // Send message through repository
    return await _chatRepository.sendMessage(
      conversationId: conversationId.trim(),
      content: content.trim(),
      senderId: senderId.trim(),
      senderType: senderType.toLowerCase(),
      contentType: contentType ?? 'text',
      metadata: metadata,
    );
  }
}