import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final WebSocketChannel channel;

  ChatService(String url) : channel = WebSocketChannel.connect(Uri.parse(url));

  void sendMessage(String message) {
    channel.sink.add(
        json.encode({'content': message})); // Mengirim pesan dalam format JSON
  }

  Stream<dynamic> get messages => channel.stream
      .map((event) => json.decode(event)); // Mendapatkan aliran pesan

  void dispose() {
    channel.sink.close(); // Menutup koneksi saat tidak digunakan
  }
}
