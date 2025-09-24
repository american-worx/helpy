import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../core/services/file_attachment_service.dart';

/// Voice message recording and playback widget
class VoiceMessageWidget extends StatefulWidget {
  final FileAttachment? voiceMessage;
  final Function(FileAttachment)? onVoiceMessageRecorded;
  final VoidCallback? onDelete;
  final bool canRecord;
  final bool canPlay;
  
  const VoiceMessageWidget({
    super.key,
    this.voiceMessage,
    this.onVoiceMessageRecorded,
    this.onDelete,
    this.canRecord = true,
    this.canPlay = true,
  });
  
  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  
  final List<double> _waveformData = [];
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.voiceMessage != null) {
      _initializeExistingVoiceMessage();
    }
  }
  
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }
  
  void _initializeExistingVoiceMessage() {
    // In a real implementation, this would get the actual duration from the audio file
    _totalDuration = const Duration(seconds: 30); // Mock duration
    
    // Generate mock waveform data
    _waveformData.clear();
    for (int i = 0; i < 50; i++) {
      _waveformData.add(math.Random().nextDouble() * 0.8 + 0.2);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.voiceMessage != null) {
      return _buildPlaybackWidget(context);
    }
    
    if (_isRecording) {
      return _buildRecordingWidget(context);
    }
    
    return _buildRecordButton(context);
  }
  
  Widget _buildRecordButton(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onLongPressCancel: () => _cancelRecording(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
  
  Widget _buildRecordingWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          _buildWaveform(),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.stop,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaybackWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying && !_isPaused ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlaybackWaveform(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_playbackDuration),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (widget.onDelete != null)
            GestureDetector(
              onTap: widget.onDelete,
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildWaveform() {
    return SizedBox(
      width: 60,
      height: 24,
      child: CustomPaint(
        painter: WaveformPainter(
          waveformData: _waveformData,
          color: Theme.of(context).colorScheme.onErrorContainer,
          isRecording: true,
        ),
      ),
    );
  }
  
  Widget _buildPlaybackWaveform() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _playbackDuration.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;
    
    return SizedBox(
      height: 30,
      child: CustomPaint(
        painter: WaveformPainter(
          waveformData: _waveformData,
          color: Theme.of(context).colorScheme.primary,
          progressColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          progress: progress,
          isRecording: false,
        ),
      ),
    );
  }
  
  void _startRecording() {
    if (!widget.canRecord) return;
    
    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _waveformData.clear();
    });
    
    _pulseController.repeat(reverse: true);
    
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingDuration = Duration(milliseconds: timer.tick * 100);
        
        // Add random waveform data during recording
        if (_waveformData.length < 100) {
          _waveformData.add(math.Random().nextDouble() * 0.8 + 0.2);
        }
      });
    });
    
    // In a real implementation, start actual audio recording here
    _simulateRecording();
  }
  
  void _stopRecording() {
    if (!_isRecording) return;
    
    _recordingTimer?.cancel();
    _pulseController.stop();
    
    setState(() {
      _isRecording = false;
    });
    
    // In a real implementation, stop recording and process the audio file
    _simulateRecordingComplete();
  }
  
  void _cancelRecording() {
    if (!_isRecording) return;
    
    _recordingTimer?.cancel();
    _pulseController.stop();
    
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
      _waveformData.clear();
    });
  }
  
  void _togglePlayback() {
    if (!widget.canPlay) return;
    
    if (_isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }
  
  void _startPlayback() {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
    
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _playbackDuration = Duration(milliseconds: timer.tick * 100);
        
        if (_playbackDuration >= _totalDuration) {
          _stopPlayback();
        }
      });
    });
    
    // In a real implementation, start actual audio playback here
  }
  
  void _pausePlayback() {
    _playbackTimer?.cancel();
    
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }
  
  void _stopPlayback() {
    _playbackTimer?.cancel();
    
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _playbackDuration = Duration.zero;
    });
  }
  
  void _simulateRecording() {
    // This simulates the recording process
    // In a real implementation, you would use a package like:
    // - flutter_sound
    // - record
    // - audio_recorder
  }
  
  void _simulateRecordingComplete() {
    // Simulate creating a voice message file
    final mockAttachment = FileAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalName: 'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a',
      storedName: 'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a',
      filePath: '/path/to/voice/message.m4a',
      fileType: FileType.audio,
      fileSize: 1024 * 100, // 100KB
      mimeType: 'audio/mp4',
      uploadedAt: DateTime.now(),
    );
    
    widget.onVoiceMessageRecorded?.call(mockAttachment);
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Voice message recorder button
class VoiceRecorderButton extends StatefulWidget {
  final Function(FileAttachment)? onVoiceRecorded;
  final bool enabled;
  
  const VoiceRecorderButton({
    super.key,
    this.onVoiceRecorded,
    this.enabled = true,
  });
  
  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  bool _isRecording = false;
  
  @override
  Widget build(BuildContext context) {
    return VoiceMessageWidget(
      onVoiceMessageRecorded: (attachment) {
        setState(() {
          _isRecording = false;
        });
        widget.onVoiceRecorded?.call(attachment);
      },
      canRecord: widget.enabled,
    );
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final Color? progressColor;
  final double progress;
  final bool isRecording;
  
  WaveformPainter({
    required this.waveformData,
    required this.color,
    this.progressColor,
    this.progress = 0.0,
    this.isRecording = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    
    final progressPaint = Paint()
      ..color = progressColor ?? color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    
    final barWidth = size.width / waveformData.length;
    final progressPosition = size.width * progress;
    
    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = waveformData[i] * size.height;
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;
      
      // Use progress color for bars before the progress position
      paint.color = x <= progressPosition ? color : (progressColor ?? color);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth - 1, barHeight),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Voice message player widget for existing recordings
class VoiceMessagePlayer extends StatefulWidget {
  final FileAttachment voiceMessage;
  final VoidCallback? onDelete;
  
  const VoiceMessagePlayer({
    super.key,
    required this.voiceMessage,
    this.onDelete,
  });
  
  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  @override
  Widget build(BuildContext context) {
    return VoiceMessageWidget(
      voiceMessage: widget.voiceMessage,
      onDelete: widget.onDelete,
      canRecord: false,
      canPlay: true,
    );
  }
}

/// Voice message permission handler
class VoicePermissionWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  
  const VoicePermissionWidget({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });
  
  @override
  Widget build(BuildContext context) {
    // In a real implementation, this would check and request microphone permissions
    // For now, we'll just return the child widget
    return child;
  }
  
  Future<bool> _requestPermission() async {
    // This would use the permission_handler package to request microphone permission
    // For simulation, we'll return true
    return true;
  }
}