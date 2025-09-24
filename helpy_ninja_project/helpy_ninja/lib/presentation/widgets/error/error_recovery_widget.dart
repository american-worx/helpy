import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';

/// Widget for displaying errors with recovery options
class ErrorRecoveryWidget extends ConsumerWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showTechnicalDetails;
  final String? customMessage;
  final List<ErrorAction>? customActions;
  
  const ErrorRecoveryWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onClose,
    this.showTechnicalDetails = false,
    this.customMessage,
    this.customActions,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header
            Row(
              children: [
                Icon(
                  _getErrorIcon(),
                  color: _getErrorColor(theme),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getErrorTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _getErrorColor(theme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customMessage ?? ErrorHandler.getUserFriendlyMessage(error),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recovery suggestions
            if (error.isRecoverable) ...[
              Text(
                'What you can try:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildRecoverySuggestions(context),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (customActions != null) ...[
                  for (final action in customActions!)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: action.isDestructive
                          ? TextButton(
                              onPressed: action.onPressed,
                              child: Text(action.label),
                            )
                          : ElevatedButton(
                              onPressed: action.onPressed,
                              child: Text(action.label),
                            ),
                    ),
                ] else ...[
                  if (error.isRecoverable && onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  TextButton(
                    onPressed: () => _showTechnicalDetails(context),
                    child: const Text('Technical Details'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getErrorIcon() {
    switch (error.type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.timeout:
        return Icons.hourglass_empty;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.parsing:
        return Icons.code_off;
      case ErrorType.unknown:
      default:
        return Icons.error;
    }
  }
  
  Color _getErrorColor(ThemeData theme) {
    switch (error.severity) {
      case ErrorSeverity.critical:
        return theme.colorScheme.error;
      case ErrorSeverity.high:
        return theme.colorScheme.error;
      case ErrorSeverity.medium:
        return theme.colorScheme.onSurfaceVariant;
      case ErrorSeverity.low:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
  
  String _getErrorTitle() {
    switch (error.type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Invalid Input';
      case ErrorType.storage:
        return 'Storage Error';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.timeout:
        return 'Request Timeout';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.parsing:
        return 'Data Error';
      case ErrorType.unknown:
      default:
        return 'Something Went Wrong';
    }
  }
  
  List<Widget> _buildRecoverySuggestions(BuildContext context) {
    final suggestions = _getRecoverySuggestions();
    return suggestions.map((suggestion) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    )).toList();
  }
  
  List<String> _getRecoverySuggestions() {
    switch (error.type) {
      case ErrorType.network:
        return [
          'Check your internet connection',
          'Try again in a moment',
          'Contact support if the problem persists',
        ];
      case ErrorType.authentication:
        return [
          'Sign in again',
          'Check your username and password',
          'Reset your password if needed',
        ];
      case ErrorType.validation:
        return [
          'Check your input data',
          'Make sure all required fields are filled',
          'Ensure the format is correct',
        ];
      case ErrorType.storage:
        return [
          'Free up storage space',
          'Restart the app',
          'Clear app cache in settings',
        ];
      case ErrorType.server:
        return [
          'The server might be under maintenance',
          'Try again later',
          'Contact support if the issue continues',
        ];
      default:
        return [
          'Restart the app',
          'Try again later',
          'Contact support if needed',
        ];
    }
  }
  
  void _showTechnicalDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TechnicalDetailsDialog(error: error),
    );
  }
}

/// Action for error recovery
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final IconData? icon;
  
  const ErrorAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.icon,
  });
}

/// Dialog showing technical error details
class TechnicalDetailsDialog extends StatelessWidget {
  final AppError error;
  
  const TechnicalDetailsDialog({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Technical Details'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Error Type', error.type.name, theme),
              _buildDetailRow('Severity', error.severity.name, theme),
              _buildDetailRow('Message', error.message, theme),
              _buildDetailRow('Timestamp', error.timestamp.toString(), theme),
              if (error.userId != null)
                _buildDetailRow('User ID', error.userId!, theme),
              if (error.sessionId != null)
                _buildDetailRow('Session ID', error.sessionId!, theme),
              if (error.context != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Context:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.context.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Stack Trace:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.stackTrace.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _copyToClipboard(context),
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard(BuildContext context) {
    final errorDetails = {
      'type': error.type.name,
      'severity': error.severity.name,
      'message': error.message,
      'timestamp': error.timestamp.toString(),
      'context': error.context,
      'stackTrace': error.stackTrace.toString(),
    };
    
    Clipboard.setData(ClipboardData(
      text: errorDetails.toString(),
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Global error boundary for widgets
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });
  
  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  
  @override
  void initState() {
    super.initState();
    
    // Catch errors from child widgets
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        
        widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
        ErrorHandler.handleFlutterError(details);
      }
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace!) ??
          ErrorRecoveryWidget(
            error: AppError.fromException(_error!),
            onRetry: () => _retry(),
          );
    }
    
    return widget.child;
  }
  
  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}