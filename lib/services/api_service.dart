import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import '../models/chat_models.dart';

class ApiService {
  // GraphQL queries and mutations
  static const String _listUsersQuery = '''
    query ListUsers {
      listUsers {
        items {
          id
          name
          profilePicture
          isOnline
          lastSeen
        }
      }
    }
  ''';
  
  static const String _getMessagesQuery = '''
    query GetMessages(\$userId: ID!, \$limit: Int, \$nextToken: String) {
      getMessages(userId: \$userId, limit: \$limit, nextToken: \$nextToken) {
        items {
          id
          content
          timestamp
          isMe
          type
          gifUrl
          sender
          receiver
        }
        nextToken
      }
    }
  ''';
  
  static const String _createMessageMutation = '''
    mutation CreateMessage(\$input: CreateMessageInput!) {
      createMessage(input: \$input) {
        id
        content
        timestamp
        isMe
        type
        gifUrl
        sender
        receiver
      }
    }
  ''';
  
  static const String _updateUserOnlineMutation = '''
    mutation UpdateUserOnline(\$id: ID!, \$isOnline: Boolean!) {
      updateUserOnline(id: \$id, isOnline: \$isOnline) {
        id
        isOnline
        lastSeen
      }
    }
  ''';
  
  // Get all users (for messages screen)
  Future<List<ChatUser>> getUsers() async {
    try {
      final request = GraphQLRequest<String>(
        document: _listUsersQuery,
        variables: {},
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
      
      final data = jsonDecode(response.data!)['listUsers']['items'] as List;
      return data.map((user) => ChatUser(
        id: user['id'],
        name: user['name'],
        profilePicture: user['profilePicture'] ?? '',
        isOnline: user['isOnline'] ?? false,
        messages: [],
      )).toList();
    } catch (e) {
      safePrint('Error getting users: $e');
      rethrow;
    }
  }
  
  // Get messages for a specific user conversation
  Future<List<Message>> getMessages(String userId, {int limit = 50, String? nextToken}) async {
    try {
      final request = GraphQLRequest<String>(
        document: _getMessagesQuery,
        variables: {
          'userId': userId,
          'limit': limit,
          'nextToken': nextToken,
        },
      );
      
      final response = await Amplify.API.query(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
      
      final data = jsonDecode(response.data!)['getMessages']['items'] as List;
      return data.map((msg) => Message(
        id: msg['id'],
        content: msg['content'],
        timestamp: DateTime.parse(msg['timestamp']),
        isMe: msg['isMe'] ?? false,
        type: _parseMessageType(msg['type']),
        gifUrl: msg['gifUrl'],
      )).toList();
    } catch (e) {
      safePrint('Error getting messages: $e');
      rethrow;
    }
  }
  
  // Send a new message
  Future<Message?> sendMessage({
    required String content,
    required String receiverId,
    required String senderId,
    MessageType type = MessageType.text,
    String? gifUrl,
  }) async {
    try {
      final request = GraphQLRequest<String>(
        document: _createMessageMutation,
        variables: {
          'input': {
            'content': content,
            'timestamp': DateTime.now().toIso8601String(),
            'type': type.toString().split('.').last, // Convert enum to string
            'gifUrl': gifUrl,
            'sender': senderId,
            'receiver': receiverId,
            'isMe': true,
          }
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
      
      final data = jsonDecode(response.data!)['createMessage'];
      return Message(
        id: data['id'],
        content: data['content'],
        timestamp: DateTime.parse(data['timestamp']),
        isMe: data['isMe'] ?? false,
        type: _parseMessageType(data['type']),
        gifUrl: data['gifUrl'],
      );
    } catch (e) {
      safePrint('Error sending message: $e');
      return null;
    }
  }
  
  // Update user online status
  Future<bool> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      final request = GraphQLRequest<String>(
        document: _updateUserOnlineMutation,
        variables: {
          'id': userId,
          'isOnline': isOnline,
        },
      );
      
      final response = await Amplify.API.mutate(request: request).response;
      
      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
      
      return true;
    } catch (e) {
      safePrint('Error updating user status: $e');
      return false;
    }
  }
  
  // Helper method to parse message type from string
  MessageType _parseMessageType(String? typeStr) {
    switch (typeStr) {
      case 'gif':
        return MessageType.gif;
      case 'image':
        return MessageType.image;
      case 'document':
        return MessageType.document;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}