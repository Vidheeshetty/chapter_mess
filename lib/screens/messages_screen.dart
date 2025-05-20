import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  List<ChatUser> users = [];
  List<ChatUser> newMatches = [];
  late AnimationController _listAnimationController;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _listAnimationController.forward();
    });
  }

  void _initializeData() {
    // Sample new matches
    newMatches = [
      ChatUser(id: '1', name: 'Emma', profilePicture: '', isOnline: true),
      ChatUser(id: '2', name: 'James', profilePicture: '', isOnline: false),
      ChatUser(id: '3', name: 'Sofia', profilePicture: '', isOnline: true),
      ChatUser(id: '4', name: 'Alex', profilePicture: '', isOnline: false),
      ChatUser(id: '5', name: 'Maya', profilePicture: '', isOnline: true),
      ChatUser(id: '6', name: 'David', profilePicture: '', isOnline: false),
      ChatUser(id: '7', name: 'Lisa', profilePicture: '', isOnline: true),
    ];

    // Sample chat users with messages
    users = [
      ChatUser(
        id: 'user_1',
        name: 'Sarah M',
        profilePicture: '',
        isOnline: true,
        messages: [
          Message(
            id: '1',
            content: "Hey! How's your day going?",
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            isMe: false,
          ),
          Message(
            id: '2',
            content: "Pretty good! Just got back from the gym",
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: true,
          ),
          Message(
            id: '3',
            content: "Nice! I've been meaning to start a new workout routine. Any recommendations?",
            timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
            isMe: false,
          ),
        ],
      ),
      ChatUser(
        id: 'user_2',
        name: 'James T',
        profilePicture: '',
        isOnline: false,
        messages: [
          Message(
            id: '4',
            content: "Let's meet at the coffee shop!",
            timestamp: DateTime.now().subtract(const Duration(hours: 11, minutes: 32)),
            isMe: false,
          ),
          Message(
            id: '5',
            content: "Sure! What time works best for you?",
            timestamp: DateTime.now().subtract(const Duration(hours: 11, minutes: 30)),
            isMe: true,
          ),
        ],
      ),
      ChatUser(
        id: 'user_3',
        name: 'Maria P',
        profilePicture: '',
        isOnline: true,
        messages: [
          Message(
            id: '6',
            content: "Sure, I'd love to see that movie",
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isMe: false,
          ),
          Message(
            id: '7',
            content: "Great! I'll book the tickets for tomorrow evening",
            timestamp: DateTime.now().subtract(const Duration(hours: 23, minutes: 45)),
            isMe: true,
          ),
        ],
      ),
      ChatUser(
        id: 'user_4',
        name: 'David R',
        profilePicture: '',
        isOnline: false,
        messages: [
          Message(
            id: '8',
            content: "What time works for tomorrow?",
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isMe: false,
          ),
          Message(
            id: '9',
            content: "I'm free after 3 PM. Does that work?",
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isMe: true,
          ),
        ],
      ),
      ChatUser(
        id: 'user_5',
        name: 'Kate L',
        profilePicture: '',
        isOnline: true,
        messages: [
          Message(
            id: '10',
            content: "👍 Still there?",
            timestamp: DateTime.now().subtract(const Duration(days: 10)),
            isMe: false,
          ),
        ],
      ),
      ChatUser(
        id: 'user_6',
        name: 'Michael K',
        profilePicture: '',
        isOnline: false,
        messages: [
          Message(
            id: '11',
            content: "Thanks for the recommendation!",
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            isMe: false,
          ),
        ],
      ),
    ];
  }

  void _deleteChat(ChatUser user) {
    setState(() {
      users.removeWhere((u) => u.id == user.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat with ${user.name} deleted'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              users.add(user);
              users.sort((a, b) => b.messages.isNotEmpty && a.messages.isNotEmpty
                  ? b.messages.last.timestamp.compareTo(a.messages.last.timestamp)
                  : 0);
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(users),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                // Navigate to settings
                  break;
                case 'help':
                // Show help
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _listAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _listAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - _listAnimation.value)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Matches Section
                  if (newMatches.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Matches',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: newMatches.length,
                              itemBuilder: (context, index) {
                                final match = newMatches[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle new match tap
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(user: match),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getAvatarColor(match.name),
                                                    _getAvatarColor(match.name).withOpacity(0.7),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getAvatarColor(match.name).withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  match.name[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (match.isOnline)
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Theme.of(context).scaffoldBackgroundColor,
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          match.name.split(' ')[0],
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Divider
                  if (newMatches.isNotEmpty)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),

                  // Recent Chats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Recent Chats',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // Chat List
                  Expanded(
                    child: users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildChatTile(user, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Messages tab
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outlined),
            activeIcon: Icon(Icons.favorite),
            label: 'Likes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
          switch (index) {
            case 0:
            // Navigate to Home
              break;
            case 1:
            // Already on Messages
              break;
            case 2:
            // Navigate to Likes
              break;
            case 3:
            // Navigate to Profile
              break;
          }
        },
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show new chat options
          _showNewChatOptions(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(ChatUser user, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeInOut,
      child: Dismissible(
        key: Key(user.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Chat'),
                content: Text('Are you sure you want to delete your conversation with ${user.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) => _deleteChat(user),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarColor(user.name),
                        _getAvatarColor(user.name).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getAvatarColor(user.name).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              user.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.lastMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.lastMessageTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 6),
                // Unread indicator
                if (user.messages.isNotEmpty && !user.messages.last.isMe)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(user: user),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with someone new!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNewChatOptions(context),
            icon: const Icon(Icons.add),
            label: const Text('Start Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start a new conversation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Find new people'),
                subtitle: const Text('Discover and connect with new people'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to people discovery
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan QR code'),
                subtitle: const Text('Scan someone\'s QR code to connect'),
                onTap: () {
                  Navigator.pop(context);
                  // Open QR scanner
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share your profile'),
                subtitle: const Text('Share your profile with others'),
                onTap: () {
                  Navigator.pop(context);
                  // Share profile
                },
              ),
            ],
          ),
        );
      },
    );
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
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];
    return colors[name.hashCode % colors.length];
  }
}

// Search delegate for chat search functionality
class ChatSearchDelegate extends SearchDelegate<ChatUser?> {
  final List<ChatUser> users;

  ChatSearchDelegate(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = users
        .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getAvatarColor(user.name),
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(user.name),
          subtitle: Text(user.lastMessage),
          onTap: () {
            close(context, user);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(user: user),
              ),
            );
          },
        );
      },
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFFF6B7A),
      const Color(0xFF6B9DFF),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9B7AFF),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFF3F51B5),
    ];
    return colors[name.hashCode % colors.length];
  }
}