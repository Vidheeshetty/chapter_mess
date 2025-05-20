import 'dart:convert';
import '../models/chat_models.dart';

class ChatService {
  // In-memory storage for messages and users
  static final Map<String, List<Message>> _messagesCache = {};
  static final List<ChatUser> _usersCache = [];

  static Future<void> saveMessage(String userId, Message message) async {
    // Initialize the list if it doesn't exist
    if (!_messagesCache.containsKey(userId)) {
      _messagesCache[userId] = [];
    }

    // Add the message to the cache
    _messagesCache[userId]!.add(message);
  }

  static Future<List<Message>> getMessages(String userId) async {
    // Return messages from cache, or empty list if none exist
    return _messagesCache[userId] ?? [];
  }

  static Future<void> deleteConversation(String userId) async {
    // Remove messages for this user from cache
    _messagesCache.remove(userId);

    // Also remove the user from the users cache
    _usersCache.removeWhere((user) => user.id == userId);
  }

  static Future<void> saveChatUsers(List<ChatUser> users) async {
    // Clear the current cache and add new users
    _usersCache.clear();
    _usersCache.addAll(users);

    // Also save their messages to the messages cache
    for (var user in users) {
      if (user.messages.isNotEmpty) {
        _messagesCache[user.id] = List.from(user.messages);
      }
    }
  }

  static Future<List<ChatUser>> getChatUsers() async {
    // Create a list to return with updated messages
    List<ChatUser> updatedUsers = [];

    for (var user in _usersCache) {
      // Get the latest messages for this user
      final messages = await getMessages(user.id);

      // Create a new ChatUser with updated messages
      updatedUsers.add(ChatUser(
        id: user.id,
        name: user.name,
        profilePicture: user.profilePicture,
        isOnline: user.isOnline,
        messages: messages,
      ));
    }

    return updatedUsers;
  }

  static Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    // Find the user in the cache and update their online status
    final userIndex = _usersCache.indexWhere((user) => user.id == userId);

    if (userIndex != -1) {
      final user = _usersCache[userIndex];
      _usersCache[userIndex] = ChatUser(
        id: user.id,
        name: user.name,
        profilePicture: user.profilePicture,
        isOnline: isOnline,
        messages: user.messages,
      );
    }
  }

  // Helper method to add a new user to the cache
  static Future<void> addUser(ChatUser user) async {
    // Check if user already exists
    final existingIndex = _usersCache.indexWhere((u) => u.id == user.id);

    if (existingIndex != -1) {
      // Update existing user
      _usersCache[existingIndex] = user;
    } else {
      // Add new user
      _usersCache.add(user);
    }

    // Save their messages to the messages cache
    if (user.messages.isNotEmpty) {
      _messagesCache[user.id] = List.from(user.messages);
    }
  }

  // Helper method to clear all data (useful for logout/reset)
  static Future<void> clearAllData() async {
    _messagesCache.clear();
    _usersCache.clear();
  }

  // Helper method to get message count for a user
  static int getMessageCount(String userId) {
    return _messagesCache[userId]?.length ?? 0;
  }

  // Helper method to get last message for a user
  static Message? getLastMessage(String userId) {
    final messages = _messagesCache[userId];
    if (messages != null && messages.isNotEmpty) {
      return messages.last;
    }
    return null;
  }
}