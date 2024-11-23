import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gcom_app/model/userModel.dart';
import 'package:gcom_app/package/ChatScreen.dart'; // Ensure this is the correct path
import 'package:gcom_app/services/UserService.dart'
    as user_service; // Gunakan alias di sini
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart'; // Add jwt_decoder package in pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';

// Model for User

// Service to fetch user data from API
class UserService {
  final String baseUrl =
      'http://10.0.2.2:8080/users'; // Ganti dengan URL API Anda

  Future<List<User>> fetchUsers() async {
    // Mengambil token dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken =
        prefs.getString('accesToken'); // Pastikan kunci sesuai

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    // Membuat permintaan GET untuk mengambil pengguna
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Menyertakan token dalam header
      },
    );

    // Memeriksa status respons
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

// Main page to display users
class UserListChat extends StatefulWidget {
  @override
  _UserListChatState createState() => _UserListChatState();
}

class _UserListChatState extends State<UserListChat> {
  late Future<List<User>> futureUsers;
  String userEmail = ''; // Current user email
  String userId = '';

  @override
  void initState() {
    super.initState();
    futureUsers =
        UserService().fetchUsers(); // Fetch user list on initialization
    decodeToken(); // Decode token to get user info
  }

  Future<void> decodeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    if (accessToken != null) {
      Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
      setState(() {
        userEmail = payload['sub'].split(',')[1];
        userId = payload['sub'].split(',')[0]; // Get email from token
      });
    } else {
      print("Token not found.");
    }
  }

  void showNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> createRoom(User user, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    if (accessToken == null) {
      print('Access token is null');
      showNotification('Access token not found');
      return; // Keluar dari fungsi jika token tidak ditemukan
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/chatrooms');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Sertakan token di header
        },
        body: jsonEncode({
          'senderId': userId,
          'receiverId': user.id,
        }));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      int roomId = data['id'];

      // Navigasi ke ChatScreen setelah berhasil membuat room
      navigateToChatScreen(roomId.toString(), user.id.toString(), userId);
    } else {
      // Menangani kesalahan jika chat room sudah ada
      if (response.statusCode == 409) {
        // Misalnya, 409 Conflict untuk chat room sudah ada
        showNotification('Chat sudah ada.');
      } else {
        print('An error occurred: ${response.body}');
      }
    }
  }

  void navigateToChatScreen(
      String roomId, String receiverId, String userId) async {
    try {
      // Ambil detail pengguna
      User user = await user_service.UserService().fetchUser(receiverId);

      // Cek apakah pengguna berhasil diambil
      if (user != null) {
        print(
            'Navigating to chat screen with: roomId: $roomId, user: ${user.email}, senderId: $userId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chatscreen(
              user: user,
              roomId: roomId,
              senderId: userId,
            ),
          ),
        );
      } else {
        showNotification('Gagal mengambil detail pengguna.');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String defaultProfileImagePath =
        'lib/image/image.png'; // Path to default image

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna'),
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada pengguna ditemukan.'));
          }

          List<User> users = snapshot.data!
              .where((user) =>
                  user.email !=
                  userEmail) // Filter out the logged-in user by email
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: users[index].profileImage.isNotEmpty
                      ? NetworkImage(users[index]
                          .profileImage) // Use NetworkImage if URL exists
                      : AssetImage(defaultProfileImagePath)
                          as ImageProvider, // Use default asset image if not
                ),
                title: Text(users[index].email),
                onTap: () => createRoom(
                    users[index], userId), // Navigate to ChatScreen on user tap
              );
            },
          );
        },
      ),
    );
  }
}
