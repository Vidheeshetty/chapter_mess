import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/chat_models.dart';

class ChatService {
  static const String _messagesKey = 'chat_messages';
  static const String _usersKey = 'chat_users';

  static Future<void> saveMessage(String userId, Message message) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('${_messagesKey}_$userId') ?? '[]';
    final messages = jsonDecode(messagesJson) as List;

    messages.add({
      'id': message.id,
      'content': message.content,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'isMe': message.isMe,
      'type': message.type.name,
      'gifUrl': message.gifUrl,
    });

    await prefs.setString('${_messagesKey}_$userId', jsonEncode(messages));
  }

  static Future<List<Message>> getMessages(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('${_messagesKey}_$userId') ?? '[]';
    final messages = jsonDecode(messagesJson) as List;

    return messages.map((msg) => Message(
      id: msg['id'],
      content: msg['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
      isMe: msg['isMe'],
      type: MessageType.values.firstWhere((e) => e.name == msg['type']),
      gifUrl: msg['gifUrl'],
    )).toList();
  }

  static Future<void> deleteConversation(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_messagesKey}_$userId');
  }

  static Future<void> saveChatUsers(List<ChatUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => {
      'id': user.id,
      'name': user.name,
      'profilePicture': user.profilePicture,
      'isOnline': user.isOnline,
    }).toList();

    await prefs.setString(_usersKey, jsonEncode(usersJson));
  }

  static Future<List<ChatUser>> getChatUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final users = jsonDecode(usersJson) as List;

    List<ChatUser> chatUsers = [];
    for (var user in users) {
      final messages = await getMessages(user['id']);
      chatUsers.add(ChatUser(
        id: user['id'],
        name: user['name'],
        profilePicture: user['profilePicture'],
        isOnline: user['isOnline'],
        messages: messages,
      ));
    }

    return chatUsers;
  }

  static Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    final users = await getChatUsers();
    final userIndex = users.indexWhere((user) => user.id == userId);

    if (userIndex != -1) {
      users[userIndex] = ChatUser(
        id: users[userIndex].id,
        name: users[userIndex].name,
        profilePicture: users[userIndex].profilePicture,
        isOnline: isOnline,
        messages: users[userIndex].messages,
      );
      await saveChatUsers(users);
    }
  }
}