import 'dart:convert';

import 'package:gcom_app/package/LandingPageChat.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomService {
  final String baseUrl =
      'http://10.0.2.2:8080/api/chatrooms'; // Ganti dengan URL API Anda

  Future<List<ChatRoom>> fetchChatRooms(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((room) => ChatRoom.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load chat rooms');
    }
  }
}
