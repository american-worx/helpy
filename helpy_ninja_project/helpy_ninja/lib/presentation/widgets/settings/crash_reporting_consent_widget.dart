import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/crash_reporting_service.dart';
import '../../../core/services/error_reporting_service.dart';

/// Widget for managing crash reporting consent
class CrashReportingConsentWidget extends ConsumerStatefulWidget {
  final bool showAsDialog;
  final VoidCallback? onConsentChanged;
  
  const CrashReportingConsentWidget({
    super.key,
    this.showAsDialog = false,
    this.onConsentChanged,
  });
  
  @override
  ConsumerState<CrashReportingConsentWidget> createState() => _CrashReportingConsentWidgetState();
}

class _CrashReportingConsentWidgetState extends ConsumerState<CrashReportingConsentWidget> {
  bool _crashReportingConsent = false;
  bool _errorReportingConsent = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }
  
  void _loadCurrentSettings() {
    setState(() {
      _crashReportingConsent = CrashReportingService.hasUserConsent;
      _errorReportingConsent = ErrorReportingService.hasUserConsent;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.showAsDialog) {
      return _buildDialog(context, theme);
    }
    
    return _buildWidget(context, theme);
  }
  
  Widget _buildDialog(BuildContext context, ThemeData theme) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.bug_report,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Help Improve the App'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExplanationText(theme),
            const SizedBox(height: 24),
            _buildConsentOptions(theme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSettings,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
  
  Widget _buildWidget(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Privacy & Error Reporting',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExplanationText(theme),
            const SizedBox(height: 20),
            _buildConsentOptions(theme),
            const SizedBox(height: 16),
            _buildCrashStatistics(theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExplanationText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help us improve Helpy Ninja by sharing anonymous error reports.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'What we collect:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('• Error messages and stack traces'),
        _buildBulletPoint('• App performance data'),
        _buildBulletPoint('• Device information (OS, model)'),
        _buildBulletPoint('• Usage patterns (anonymous)'),
        const SizedBox(height: 12),
        Text(
          'What we DON\'T collect:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('• Personal information or messages'),
        _buildBulletPoint('• Passwords or authentication tokens'),
        _buildBulletPoint('• Chat content or learning data'),
        _buildBulletPoint('• Location data'),
      ],
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
  
  Widget _buildConsentOptions(ThemeData theme) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Crash Reports'),
          subtitle: const Text('Send crash reports to help fix critical issues'),
          value: _crashReportingConsent,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _crashReportingConsent = value;
            });
          },
          secondary: const Icon(Icons.bug_report),
        ),
        SwitchListTile(
          title: const Text('Error Reports'),
          subtitle: const Text('Send general error reports and performance data'),
          value: _errorReportingConsent,
          onChanged: _isLoading ? null : (value) {
            setState(() {
              _errorReportingConsent = value;
            });
          },
          secondary: const Icon(Icons.error_outline),
        ),
      ],
    );
  }
  
  Widget _buildCrashStatistics(ThemeData theme) {
    final stats = CrashReportingService.getCrashStatistics();
    
    if (stats.totalCrashes == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('No crashes detected. App is running smoothly!'),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stats.hasFrequentCrashes 
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stats.hasFrequentCrashes ? Icons.warning : Icons.info,
                color: stats.hasFrequentCrashes 
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                'Crash Statistics',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total crashes: ${stats.totalCrashes}'),
          Text('Last 24 hours: ${stats.crashesLast24Hours}'),
          Text('Last week: ${stats.crashesLastWeek}'),
          if (stats.lastCrashTime != null)
            Text('Last crash: ${_formatDateTime(stats.lastCrashTime!)}'),
          if (stats.hasFrequentCrashes) ...[
            const SizedBox(height: 8),
            Text(
              'Frequent crashes detected. Please enable crash reporting to help us fix these issues.',
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Future.wait([
        CrashReportingService.requestUserConsent(_crashReportingConsent),
        ErrorReportingService.requestUserConsent(_errorReportingConsent),
      ]);
      
      widget.onConsentChanged?.call();
      
      if (widget.showAsDialog && mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Show crash reporting consent dialog
Future<bool?> showCrashReportingConsentDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CrashReportingConsentWidget(
      showAsDialog: true,
    ),
  );
}