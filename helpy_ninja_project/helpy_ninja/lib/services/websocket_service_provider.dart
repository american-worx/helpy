import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/services/websocket_service.dart';

/// Provider for the WebSocket service
final websocketServiceProvider = Provider<WebSocketService?>((ref) {
  // In a real implementation, we would initialize the WebSocket service with the user ID
  // For now, we'll return null to indicate that the service is not initialized
  return null;
});
