import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  AuthUser? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      _isAuthenticated = session.isSignedIn;
      
      if (_isAuthenticated) {
        await _fetchUserAttributes();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _fetchUserAttributes() async {
    try {
      final result = await Amplify.Auth.fetchUserAttributes();
      final users = await Amplify.Auth.fetchCurrentAuthSession();
      
      if (users is CognitoAuthSession) {
        final cognitoUser = users.userSubResult.value;
        // Create a user object from the attributes
        _user = AuthUser(
          id: cognitoUser,
          name: _getAttributeValue(result, 'name') ?? 'User',
          email: _getAttributeValue(result, 'email') ?? '',
          phoneNumber: _getAttributeValue(result, 'phone_number'),
          profilePicture: _getAttributeValue(result, 'picture'),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user attributes: $e');
    }
  }
  
  String? _getAttributeValue(List<AuthUserAttribute> attributes, String key) {
    try {
      return attributes
          .firstWhere((element) => element.userAttributeKey.toString() == key)
          .value;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
  }) async {
    _setLoading(true);
    try {
      final options = SignUpRequest(
        username: username,
        password: password,
        userAttributes: {
          'email': email,
          'name': name,
        },
      );
      
      final result = await Amplify.Auth.signUp(options: options);
      return result.isSignUpComplete;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    _setLoading(true);
    try {
      final options = ConfirmSignUpRequest(
        username: username,
        confirmationCode: confirmationCode,
      );
      
      final result = await Amplify.Auth.confirmSignUp(options: options);
      return result.isSignUpComplete;
    } catch (e) {
      debugPrint('Error confirming sign up: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final options = SignInRequest(
        username: username,
        password: password,
      );
      
      final result = await Amplify.Auth.signIn(options: options);
      _isAuthenticated = result.isSignedIn;
      
      if (_isAuthenticated) {
        await _fetchUserAttributes();
        notifyListeners();
      }
      
      return _isAuthenticated;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signOut() async {
    _setLoading(true);
    try {
      await Amplify.Auth.signOut();
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing out: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
  });
}