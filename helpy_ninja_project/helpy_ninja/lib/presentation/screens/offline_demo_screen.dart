import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';
import '../../data/providers/sync_provider.dart';
import '../../data/providers/realtime_chat_provider.dart';
import '../widgets/sync/sync_status_widget.dart';
import '../widgets/chat/connection_status_widget.dart';
import '../widgets/chat/realtime_chat_example.dart';

/// Demo screen showcasing the complete offline-first architecture
class OfflineDemoScreen extends ConsumerStatefulWidget {
  const OfflineDemoScreen({super.key});

  @override
  ConsumerState<OfflineDemoScreen> createState() => _OfflineDemoScreenState();
}

class _OfflineDemoScreenState extends ConsumerState<OfflineDemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize real-time chat connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(realtimeChatProvider.notifier).connect();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First Demo'),
        actions: const [
          CompactConnectionStatusWidget(),
          SizedBox(width: 8),
          CompactSyncStatusWidget(),
          SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.sync), text: 'Sync Status'),
            Tab(icon: Icon(Icons.chat), text: 'Real-time Chat'),
            Tab(icon: Icon(Icons.storage), text: 'Data Explorer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSyncTab(),
          _buildChatTab(),
          _buildDataExplorerTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offline-First Architecture Demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Architecture overview card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.architecture, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Architecture Components',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    'Hive Local Storage',
                    'All data stored locally with type adapters',
                    Icons.storage,
                    Colors.green,
                  ),
                  _buildFeatureItem(
                    'Real-time WebSockets',
                    'Live messaging with automatic reconnection',
                    Icons.wifi,
                    Colors.blue,
                  ),
                  _buildFeatureItem(
                    'Sync Service',
                    'Automatic data synchronization when online',
                    Icons.sync,
                    Colors.orange,
                  ),
                  _buildFeatureItem(
                    'Offline-First',
                    'App works fully offline, syncs when connected',
                    Icons.offline_bolt,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Development flags status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Development Flags Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFlagStatus('Authentication', !AppConstants.enableAuthDuringDevelopment),
                  _buildFlagStatus('Network Requests', !AppConstants.enableNetworkRequests),
                  _buildFlagStatus('WebSocket Connection', !AppConstants.enableWebSocketConnection),
                  _buildFlagStatus('API Calls', !AppConstants.enableApiCalls),
                  _buildFlagStatus('LLM Requests', !AppConstants.enableLLMRequests),
                  _buildFlagStatus('Image Loading', !AppConstants.enableImageLoading),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _forceSync(),
                        icon: const Icon(Icons.sync),
                        label: const Text('Force Sync'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _connectWebSocket(),
                        icon: const Icon(Icons.wifi),
                        label: const Text('Connect WebSocket'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _disconnectWebSocket(),
                        icon: const Icon(Icons.wifi_off),
                        label: const Text('Disconnect WebSocket'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _clearData(),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Local Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SyncStatusWidget(
            showDetails: true,
            showProgress: true,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return const RealtimeChatExample(
      conversationId: 'demo-conversation',
      conversationTitle: 'Demo Chat',
    );
  }

  Widget _buildDataExplorerTab() {
    final syncState = ref.watch(syncProvider);
    final chatState = ref.watch(realtimeChatProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Data Storage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Hive statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storage, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Hive Storage Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataStatRow(
                    'Conversations',
                    syncState.statistics.totalConversations.toString(),
                    Icons.chat_bubble_outline,
                  ),
                  _buildDataStatRow(
                    'Messages',
                    syncState.statistics.totalMessages.toString(),
                    Icons.message,
                  ),
                  _buildDataStatRow(
                    'Lessons',
                    syncState.statistics.totalLessons.toString(),
                    Icons.school,
                  ),
                  _buildDataStatRow(
                    'Learning Sessions',
                    syncState.statistics.totalSessions.toString(),
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Real-time state
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Real-time State',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDataStatRow(
                    'WebSocket Connected',
                    chatState.isConnected ? 'Yes' : 'No',
                    chatState.isConnected ? Icons.check_circle : Icons.cancel,
                  ),
                  _buildDataStatRow(
                    'Active Conversations',
                    chatState.conversations.length.toString(),
                    Icons.chat,
                  ),
                  _buildDataStatRow(
                    'Cached Messages',
                    chatState.messages.length.toString(),
                    Icons.cached,
                  ),
                  _buildDataStatRow(
                    'Online Users',
                    chatState.userPresence.values
                        .where((p) => p.status == 'online')
                        .length
                        .toString(),
                    Icons.people,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFlagStatus(String label, bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDisabled ? Icons.block : Icons.check_circle,
            size: 16,
            color: isDisabled ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            isDisabled ? 'DISABLED' : 'ENABLED',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDisabled ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _forceSync() {
    ref.read(syncProvider.notifier).forceSync();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync started...')),
    );
  }

  void _connectWebSocket() {
    ref.read(realtimeChatProvider.notifier).connect();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to WebSocket...')),
    );
  }

  void _disconnectWebSocket() {
    ref.read(realtimeChatProvider.notifier).disconnect();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disconnected from WebSocket')),
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will clear all locally stored data including messages, '
          'conversations, and progress. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // This would actually clear the data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}