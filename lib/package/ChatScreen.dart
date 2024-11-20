import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gcom_app/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chatscreen extends StatefulWidget {
  final User user; // Menerima pengguna yang dipilih
  final String roomId; // Menerima id chat yang dipilih

  Chatscreen({Key? key, required this.user, required this.roomId})
      : super(key: key);

  @override
  _WebSocketChatAppState createState() => _WebSocketChatAppState();
}

class _WebSocketChatAppState extends State<Chatscreen> {
  final String url = 'ws://10.0.2.2:8080/ws'; // Ganti dengan URL backend Anda
  WebSocketChannel? channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final TextEditingController _messageInputController = TextEditingController();
  final List<String> messages = []; // Daftar untuk menyimpan pesan
  bool isConnected = false;

  // Fungsi untuk melakukan koneksi ke WebSocket dengan token JWT
  void connect(String jwtToken) {
    channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    // Tambahkan listener untuk menerima pesan dari server
    channel!.stream.listen((message) {
      // Dekode JSON yang diterima dari server
      final decodedMessage = jsonDecode(message);
      final displayMessage =
          "Sender: ${decodedMessage['sender']['id']} - ${decodedMessage['messageContent']}";

      // Kirim pesan ke StreamController
      _messageController.add(displayMessage);
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('Connection closed');
      _messageController.close();
    });
  }

  // Fungsi untuk mengirim pesan ke server
  void sendMessage(String messageContent, String senderId, int chatRoomId) {
    if (channel != null) {
      // Buat objek pesan
      Map<String, dynamic> message = {
        'sendingTime': DateTime.now().toIso8601String(),
        'messageContent': messageContent,
        'chatRoom': {'id': chatRoomId},
        'sender': {'id': senderId},
      };

      // Konversi pesan ke format JSON string dan kirim
      channel!.sink.add(jsonEncode(message));
    }
  }

  Future<void> _connectWebSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accesToken');

    if (token != null) {
      connect(token);

      setState(() {
        isConnected = true;
      });

      _messageController.stream.listen((message) {
        setState(() {
          messages.add(message);
        });
      });
    } else {
      print("Token tidak ditemukan.");
    }
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    channel?.sink.close();
    _messageController.close(); // Menutup StreamController
    super.dispose();
  }

  Future<String?> saveMessage(
      String messageContent, String senderId, String chatRoomId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/messages');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message_content': messageContent,
          'room_id': {'id': chatRoomId},
          'sender_id': {'id': senderId},
        }));
    print(senderId);
    print(chatRoomId);
    print(messageContent);
    if (response.statusCode == 200) {}
    return null;
  }

  // void _sendMessage() {
  //   String message = _messageInputController.text;
  //   if (message.isNotEmpty) {
  //     String senderId =
  //         widget.user.id.toString(); // Menggunakan ID pengguna yang dipilih
  //     String chatRoomId = widget.roomId; // Ganti dengan ID ruang chat yang valid

  //     sendMessage(message, senderId, chatRoomId);
  //     _messageInputController.clear();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Chat dengan ${widget.user.username}'), // Menampilkan email pengguna yang dipilih
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            TextField(
              controller: _messageInputController,
              decoration: InputDecoration(
                labelText: 'Enter message',
              ),
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                String messageContent = _messageInputController.text;
                if (messageContent.isNotEmpty) {
                  String senderId = widget.user.id.toString();
                  String chatRoomId = widget.roomId;

                  saveMessage(messageContent, senderId, chatRoomId);

                  _messageInputController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
