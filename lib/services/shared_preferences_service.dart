import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static SharedPreferences get preferences {
    if (_preferences == null) {
      throw Exception('SharedPreferences not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    return await preferences.setString(key, value);
  }

  static String? getString(String key) {
    return preferences.getString(key);
  }

  // Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    return await preferences.setBool(key, value);
  }

  static bool? getBool(String key) {
    return preferences.getBool(key);
  }

  // Integer operations
  static Future<bool> setInt(String key, int value) async {
    return await preferences.setInt(key, value);
  }

  static int? getInt(String key) {
    return preferences.getInt(key);
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    return await preferences.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return preferences.getDouble(key);
  }

  // List of strings operations
  static Future<bool> setStringList(String key, List<String> value) async {
    return await preferences.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return preferences.getStringList(key);
  }

  // JSON operations (for complex objects)
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await preferences.setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    final jsonString = preferences.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding JSON for key $key: $e');
        return null;
      }
    }
    return null;
  }

  // List of objects operations
  static Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    return await preferences.setString(key, jsonEncode(value));
  }

  static List<Map<String, dynamic>>? getObjectList(String key) {
    final jsonString = preferences.getString(key);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding JSON list for key $key: $e');
        return null;
      }
    }
    return null;
  }

  // Remove operations
  static Future<bool> remove(String key) async {
    return await preferences.remove(key);
  }

  // Clear all data
  static Future<bool> clear() async {
    return await preferences.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return preferences.containsKey(key);
  }

  // Get all keys
  static Set<String> getKeys() {
    return preferences.getKeys();
  }

  // App-specific preference keys (constants for consistency)
  static const String keyUserTheme = 'user_theme';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserProfilePicture = 'user_profile_picture';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLastSeenTimestamp = 'last_seen_timestamp';
  static const String keyChatBackupEnabled = 'chat_backup_enabled';
  static const String keyAppVersion = 'app_version';

  // Convenience methods for app-specific preferences
  static Future<bool> setUserTheme(String theme) async {
    return await setString(keyUserTheme, theme);
  }

  static String getUserTheme() {
    return getString(keyUserTheme) ?? 'system'; // default to system theme
  }

  static Future<bool> setIsFirstLaunch(bool isFirst) async {
    return await setBool(keyIsFirstLaunch, isFirst);
  }

  static bool getIsFirstLaunch() {
    return getBool(keyIsFirstLaunch) ?? true; // default to true
  }

  static Future<bool> setUserId(String userId) async {
    return await setString(keyUserId, userId);
  }

  static String? getUserId() {
    return getString(keyUserId);
  }

  static Future<bool> setUserName(String userName) async {
    return await setString(keyUserName, userName);
  }

  static String? getUserName() {
    return getString(keyUserName);
  }

  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool(keyNotificationsEnabled, enabled);
  }

  static bool getNotificationsEnabled() {
    return getBool(keyNotificationsEnabled) ?? true; // default to enabled
  }

  static Future<bool> setLastSeenTimestamp(int timestamp) async {
    return await setInt(keyLastSeenTimestamp, timestamp);
  }

  static int? getLastSeenTimestamp() {
    return getInt(keyLastSeenTimestamp);
  }

  static Future<bool> setChatBackupEnabled(bool enabled) async {
    return await setBool(keyChatBackupEnabled, enabled);
  }

  static bool getChatBackupEnabled() {
    return getBool(keyChatBackupEnabled) ?? false; // default to disabled
  }

  static Future<bool> setAppVersion(String version) async {
    return await setString(keyAppVersion, version);
  }

  static String? getAppVersion() {
    return getString(keyAppVersion);
  }
}