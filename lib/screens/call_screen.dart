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
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  Timer? _callTimer;
  CallState _callState = CallState.ringing;
  int _callDuration = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;
  bool _cameraPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startRinging();
    if (widget.isVideoCall) {
      _checkCameraPermission();
    }
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
  }

  void _checkCameraPermission() {
    // Simulate camera permission denied
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _cameraPermissionDenied = true;
        });
      }
    });
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
    _rippleController.stop();
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
    _rippleController.stop();
    Navigator.pop(context);
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
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
        child: Stack(
          children: [
            // Background gradient for video calls
            if (widget.isVideoCall)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

            Column(
              children: [
                // Top bar with back button and call info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: widget.isVideoCall ? Colors.white : null,
                          size: 32,
                        ),
                        onPressed: _endCall,
                      ),
                      const Spacer(),
                      Text(
                        _getCallStatusText(),
                        style: TextStyle(
                          color: widget.isVideoCall
                              ? Colors.white
                              : Theme.of(context).colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User avatar with animations
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple effect
                          if (_callState == CallState.ringing)
                            AnimatedBuilder(
                              animation: _rippleAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 280 + (_rippleAnimation.value * 40),
                                  height: 280 + (_rippleAnimation.value * 40),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _getAvatarColor(widget.user.name)
                                          .withOpacity(0.3 - (_rippleAnimation.value * 0.3)),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Main avatar with pulse effect
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _callState == CallState.ringing
                                    ? _pulseAnimation.value
                                    : 1.0,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getAvatarColor(widget.user.name),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getAvatarColor(widget.user.name).withOpacity(0.4),
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
                        ],
                      ),

                      const SizedBox(height: 40),

                      // User name
                      Text(
                        widget.user.name,
                        style: TextStyle(
                          color: widget.isVideoCall
                              ? Colors.white
                              : Theme.of(context).colorScheme.onBackground,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Call duration or status
                      if (_callState == CallState.connected)
                        Text(
                          _formatDuration(_callDuration),
                          style: TextStyle(
                            color: widget.isVideoCall
                                ? Colors.white70
                                : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              widget.isVideoCall ? 'Incoming video call...' : 'Incoming voice call...',
                              style: TextStyle(
                                color: widget.isVideoCall
                                    ? Colors.white70
                                    : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            if (_callState == CallState.ringing)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (index) {
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300 + (index * 100)),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: widget.isVideoCall
                                            ? Colors.white70
                                            : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Video call error message (when camera permission denied)
                if (widget.isVideoCall && _cameraPermissionDenied && _callState != CallState.ringing)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Camera permission denied',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          // Accept call
          GestureDetector(
            onTap: _acceptCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.call,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      );
    }

    // Connected call controls
    List<Widget> controls = [
      // Mute button
      _buildControlButton(
        icon: _isMuted ? Icons.mic_off : Icons.mic,
        isActive: _isMuted,
        activeColor: Colors.red,
        onTap: () {
          setState(() {
            _isMuted = !_isMuted;
          });
        },
      ),
    ];

    // Add speaker/video toggle based on call type
    if (!widget.isVideoCall) {
      controls.add(
        _buildControlButton(
          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          isActive: _isSpeakerOn,
          activeColor: Theme.of(context).colorScheme.primary,
          onTap: () {
            setState(() {
              _isSpeakerOn = !_isSpeakerOn;
            });
          },
        ),
      );
    } else {
      controls.add(
        _buildControlButton(
          icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
          isActive: !_isVideoEnabled,
          activeColor: Colors.red,
          onTap: () {
            setState(() {
              _isVideoEnabled = !_isVideoEnabled;
            });
          },
        ),
      );
    }

    // End call button
    controls.add(
      _buildControlButton(
        icon: Icons.call_end,
        isActive: true,
        activeColor: Colors.red,
        onTap: _endCall,
        size: 60,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: controls,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? activeColor : Colors.black).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
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
      const Color(0xFFFF6B7A), // Red
      const Color(0xFF6B9DFF), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9B7AFF), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Teal
      const Color(0xFF3F51B5), // Indigo
    ];
    return colors[name.hashCode % colors.length];
  }
}

enum CallState {
  ringing,
  incoming,
  connected,
}