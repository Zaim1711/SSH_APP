import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  late WebSocketChannel _channel;

  void connect(String token) {
    _channel = IOWebSocketChannel.connect('http://10.0.2.2:8080/chat');
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  Stream<dynamic> get stream => _channel.stream;

  void close() {
    _channel.sink.close();
  }
}
