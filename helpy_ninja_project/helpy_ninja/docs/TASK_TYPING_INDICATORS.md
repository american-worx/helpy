# Task: Add Typing Indicators for Group Chat

## Overview
This document describes the implementation plan for adding typing indicators to the group chat feature in the Helpy Ninja application. This feature will show when other participants in a group session are typing, enhancing the real-time collaborative experience.

## Features to Implement

### 1. WebSocket Service Enhancement
- Add methods to send typing indicator events
- Enhance message handling to process incoming typing indicators
- Add typing indicator stream to listen for typing events

### 2. Group Session Notifier Enhancement
- Add methods to send typing indicators through WebSocket
- Implement state management for tracking who is typing
- Add logic to handle incoming typing indicators

### 3. Group Chat Screen Enhancement
- Add UI components to display typing indicators
- Implement logic to show/hide typing indicators
- Add functionality to send typing indicators when user types

## Technical Details

### WebSocket Message Types
1. `typing` - Sent when a participant starts/stops typing
   - `userId`: ID of the user who is typing
   - `sessionId`: ID of the session
   - `isTyping`: Boolean indicating if user is typing or not
   - `timestamp`: When the event occurred

### Data Structures
```dart
class TypingIndicatorEvent {
  final String userId;
  final String sessionId;
  final bool isTyping;
  final DateTime timestamp;
}
```

### Methods to Implement
1. `sendTypingIndicator()` - Send typing indicator through WebSocket
2. `_handleTypingIndicator()` - Handle incoming typing indicators
3. `typingIndicatorStream` - Stream to listen for typing events

## Implementation Plan

### Phase 1: WebSocket Service Enhancement
1. Add typing indicator message handling in [_handleMessage](file:///Volumes/DONKEY/helpy/helpy_ninja_project/helpy_ninja/lib/services/websocket_service.dart#L233-L298)
2. Add [sendTypingIndicator](file:///Volumes/DONKEY/helpy/helpy_ninja_project/helpy_ninja/lib/services/websocket_service.dart#L149-L162) method
3. Add StreamController for typing indicators
4. Add [typingIndicatorStream](file:///Volumes/DONKEY/helpy/helpy_ninja_project/helpy_ninja/lib/services/websocket_service.dart#L33-L34) getter

### Phase 2: Group Session Notifier Enhancement
1. Add method to send typing indicators
2. Add state management for tracking typing users
3. Implement handler for incoming typing indicators

### Phase 3: Group Chat Screen Enhancement
1. Add UI component for typing indicators
2. Implement logic to show who is typing
3. Add functionality to send typing events when user types

### Phase 4: Testing
1. Unit tests for new functionality
2. Integration tests for real-time typing indicators
3. Manual testing with multiple participants

## Files to Modify

### Services
1. `lib/services/websocket_service.dart` - Add typing indicator functionality

### Data Layer
1. `lib/data/providers/group_session_notifier.dart` - Add typing indicator integration

### Presentation Layer
1. `lib/presentation/screens/chat/group_chat_screen.dart` - Add typing indicator UI

## Quality Assurance

### Code Quality
- Follow existing code patterns and conventions
- Add proper documentation and comments
- Ensure no analyzer warnings or errors

### Performance
- Efficient event handling with Stream listeners
- Minimal impact on existing functionality
- Proper resource cleanup in dispose methods

### Testing
- Unit tests for all new functionality
- Integration tests for real-time features
- Manual testing with multiple participants

## Future Enhancements

### Short-term
1. Add timeout mechanism for typing indicators
2. Improve UI/UX for typing indicators
3. Add support for multiple users typing simultaneously

### Long-term
1. Add rich typing indicators with user avatars
2. Implement typing indicator animations
3. Add support for custom typing indicator messages

## Integration with Existing System

### Seamless Integration
- Works with existing group session infrastructure
- Maintains compatibility with current state management
- Follows established coding patterns and conventions

### Backward Compatibility
- No breaking changes to existing APIs
- Maintains data structure compatibility
- Preserves existing functionality while adding new capabilities