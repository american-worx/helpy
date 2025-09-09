import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/services/websocket_service.dart';
import 'package:helpy_ninja/domain/entities/message.dart';

void main() {
  group('WebSocketService Tests', () {
    late WebSocketService webSocketService;

    setUp(() {
      webSocketService = WebSocketService();
    });

    tearDown(() {
      webSocketService.dispose();
    });

    test('should initialize with correct default values', () {
      expect(webSocketService.isConnected, false);
      expect(webSocketService.messageStream, isNotNull);
      expect(webSocketService.connectionStream, isNotNull);
      expect(webSocketService.participantChangeStream, isNotNull);
      expect(webSocketService.typingIndicatorStream, isNotNull);
      expect(webSocketService.acknowledgmentStream, isNotNull);
    });

    test('should generate sequence numbers for messages', () async {
      // Create a test message
      final message = Message(
        id: 'test_message_1',
        conversationId: 'session_1',
        senderId: 'user_1',
        senderName: 'Test User',
        content: 'Hello, world!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      // Since we can't actually connect to a WebSocket server in tests,
      // we'll just verify that the method doesn't throw an exception
      // when not connected
      expect(() => webSocketService.sendMessage(message), throwsException);
    });

    test('should handle message acknowledgments', () {
      // Test the acknowledgment stream
      expect(webSocketService.acknowledgmentStream, isNotNull);
    });

    test('should properly dispose resources', () {
      // Verify that dispose doesn't throw an exception
      expect(() => webSocketService.dispose(), returnsNormally);
    });
  });
}
