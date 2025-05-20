import 'dart:async';
import 'package:amazon_chime_sdk_call/amazon_chime_sdk_call.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_models.dart';
import 'auth_service.dart';

class CallService with ChangeNotifier {
  final AuthService _authService;
  late ChimeSdkCallClient _callClient;
  
  // Call state management
  bool _isCallInitialized = false;
  bool _isInCall = false;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOn = false;
  CallDirection? _callDirection;
  String? _callId;
  String? _meetingId;
  ChatUser? _remoteUser;
  
  // Your AWS Lambda API Gateway endpoint for creating meetings
  final String _apiGatewayEndpoint = 'YOUR_API_GATEWAY_ENDPOINT';
  
  // Constructor
  CallService(this._authService) {
    _initializeCallClient();
  }
  
  // Getters
  bool get isCallInitialized => _isCallInitialized;
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraOn => _isCameraOn;
  CallDirection? get callDirection => _callDirection;
  String? get callId => _callId;
  ChatUser? get remoteUser => _remoteUser;
  
  // Initialize the call client
  Future<void> _initializeCallClient() async {
    try {
      _callClient = await ChimeSdkCallClient.create();
      
      _callClient.addListener(_callClientListener);
      
      _isCallInitialized = true;
      notifyListeners();
      debugPrint('Call client initialized successfully');
    } catch (e) {
      debugPrint('Error initializing call client: $e');
    }
  }
  
  // Call client listener
  void _callClientListener(ChimeSdkCallClientEvent event) {
    if (event is IncomingCallEvent) {
      _handleIncomingCall(event);
    } else if (event is CallStateUpdatedEvent) {
      _handleCallStateUpdated(event);
    } else if (event is CallFailedEvent) {
      _handleCallFailed(event);
    }
  }
  
  // Handle incoming call
  void _handleIncomingCall(IncomingCallEvent event) {
    _isInCall = true;
    _callId = event.call.callId;
    _callDirection = CallDirection.incoming;
    
    // Fetch user details based on caller ID
    _fetchRemoteUserDetails(event.call.callerId);
    
    notifyListeners();
  }
  
  // Handle call state updates
  void _handleCallStateUpdated(CallStateUpdatedEvent event) {
    final call = event.call;
    
    switch (call.state) {
      case CallState.connecting:
        debugPrint('Call connecting');
        break;
      case CallState.connected:
        debugPrint('Call connected');
        _isInCall = true;
        break;
      case CallState.disconnecting:
        debugPrint('Call disconnecting');
        break;
      case CallState.disconnected:
        debugPrint('Call disconnected');
        _resetCallState();
        break;
      default:
        break;
    }
    
    notifyListeners();
  }
  
  // Handle call failures
  void _handleCallFailed(CallFailedEvent event) {
    debugPrint('Call failed: ${event.exception}');
    _resetCallState();
    notifyListeners();
  }
  
  // Reset call state after call ends
  void _resetCallState() {
    _isInCall = false;
    _isMuted = false;
    _isSpeakerOn = false;
    _isCameraOn = false;
    _callDirection = null;
    _callId = null;
    _meetingId = null;
    _remoteUser = null;
  }
  
  // Fetch remote user details
  Future<void> _fetchRemoteUserDetails(String userId) async {
    // In a real app, you'd fetch this from your backend or local cache
    // This is a placeholder implementation
    // API call to get user details would go here
    _remoteUser = ChatUser(
      id: userId,
      name: 'Fetching...', // Placeholder until actual data is fetched
      profilePicture: '',
      isOnline: true,
    );
    notifyListeners();
  }
  
  // Start a call
  Future<bool> startCall(ChatUser user, bool isVideo) async {
    if (!_isCallInitialized) {
      await _initializeCallClient();
    }
    
    try {
      _remoteUser = user;
      _callDirection = CallDirection.outgoing;
      _isCameraOn = isVideo;
      
      // Create a meeting via your API Gateway endpoint (AWS Lambda)
      final meetingResponse = await _createMeeting();
      if (meetingResponse == null) return false;
      
      _meetingId = meetingResponse['meetingId'];
      
      // Join the meeting
      await _callClient.join(
        JoinConfig(
          meetingId: _meetingId!,
          callId: DateTime.now().millisecondsSinceEpoch.toString(),
          attendeeName: _authService.user?.name ?? 'User',
          calleeIds: [user.id],
          isVideoEnabled: isVideo,
        ),
      );
      
      _isInCall = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting call: $e');
      _resetCallState();
      notifyListeners();
      return false;
    }
  }
  
  // Create a meeting via API Gateway/Lambda
  Future<Map<String, dynamic>?> _createMeeting() async {
    try {
      final response = await http.post(
        Uri.parse('$_apiGatewayEndpoint/meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN', // You'd use a real token here
        },
        body: jsonEncode({
          'userId': _authService.user?.id,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error creating meeting: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating meeting: $e');
      return null;
    }
  }
  
  // Answer an incoming call
  Future<bool> answerCall() async {
    if (!_isInCall || _callId == null) return false;
    
    try {
      await _callClient.answer(_callId!);
      return true;
    } catch (e) {
      debugPrint('Error answering call: $e');
      return false;
    }
  }
  
  // Decline or end a call
  Future<bool> endCall() async {
    if (!_isInCall || _callId == null) return false;
    
    try {
      await _callClient.hangup(_callId!);
      _resetCallState();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error ending call: $e');
      return false;
    }
  }
  
  // Toggle mute
  Future<bool> toggleMute() async {
    if (!_isInCall || _callId == null) return false;
    
    try {
      if (_isMuted) {
        await _callClient.unmute(_callId!);
      } else {
        await _callClient.mute(_callId!);
      }
      
      _isMuted = !_isMuted;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling mute: $e');
      return false;
    }
  }
  
  // Toggle speaker
  Future<bool> toggleSpeaker() async {
    if (!_isInCall || _callId == null) return false;
    
    try {
      await _callClient.setSpeakerOn(!_isSpeakerOn);
      _isSpeakerOn = !_isSpeakerOn;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling speaker: $e');
      return false;
    }
  }
  
  // Toggle camera
  Future<bool> toggleCamera() async {
    if (!_isInCall || _callId == null) return false;
    
    try {
      if (_isCameraOn) {
        await _callClient.disableVideo(_callId!);
      } else {
        await _callClient.enableVideo(_callId!);
      }
      
      _isCameraOn = !_isCameraOn;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling camera: $e');
      return false;
    }
  }
  
  // Dispose resources
  @override
  void dispose() {
    _callClient.removeListener(_callClientListener);
    super.dispose();
  }
}

enum CallDirection {
  incoming,
  outgoing,
}