import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chat_models.dart';

class CallScreen extends StatefulWidget {
  final ChatUser user;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.user,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _callTimer;
  CallState _callState = CallState.ringing;
  int _callDuration = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startRinging();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _startRinging() {
    Timer(const Duration(seconds: 3), () {
      if (mounted && _callState == CallState.ringing) {
        setState(() {
          _callState = CallState.incoming;
        });
      }
    });
  }

  void _acceptCall() {
    setState(() {
      _callState = CallState.connected;
    });
    _pulseController.stop();
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _pulseController.stop();
    Navigator.pop(context);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isVideoCall
          ? Colors.black
          : Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Call status
                  Text(
                    _getCallStatusText(),
                    style: TextStyle(
                      color: widget.isVideoCall ? Colors.white : Theme.of(context).colorScheme.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // User avatar
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _callState == CallState.ringing
                            ? _pulseAnimation.value
                            : 1.0,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getAvatarColor(widget.user.name),
                            boxShadow: [
                              BoxShadow(
                                color: _getAvatarColor(widget.user.name).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // User name
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      color: widget.isVideoCall ? Colors.white : Theme.of(context).colorScheme.onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Call duration or status
                  if (_callState == CallState.connected)
                    Text(
                      _formatDuration(_callDuration),
                      style: TextStyle(
                        color: widget.isVideoCall ? Colors.white70 : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    )
                  else
                    Text(
                      widget.isVideoCall ? 'Incoming video call...' : 'Incoming voice call...',
                      style: TextStyle(
                        color: widget.isVideoCall ? Colors.white70 : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),

            // Video call error message (when camera permission denied)
            if (widget.isVideoCall && _callState != CallState.ringing)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Camera permission denied',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Call controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: _buildCallControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    if (_callState == CallState.ringing) {
      return const SizedBox.shrink();
    }

    if (_callState == CallState.incoming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline call
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.call_end, color: Colors.white, size: 32),
              onPressed: _endCall,
              iconSize: 64,
            ),
          ),
          // Accept call
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.call, color: Colors.white, size: 32),
              onPressed: _acceptCall,
              iconSize: 64,
            ),
          ),
        ],
      );
    }

    // Connected call controls
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute button
        Container(
          decoration: BoxDecoration(
            color: _isMuted ? Colors.red : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
            iconSize: 48,
          ),
        ),

        // Speaker button (voice call only)
        if (!widget.isVideoCall)
          Container(
            decoration: BoxDecoration(
              color: _isSpeakerOn ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSpeakerOn = !_isSpeakerOn;
                });
              },
              iconSize: 48,
            ),
          ),

        // Video toggle (video call only)
        if (widget.isVideoCall)
          Container(
            decoration: BoxDecoration(
              color: _isVideoEnabled ? Colors.grey.withOpacity(0.3) : Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isVideoEnabled = !_isVideoEnabled;
                });
              },
              iconSize: 48,
            ),
          ),

        // End call button
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
            onPressed: _endCall,
            iconSize: 56,
          ),
        ),
      ],
    );
  }

  String _getCallStatusText() {
    switch (_callState) {
      case CallState.ringing:
        return 'Calling...';
      case CallState.incoming:
        return widget.isVideoCall ? 'Incoming Video Call' : 'Incoming Voice Call';
      case CallState.connected:
        return widget.isVideoCall ? 'Video Call' : 'Voice Call';
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[name.hashCode % colors.length];
  }
}

enum CallState {
  ringing,
  incoming,
  connected,
}