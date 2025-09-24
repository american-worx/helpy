import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:logger/logger.dart';

import '../storage/secure_storage.dart';
import '../errors/api_exception.dart';
import '../../config/constants.dart';

/// WebSocket service for real-time communication
class WebSocketService {
  static const String _baseWsUrl = 'wss://api.helpyninja.com/ws';
  
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool _isConnected = false;
  bool _isReconnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  
  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _presenceController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _participantController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();

  WebSocketService(this._secureStorage);

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;

  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Stream of typing indicators
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  /// Stream of user presence updates
  Stream<Map<String, dynamic>> get presenceStream => _presenceController.stream;

  /// Stream of participant updates
  Stream<Map<String, dynamic>> get participantStream => _participantController.stream;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isReconnecting) return;

    // Check if WebSocket connections are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableWebSocketConnection) {
      _logger.w('WebSocket connections disabled for development. Skipping connection.');
      // Simulate successful connection for development
      _isConnected = true;
      _connectionController.add(true);
      return;
    }

    try {
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        throw ApiException(
          message: 'No access token available for WebSocket connection',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      }

      _logger.d('Connecting to WebSocket: $_baseWsUrl');
      
      final uri = Uri.parse('$_baseWsUrl?token=$accessToken');
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to WebSocket stream
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionController.add(true);
      _startHeartbeat();
      
      _logger.d('WebSocket connected successfully');
      
      // Send authentication message
      await _sendAuthMessage(accessToken);
      
    } catch (e) {
      _logger.e('WebSocket connection failed', error: e);
      _isConnected = false;
      _connectionController.add(false);
      
      if (_shouldReconnect) {
        _scheduleReconnect();
      }
      
      rethrow;
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isReconnecting = false;
    
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    
    await _subscription?.cancel();
    _subscription = null;
    
    _isConnected = false;
    _connectionController.add(false);
    
    _logger.d('WebSocket disconnected');
  }

  /// Send a message through WebSocket
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      throw ApiException(
        message: 'WebSocket not connected',
        statusCode: 500,
        type: ApiExceptionType.network,
      );
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      _logger.d('WebSocket message sent: ${message['type']}');
    } catch (e) {
      _logger.e('Failed to send WebSocket message', error: e);
      rethrow;
    }
  }

  /// Send a chat message
  Future<void> sendChatMessage({
    required String conversationId,
    required String content,
    required String messageId,
    String contentType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    await sendMessage({
      'type': 'message',
      'data': {
        'conversationId': conversationId,
        'messageId': messageId,
        'content': content,
        'contentType': contentType,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    await sendMessage({
      'type': 'typing',
      'data': {
        'conversationId': conversationId,
        'isTyping': isTyping,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Join a conversation room
  Future<void> joinConversation(String conversationId) async {
    await sendMessage({
      'type': 'join_conversation',
      'data': {
        'conversationId': conversationId,
      },
    });
  }

  /// Leave a conversation room
  Future<void> leaveConversation(String conversationId) async {
    await sendMessage({
      'type': 'leave_conversation',
      'data': {
        'conversationId': conversationId,
      },
    });
  }

  /// Send message acknowledgment
  Future<void> acknowledgeMessage({
    required String messageId,
    required String status, // 'delivered' or 'read'
  }) async {
    await sendMessage({
      'type': 'message_ack',
      'data': {
        'messageId': messageId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Send authentication message
  Future<void> _sendAuthMessage(String accessToken) async {
    await sendMessage({
      'type': 'auth',
      'data': {
        'token': accessToken,
      },
    });
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data as String);
      final String type = message['type'] ?? 'unknown';
      final Map<String, dynamic> messageData = message['data'] ?? {};

      _logger.d('WebSocket message received: $type');

      // Route message to appropriate stream
      switch (type) {
        case 'message':
        case 'message_update':
        case 'message_delete':
          _messageController.add(message);
          break;
        case 'typing':
          _typingController.add(message);
          break;
        case 'user_presence':
          _presenceController.add(message);
          break;
        case 'participant_joined':
        case 'participant_left':
        case 'participant_update':
          _participantController.add(message);
          break;
        case 'heartbeat_response':
          _logger.d('Heartbeat response received');
          break;
        case 'error':
          _logger.e('WebSocket error: ${messageData['message']}');
          break;
        default:
          _logger.w('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      _logger.e('Failed to parse WebSocket message', error: e);
    }
  }

  /// Handle WebSocket errors
  void _onError(dynamic error) {
    _logger.e('WebSocket error occurred', error: error);
    _isConnected = false;
    _connectionController.add(false);
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle WebSocket disconnection
  void _onDisconnected() {
    _logger.w('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    _heartbeatTimer?.cancel();
    
    if (_shouldReconnect && !_isReconnecting) {
      _scheduleReconnect();
    }
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected && _channel != null) {
        sendMessage({
          'type': 'heartbeat',
          'data': {'timestamp': DateTime.now().toIso8601String()},
        }).catchError((error) {
          _logger.w('Failed to send heartbeat', error: error);
        });
      }
    });
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;
    
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );
    
    _logger.d('Scheduling WebSocket reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    
    _reconnectTimer = Timer(delay, () {
      _isReconnecting = false;
      connect().catchError((error) {
        _logger.e('WebSocket reconnection failed', error: error);
      });
    });
  }

  /// Reset reconnection attempts (call when connection is successful)
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }

  /// Dispose of all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _presenceController.close();
    _participantController.close();
    _connectionController.close();
  }
}