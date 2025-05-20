import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../services/call_service.dart';

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

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late CallService _callService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _callService = Provider.of<CallService>(context);
    
    if (!_isInitialized) {
      _isInitialized = true;
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

  Future<void> _startCall() async {
    if (_callService.callDirection == CallDirection.incoming) {
      // This is an incoming call, don't initiate a new one
      return;
    }
    
    // Start a new outgoing call
    final success = await _callService.startCall(widget.user, widget.isVideoCall);
    
    if (!success && mounted) {
      // Show error and navigate back if call fails to start
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start call. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      
      Navigator.of(context).pop();
    }
  }

  Future<void> _acceptCall() async {
    await _callService.answerCall();
    
    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
    
    if (_rippleController.isAnimating) {
      _rippleController.stop();
    }
  }

  Future<void> _endCall() async {
    await _callService.endCall();
    
    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
    
    if (_rippleController.isAnimating) {
      _rippleController.stop();
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallService>(
      builder: (context, callService, child) {
        final user = callService.remoteUser ?? widget.user;
        final isIncomingCall = callService.callDirection == CallDirection.incoming;
        final isConnected = callService.isInCall;
        
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
                            _getCallStatusText(callService),
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
                              if (!isConnected)
                                AnimatedBuilder(
                                  animation: _rippleAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: 280 + (_rippleAnimation.value * 40),
                                      height: 280 + (_rippleAnimation.value * 40),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _getAvatarColor(user.name)
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
                                    scale: !isConnected
                                        ? _pulseAnimation.value
                                        : 1.0,
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getAvatarColor(user.name),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getAvatarColor(user.name).withOpacity(0.4),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          user.name[0].toUpperCase(),
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
                            user.name,
                            style: TextStyle(
                              color: widget.isVideoCall
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onBackground,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Call status text
                          if (isConnected)
                            Text(
                              widget.isVideoCall ? 'Connected video call' : 'Connected voice call',
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
                                  widget.isVideoCall ? 
                                    (isIncomingCall ? 'Incoming video call...' : 'Calling...') : 
                                    (isIncomingCall ? 'Incoming voice call...' : 'Calling...'),
                                  style: TextStyle(
                                    color: widget.isVideoCall
                                        ? Colors.white70
                                        : Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
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

                    // Call controls
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: _buildCallControls(callService),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallControls(CallService callService) {
    final isConnected = callService.isInCall;
    final isIncomingCall = callService.callDirection == CallDirection.incoming;
    
    // Incoming call controls (accept/decline)
    if (isIncomingCall && !isConnected) {
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

    // Outgoing calling or connected call controls
    List<Widget> controls = [
      // Mute button
      _buildControlButton(
        icon: callService.isMuted ? Icons.mic_off : Icons.mic,
        isActive: callService.isMuted,
        activeColor: Colors.red,
        onTap: () => callService.toggleMute(),
      ),
    ];

    // Add speaker/video toggle based on call type
    if (!widget.isVideoCall) {
      controls.add(
        _buildControlButton(
          icon: callService.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
          isActive: callService.isSpeakerOn,
          activeColor: Theme.of(context).colorScheme.primary,
          onTap: () => callService.toggleSpeaker(),
        ),
      );
    } else {
      controls.add(
        _buildControlButton(
          icon: callService.isCameraOn ? Icons.videocam : Icons.videocam_off,
          isActive: !callService.isCameraOn,
          activeColor: Colors.red,
          onTap: () => callService.toggleCamera(),
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

  String _getCallStatusText(CallService callService) {
    final isConnected = callService.isInCall;
    final isIncomingCall = callService.callDirection == CallDirection.incoming;
    
    if (!isConnected) {
      return isIncomingCall ? 'Incoming Call' : 'Calling...';
    } else {
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