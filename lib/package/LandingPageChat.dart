import 'package:flutter/material.dart';
import 'package:gcom_app/model/userModel.dart';
import 'package:gcom_app/package/ChatScreen.dart'; // Ensure this is the correct path
import 'package:gcom_app/package/UserListChat.dart';
import 'package:gcom_app/services/ChatRoomService.dart';
import 'package:gcom_app/services/UserService.dart'
    as user_service; // Use an alias here
import 'package:jwt_decoder/jwt_decoder.dart'; // Ensure you have this package
import 'package:shared_preferences/shared_preferences.dart';

// Model for ChatRoom
class ChatRoom {
  final int id;
  final String? receiverId;

  ChatRoom({
    required this.id,
    this.receiverId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      receiverId:
          json['receiverId'] ?? 'Chat Room', // Default name if not provided
    );
  }
}

// Main page to display chat rooms
class LandingPageChatRooms extends StatefulWidget {
  @override
  _LandingPageChatRoomsState createState() => _LandingPageChatRoomsState();
}

class _LandingPageChatRoomsState extends State<LandingPageChatRooms> {
  late Future<List<ChatRoom>> futureChatRooms;
  String userId = '';

  @override
  void initState() {
    super.initState();
    futureChatRooms = Future.value([]);
    decodeToken();
  }

  Future<void> decodeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken'); // Corrected key

    if (accessToken != null) {
      Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
      setState(() {
        userId = payload['sub'].split(',')[0];
        futureChatRooms = ChatRoomService().fetchChatRooms(userId);
      });
    } else {
      print("Token not found.");
    }
  }

  void navigateToChatScreen(ChatRoom chatRoom) async {
    try {
      // Fetch the user details using the receiverId
      User user = await user_service.UserService()
          .fetchUser(chatRoom.receiverId!); // Use the alias

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chatscreen(
            user: user, // Pass the fetched user
            roomId: chatRoom.id.toString(),
          ),
        ),
      );
    } catch (error) {
      // Handle errors, e.g., show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $error')),
      );
    }
  }

  void navigateToListChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserListChat()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String defaultProfileImagePath =
        'lib/image/image.png'; // Path to default image
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
      ),
      body: FutureBuilder<List<ChatRoom>>(
        future: futureChatRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    'Belum ada chat room.')); // Message when there are no chat rooms
          }

          List<ChatRoom> chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return FutureBuilder<User>(
                future: user_service.UserService().fetchUser(chatRooms[index]
                    .receiverId!), // Fetch user data for each chat room
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'), // Show loading indicator
                    );
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text(
                          'Error: ${userSnapshot.error}'), // Show error message
                    );
                  } else if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text(
                          ' User  not found'), // Handle case where user is not found
                    );
                  }

                  User user = userSnapshot.data!; // Get the fetched user

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profileImage.isNotEmpty
                          ? NetworkImage(user
                              .profileImage) // Use NetworkImage if URL exists
                          : AssetImage(defaultProfileImagePath)
                              as ImageProvider, // Use default asset image if not
                    ),
                    title: Text(
                        user.email ?? 'Unknown User'), // Display user's name
                    onTap: () => navigateToChatScreen(
                        chatRooms[index]), // Navigate to chat screen on tap
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToListChat,
        child: Icon(Icons.add, color: Color(0xFF0E197E)),
        tooltip: 'Tambah Chat',
      ),
    );
  }
}
