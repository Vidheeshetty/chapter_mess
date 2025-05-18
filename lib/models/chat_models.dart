class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final MessageType type;
  final String? gifUrl;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.type = MessageType.text,
    this.gifUrl,
  });
}

enum MessageType {
  text,
  gif,
  image,
  document,
}

class ChatUser {
  final String id;
  final String name;
  final String profilePicture;
  final bool isOnline;
  final List<Message> messages;

  ChatUser({
    required this.id,
    required this.name,
    required this.profilePicture,
    this.isOnline = false,
    this.messages = const [],
  });

  String get lastMessage {
    if (messages.isEmpty) return '';
    final lastMsg = messages.last;
    if (lastMsg.type == MessageType.gif) return '🎭 GIF';
    if (lastMsg.type == MessageType.image) return '📷 Image';
    if (lastMsg.type == MessageType.document) return '📄 Document';
    return lastMsg.content;
  }

  String get lastMessageTime {
    if (messages.isEmpty) return '';
    final now = DateTime.now();
    final lastMsgTime = messages.last.timestamp;
    final difference = now.difference(lastMsgTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}