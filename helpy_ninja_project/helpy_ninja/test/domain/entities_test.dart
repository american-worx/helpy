import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:helpy_ninja/domain/entities/message.dart';
import 'package:helpy_ninja/domain/entities/chat_settings.dart';

void main() {
  group('Shared Enums Tests', () {
    test('DifficultyLevel enum should have all expected values', () {
      expect(DifficultyLevel.values.length, 4);
      expect(DifficultyLevel.values, contains(DifficultyLevel.beginner));
      expect(DifficultyLevel.values, contains(DifficultyLevel.intermediate));
      expect(DifficultyLevel.values, contains(DifficultyLevel.advanced));
      expect(DifficultyLevel.values, contains(DifficultyLevel.expert));
    });

    test('AttachmentType enum should have all expected values', () {
      expect(AttachmentType.values.length, 5);
      expect(AttachmentType.values, contains(AttachmentType.image));
      expect(AttachmentType.values, contains(AttachmentType.video));
      expect(AttachmentType.values, contains(AttachmentType.audio));
      expect(AttachmentType.values, contains(AttachmentType.document));
      expect(AttachmentType.values, contains(AttachmentType.file));
    });

    test('MessagePriority enum should have all expected values', () {
      expect(MessagePriority.values.length, 4);
      expect(MessagePriority.values, contains(MessagePriority.low));
      expect(MessagePriority.values, contains(MessagePriority.normal));
      expect(MessagePriority.values, contains(MessagePriority.high));
      expect(MessagePriority.values, contains(MessagePriority.urgent));
    });
  });

  group('MessageReaction Tests', () {
    test('should create MessageReaction with valid data', () {
      final reaction = MessageReaction(
        emoji: '👍',
        userIds: ['user1', 'user2'],
        count: 2,
        timestamp: DateTime.now(),
      );

      expect(reaction.emoji, '👍');
      expect(reaction.userIds, ['user1', 'user2']);
      expect(reaction.count, 2);
      expect(reaction.timestamp, isA<DateTime>());
    });

    test('should convert MessageReaction to and from JSON', () {
      final timestamp = DateTime.now();
      final reaction = MessageReaction(
        emoji: '❤️',
        userIds: ['user1'],
        count: 1,
        timestamp: timestamp,
        userName: 'Test User',
      );

      final json = reaction.toJson();
      expect(json['emoji'], '❤️');
      expect(json['userIds'], ['user1']);
      expect(json['count'], 1);
      expect(json['userName'], 'Test User');

      final fromJson = MessageReaction.fromJson(json);
      expect(fromJson.emoji, reaction.emoji);
      expect(fromJson.userIds, reaction.userIds);
      expect(fromJson.count, reaction.count);
      expect(fromJson.userName, reaction.userName);
    });

    test('should compare MessageReactions correctly', () {
      final reaction1 = MessageReaction(
        emoji: '👍',
        userIds: ['user1', 'user2'],
        count: 2,
        timestamp: DateTime.now(),
      );

      final reaction2 = MessageReaction(
        emoji: '👍',
        userIds: ['user1', 'user2'],
        count: 2,
        timestamp: DateTime.now(),
      );

      final reaction3 = MessageReaction(
        emoji: '❤️',
        userIds: ['user1'],
        count: 1,
        timestamp: DateTime.now(),
      );

      expect(reaction1, equals(reaction2));
      expect(reaction1, isNot(equals(reaction3)));
    });
  });

  group('CompressionInfo Tests', () {
    test('should create CompressionInfo with valid data', () {
      final compressionInfo = CompressionInfo(
        originalSize: 1000000,
        compressedSize: 500000,
        compressionRatio: 0.5,
        algorithm: 'gzip',
        processingTime: const Duration(milliseconds: 500),
      );

      expect(compressionInfo.originalSize, 1000000);
      expect(compressionInfo.compressedSize, 500000);
      expect(compressionInfo.compressionRatio, 0.5);
      expect(compressionInfo.algorithm, 'gzip');
      expect(compressionInfo.processingTime, const Duration(milliseconds: 500));
    });

    test('should convert CompressionInfo to and from JSON', () {
      final compressionInfo = CompressionInfo(
        originalSize: 2000000,
        compressedSize: 800000,
        compressionRatio: 0.6,
        algorithm: 'brotli',
        processingTime: const Duration(milliseconds: 1000),
        metadata: {'quality': 'high', 'method': 'fast'},
      );

      final json = compressionInfo.toJson();
      expect(json['originalSize'], 2000000);
      expect(json['compressedSize'], 800000);
      expect(json['compressionRatio'], 0.6);
      expect(json['algorithm'], 'brotli');
      expect(json['processingTime'], 1000);

      final fromJson = CompressionInfo.fromJson(json);
      expect(fromJson.originalSize, compressionInfo.originalSize);
      expect(fromJson.compressedSize, compressionInfo.compressedSize);
      expect(fromJson.compressionRatio, compressionInfo.compressionRatio);
      expect(fromJson.algorithm, compressionInfo.algorithm);
      expect(fromJson.processingTime, compressionInfo.processingTime);
    });
  });

  group('Message Tests', () {
    test('should create Message with basic properties', () {
      final message = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello, world!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      expect(message.id, 'msg_001');
      expect(message.content, 'Hello, world!');
      expect(message.type, MessageType.text);
      expect(message.status, MessageStatus.sent);
      expect(message.priority, MessagePriority.normal); // default value
    });

    test('should calculate total reactions correctly', () {
      final message = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        reactions: [
          MessageReaction(
            emoji: '👍',
            userIds: ['user1', 'user2'],
            count: 2,
            timestamp: DateTime.now(),
          ),
          MessageReaction(
            emoji: '❤️',
            userIds: ['user3'],
            count: 1,
            timestamp: DateTime.now(),
          ),
        ],
      );

      expect(message.totalReactions, 3);
    });

    test('should add and remove reactions correctly', () {
      final message = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      // Add first reaction
      final withReaction = message.addReaction('user_002', '👍');
      expect(withReaction.reactions!.length, 1);
      expect(withReaction.reactions!.first.emoji, '👍');
      expect(withReaction.reactions!.first.count, 1);

      // Add same emoji from different user
      final withMoreReactions = withReaction.addReaction('user_003', '👍');
      expect(withMoreReactions.reactions!.length, 1);
      expect(withMoreReactions.reactions!.first.count, 2);

      // Remove reaction
      final withRemovedReaction = withMoreReactions.removeReaction(
        'user_002',
        '👍',
      );
      expect(withRemovedReaction.reactions!.length, 1);
      expect(withRemovedReaction.reactions!.first.count, 1);

      // Remove last reaction
      final withoutReactions = withRemovedReaction.removeReaction(
        'user_003',
        '👍',
      );
      expect(withoutReactions.reactions!.isEmpty, true);
    });

    test('should check user reactions correctly', () {
      final message = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        reactions: [
          MessageReaction(
            emoji: '👍',
            userIds: ['user1', 'user2'],
            count: 2,
            timestamp: DateTime.now(),
          ),
        ],
      );

      expect(message.hasUserReaction('user1', '👍'), true);
      expect(message.hasUserReaction('user3', '👍'), false);
      expect(message.hasUserReaction('user1', '❤️'), false);
    });

    test('should identify Helpy messages correctly', () {
      final helpyMessage = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'helpy_001',
        senderName: 'Helpy',
        content: 'Hello! How can I help you?',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      final userMessage = Message(
        id: 'msg_002',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'User',
        content: 'Hi there!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      expect(helpyMessage.isFromHelpy, true);
      expect(userMessage.isFromHelpy, false);
    });
  });

  group('Message JSON Serialization Tests', () {
    test('should convert Message to and from JSON correctly', () {
      final originalMessage = Message(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello, world!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.parse('2024-01-01T12:00:00Z'),
        priority: MessagePriority.high,
        isEdited: true,
        editedAt: DateTime.parse('2024-01-01T12:05:00Z'),
      );

      final json = originalMessage.toJson();
      final reconstructedMessage = Message.fromJson(json);

      expect(reconstructedMessage.id, originalMessage.id);
      expect(
        reconstructedMessage.conversationId,
        originalMessage.conversationId,
      );
      expect(reconstructedMessage.content, originalMessage.content);
      expect(reconstructedMessage.type, originalMessage.type);
      expect(reconstructedMessage.status, originalMessage.status);
      expect(reconstructedMessage.priority, originalMessage.priority);
      expect(reconstructedMessage.isEdited, originalMessage.isEdited);
      expect(reconstructedMessage.timestamp, originalMessage.timestamp);
      expect(reconstructedMessage.editedAt, originalMessage.editedAt);
    });
  });

  group('ChatSettings Tests', () {
    test('should create ChatSettings with valid AI model settings', () {
      final modelSettings = AIModelSettings(
        modelId: 'gpt-4',
        temperature: 0.7,
        topP: 0.9,
        topK: 50,
        maxTokens: 2048,
      );

      expect(modelSettings.temperature, 0.7);
      expect(modelSettings.topP, 0.9);
      expect(modelSettings.topK, 50);
      expect(modelSettings.isValid, true);
    });

    test('should validate AI model settings correctly', () {
      final validSettings = AIModelSettings(
        temperature: 1.0,
        topP: 0.8,
        topK: 40,
        maxTokens: 1024,
        presencePenalty: 0.5,
        frequencyPenalty: -0.5,
      );

      final invalidSettings = AIModelSettings(
        temperature: 3.0, // Invalid: > 2.0
        topP: 1.5, // Invalid: > 1.0
        topK: -1, // Invalid: <= 0
        maxTokens: 0, // Invalid: <= 0
        presencePenalty: 3.0, // Invalid: > 2.0
        frequencyPenalty: -3.0, // Invalid: < -2.0
      );

      expect(validSettings.isValid, true);
      expect(invalidSettings.isValid, false);
    });

    test('should determine creativity level from temperature', () {
      expect(
        AIModelSettings(temperature: 0.2).creativityLevel,
        CreativityLevel.conservative,
      );
      expect(
        AIModelSettings(temperature: 0.5).creativityLevel,
        CreativityLevel.balanced,
      );
      expect(
        AIModelSettings(temperature: 1.0).creativityLevel,
        CreativityLevel.creative,
      );
      expect(
        AIModelSettings(temperature: 1.5).creativityLevel,
        CreativityLevel.experimental,
      );
    });

    test('should determine focus level from topP', () {
      expect(AIModelSettings(topP: 0.3).focusLevel, FocusLevel.focused);
      expect(AIModelSettings(topP: 0.7).focusLevel, FocusLevel.balanced);
      expect(AIModelSettings(topP: 0.9).focusLevel, FocusLevel.diverse);
    });
  });
}
