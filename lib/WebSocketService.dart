// lib/services/web_socket_service.dart
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url = 'ws://10.0.2.2:8080/ws'; // Ganti dengan URL backend Anda
  WebSocketChannel? channel;

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
      print('Received: $message');
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('Connection closed');
    });
  }

  // Fungsi untuk mengirim pesan ke server
  void sendMessage(String message) {
    if (channel != null) {
      channel!.sink.add(message);
    }
  }

  // Fungsi untuk memutuskan koneksi WebSocket
  void disconnect() {
    channel?.sink.close();
  }
}
