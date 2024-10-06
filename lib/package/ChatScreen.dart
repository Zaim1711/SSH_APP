import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chatscreen extends StatefulWidget {
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
      // Kirim pesan ke StreamController
      _messageController.add(message);
    }, onError: (error) {
      // Tangani kesalahan
      print('Error: $error');
    }, onDone: () {
      // Tangani saat koneksi ditutup
      print('Connection closed');
      _messageController.close(); // Tutup StreamController saat koneksi ditutup
    });
  }

  // Fungsi untuk mengirim pesan ke server
  void sendMessage(String messageContent, String senderId, int chatRoomId) {
    if (channel != null) {
      // Buat objek pesan
      Map<String, dynamic> message = {
        'messageContent': messageContent,
        'sender': {'id': senderId}, // Sesuaikan dengan struktur objek User Anda
        'chatRoom': {
          'id': chatRoomId
        }, // Sesuaikan dengan struktur objek ChatRoom Anda
        'sendingTime':
            DateTime.now().toIso8601String(), // Gunakan waktu saat ini
      };

      // Kirim pesan ke channel WebSocket
      channel!.sink.add(message.toString()); // Ubah ke format string
    }
  }

  Future<void> _connectWebSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('accesToken'); // Ambil token dari Shared Preferences

    connect(token!); // Koneksi WebSocket dengan token

    // Mengupdate status koneksi
    setState(() {
      isConnected = true;
    });

    // Mendengarkan pesan yang diterima dari server
    _messageController.stream.listen((message) {
      setState(() {
        messages.add(message); // Menambahkan pesan ke daftar
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    channel?.sink.close(); // Putuskan koneksi saat widget dihapus
    super.dispose();
  }

  void _sendMessage() {
    String message = _messageInputController.text;
    if (message.isNotEmpty) {
      String senderId = '1'; // Ganti dengan ID pengirim yang valid
      int chatRoomId = 1; // Ganti dengan ID ruang chat yang valid

      sendMessage(message, senderId, chatRoomId);
      _messageInputController.clear(); // Kosongkan field input
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat'),
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
            SizedBox(height: 10),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
