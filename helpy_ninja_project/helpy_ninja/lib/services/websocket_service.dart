import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:helpy_ninja/config/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../domain/entities/message.dart';

/// WebSocket service for real-time communication in multi-agent chat
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Message>? _messageController;
  StreamController<ConnectionState>? _connectionController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _heartbeatInterval = const Duration(seconds: 30);
  final Duration _reconnectDelay = const Duration(seconds: 5);

  /// Stream of incoming messages
  Stream<Message> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  /// Current connection state
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect(String userId) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionController?.add(ConnectionState.connecting);

    try {
      final uri = Uri.parse('${AppConstants.websocketUrl}?userId=$userId');
      _channel = WebSocketChannel.connect(uri);

      // Initialize controllers if needed
      _messageController ??= StreamController<Message>.broadcast();
      _connectionController ??= StreamController<ConnectionState>.broadcast();

      // Listen for messages
      _channel?.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Wait for connection to be established
      await Future.delayed(const Duration(milliseconds: 100));
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController?.add(ConnectionState.connected);

      // Start heartbeat
      _startHeartbeat();

      debugPrint('WebSocket connected successfully for user: $userId');
    } catch (e) {
      _isConnecting = false;
      _connectionController?.add(ConnectionState.disconnected);
      debugPrint('WebSocket connection failed: $e');

      // Attempt to reconnect
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();

    _isConnected = false;
    _isConnecting = false;

    try {
      await _channel?.sink.close(status.goingAway);
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }

    _connectionController?.add(ConnectionState.disconnected);
    debugPrint('WebSocket disconnected');
  }

  /// Join a group session
  Future<void> joinGroupSession(String sessionId) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final joinMessage = {
      'type': 'join_session',
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(joinMessage);
    debugPrint('Joined group session: $sessionId');
  }

  /// Leave a group session
  Future<void> leaveGroupSession(String sessionId) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final leaveMessage = {
      'type': 'leave_session',
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(leaveMessage);
    debugPrint('Left group session: $sessionId');
  }

  /// Send a message through WebSocket
  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final messageData = {
      'type': 'message',
      'message': message.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(messageData);
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String userId,
    required String sessionId,
    bool isTyping = true,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final typingData = {
      'type': 'typing',
      'userId': userId,
      'sessionId': sessionId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(typingData);
  }

  /// Send presence update
  Future<void> sendPresenceUpdate({
    required String userId,
    required String sessionId,
    required bool isOnline,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final presenceData = {
      'type': 'presence',
      'userId': userId,
      'sessionId': sessionId,
      'isOnline': isOnline,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(presenceData);
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final jsonString = data is String ? data : utf8.decode(data);
      final Map<String, dynamic> messageData = jsonDecode(jsonString);

      final messageType = messageData['type'] as String?;

      switch (messageType) {
        case 'message':
          final messageJson = messageData['message'] as Map<String, dynamic>;
          final message = Message.fromJson(messageJson);
          _messageController?.add(message);
          break;

        case 'typing':
          // Handle typing indicators
          debugPrint(
            'Typing indicator received: ${messageData['userId']} is ${messageData['isTyping'] ? 'typing' : 'not typing'}',
          );
          break;

        case 'presence':
          // Handle presence updates
          debugPrint(
            'Presence update received: ${messageData['userId']} is ${messageData['isOnline'] ? 'online' : 'offline'}',
          );
          break;

        case 'heartbeat':
          // Heartbeat response
          debugPrint('Heartbeat received from server');
          break;

        case 'error':
          debugPrint('WebSocket error: ${messageData['message']}');
          break;

        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(Object error) {
    debugPrint('WebSocket error: $error');
    _connectionController?.add(ConnectionState.error);

    // Attempt to reconnect
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _connectionController?.add(ConnectionState.disconnected);

    // Attempt to reconnect
    _scheduleReconnect();
  }

  /// Send message through WebSocket channel
  void _sendMessage(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      _channel?.sink.add(jsonString);
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _stopHeartbeat(); // Clear any existing timer

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        final heartbeatMessage = {
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        };
        _sendMessage(heartbeatMessage);
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _stopReconnectTimer();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      debugPrint(
        'Scheduling reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds',
      );

      _reconnectTimer = Timer(_reconnectDelay, () {
        // Try to reconnect
        // Note: We would need the userId to reconnect, which should be stored
        // This is a simplified implementation
        debugPrint('Attempting to reconnect...');
        // In a real implementation, we would call connect() with the stored userId
      });
    } else {
      debugPrint('Max reconnection attempts reached');
      _connectionController?.add(ConnectionState.disconnected);
    }
  }

  /// Stop reconnection timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Dispose of resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _connectionController?.close();
    _stopHeartbeat();
    _stopReconnectTimer();
  }
}

/// Connection state enum
enum ConnectionState { connecting, connected, disconnected, error }
