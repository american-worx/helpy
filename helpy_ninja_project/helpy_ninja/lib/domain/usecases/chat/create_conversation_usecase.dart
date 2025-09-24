import 'package:injectable/injectable.dart';

import '../../entities/conversation.dart';
import '../../repositories/i_chat_repository.dart';

/// Use case for creating a new conversation
@injectable
class CreateConversationUseCase {
  final IChatRepository _chatRepository;

  CreateConversationUseCase(this._chatRepository);

  /// Execute create conversation
  Future<Conversation> execute({
    required String title,
    required String type,
    List<String>? participantIds,
  }) async {
    // Validate input
    if (title.trim().isEmpty) {
      throw ArgumentError('Conversation title cannot be empty');
    }

    if (type.trim().isEmpty) {
      throw ArgumentError('Conversation type cannot be empty');
    }

    // Validate title length
    if (title.length > 100) {
      throw ArgumentError('Title cannot exceed 100 characters');
    }

    // Validate conversation type
    final validTypes = ['individual', 'group'];
    if (!validTypes.contains(type.toLowerCase())) {
      throw ArgumentError('Invalid conversation type. Must be either "individual" or "group"');
    }

    // Validate participant count for group conversations
    if (type.toLowerCase() == 'group') {
      if (participantIds == null || participantIds.isEmpty) {
        throw ArgumentError('Group conversations must have at least one participant');
      }

      if (participantIds.length > 8) {
        throw ArgumentError('Group conversations cannot have more than 8 participants');
      }
    }

    // Create conversation through repository
    return await _chatRepository.createConversation(
      title: title.trim(),
      type: type.toLowerCase(),
      participantIds: participantIds,
    );
  }
}