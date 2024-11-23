import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gcom_app/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chatscreen extends StatefulWidget {
  final User user; // Menerima pengguna yang dipilih
  final String roomId; // Menerima id chat yang dipilih
  final String senderId; // Menerima senderId

  Chatscreen(
      {Key? key,
      required this.user,
      required this.roomId,
      required this.senderId})
      : super(key: key);

  @override
  _WebSocketChatAppState createState() => _WebSocketChatAppState();
}

class _WebSocketChatAppState extends State<Chatscreen> {
  String userId = '';
  late StompClient stompClient;
  final String url = 'ws://10.0.2.2:8080/ws'; // Ganti dengan URL backend Anda
  WebSocketChannel? channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final TextEditingController _messageInputController = TextEditingController();
  final List<String> messages = []; // Daftar untuk menyimpan pesan
  bool isConnected = false;
  final ScrollController _scrollController = ScrollController();

  void connect(String jwtToken) {
    print('Attempting to connect to WebSocket...');
    channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (channel != null) {
      print('WebSocket connected successfully.');

      // Mendengarkan pesan dari server
      channel!.stream.listen((message) {
        print('Message received: $message'); // Logging pesan yang diterima
        try {
          Map<String, dynamic> receivedMessage = jsonDecode(message);

          // Mengalirkan pesan ke _messageController
          _messageController.add(
              "${receivedMessage['messageContent']} - ${DateFormat('HH:mm').format(DateTime.now())} - ${receivedMessage['senderId']}");

          print(
              'Updated messages list: $messages'); // Logging daftar pesan setelah diperbarui
        } catch (e) {
          print('Error parsing message: $e'); // Menangani kesalahan parsing
        }
      }, onDone: () {
        print('WebSocket closed');
      }, onError: (error) {
        print('WebSocket error: $error');
      });
    } else {
      print('Failed to connect to WebSocket.');
    }
  }

  void connectStomp(String jwtToken) {
    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          print('Connected to WebSocket');

          // Mendaftar ke topik
          stompClient.subscribe(
            destination:
                '/topic/chatroom/${widget.roomId}', // Ganti dengan topik yang sesuai
            callback: (StompFrame frame) {
              // Pesan diterima dari topik
              print('Message received: ${frame.body}');
              _messageController
                  .add(frame.body!); // Mengalirkan pesan ke StreamController
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        onDisconnect: (StompFrame frame) =>
            print('Disconnected from WebSocket'),
      ),
    );

    // Menghubungkan ke WebSocket
    stompClient.activate();
  }

  void sendMessage(String messageContent, String senderId, String receiverId,
      int chatRoomId) {
    if (channel != null && channel!.closeCode == null) {
      // Memastikan channel aktif
      Map<String, dynamic> message = {
        'sendingTime': DateTime.now().toIso8601String(),
        'chatRoomId': chatRoomId,
        'messageContent': messageContent,
        'senderId': senderId,
        'receiverId': receiverId,
      };

      // Send the message through WebSocket
      channel!.sink.add(jsonEncode(message));
      saveMessage(messageContent, senderId, chatRoomId.toString());

      setState(() {
        messages.add(
            "$messageContent - ${DateFormat('HH:mm').format(DateTime.now())} - $senderId");
      });
    } else {
      print("WebSocket channel is null or closed.");
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
    } else {
      print("Token tidak ditemukan.");
    }
  }

  Future<List<String>> fetchMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    final url = Uri.parse(
        'http://10.0.2.2:8080/api/messages/chatroom/${widget.roomId}');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final List<dynamic> messageList = jsonDecode(response.body);

      return messageList.map((message) {
        String senderId = message['senderId'];
        String content = message['content'];
        String timestampString = message['timestamp'];

        DateTime timestamp = DateTime.parse(timestampString);
        String formattedTime = DateFormat('HH:mm').format(timestamp);

        return "$content - $formattedTime - $senderId"; // Format pesan
      }).toList();
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserIdFromToken().then((_) {
      fetchMessages().then((fetchedMessages) {
        setState(() {
          messages.addAll(fetchedMessages);
        });
        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }).catchError((error) {
        print("Error fetching messages: $error");
      });
    });
    _connectWebSocket();
  }

  @override
  void dispose() {
    channel?.sink.close();
    _messageController.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getUserIdFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    if (accessToken != null) {
      Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
      setState(() {
        userId = payload['sub'].split(',')[0]; // Ambil ID pengguna dari token
      });
    } else {
      print("Access token tidak ditemukan.");
    }
  }

  Future<void> saveMessage(
      String messageContent, String senderId, String chatRoomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    if (accessToken != null) {
      Map<String, dynamic> payload = JwtDecoder.decode(accessToken);
      String userId = payload['sub'].split(',')[0]; // Ensure this is correct

      final url = Uri.parse('http://10.0.2.2:8080/api/messages/message');
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'messageContent': messageContent,
            'senderId': userId, // Ensure this is correct
            'chatRoomId': chatRoomId,
          }));

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
      _scrollToBottom();
    } else {
      print("Access token tidak ditemukan.");
    }
  }

  void _scrollToBottom() {
    // Scroll to the bottom
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.username}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<String>(
                stream: _messageController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messageParts = snapshot.data!.split(' - ');
                    final messageContent = messageParts.length > 1
                        ? messageParts[0]
                        : snapshot.data!;
                    final timestamp =
                        messageParts.length > 1 ? messageParts[1] : '';
                    final senderId =
                        messageParts.length > 2 ? messageParts[2] : '';

                    return Align(
                      alignment: senderId == userId
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: MessageBubble(
                        message: "$messageContent  $timestamp",
                        isSender: senderId == userId,
                      ),
                    );
                  } else if (messages.isEmpty) {
                    return Center(child: Text('No messages yet.'));
                  } else {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageParts = messages[index].split(' - ');
                        final messageContent = messageParts.length > 1
                            ? messageParts[0]
                            : messages[index];
                        final timestamp =
                            messageParts.length > 1 ? messageParts[1] : '';
                        final senderId =
                            messageParts.length > 2 ? messageParts[2] : '';

                        return Align(
                          alignment: senderId == userId
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: MessageBubble(
                            message: "$messageContent  $timestamp",
                            isSender: senderId == userId,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            TextField(
              controller: _messageInputController,
              decoration: const InputDecoration(
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

                  sendMessage(messageContent, widget.senderId,
                      widget.user.id.toString(), int.parse(chatRoomId));
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

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSender; // Menambahkan parameter untuk menentukan pengirim

  const MessageBubble({Key? key, required this.message, required this.isSender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width * 0.75, // Batasan lebar maksimum
      ),
      decoration: BoxDecoration(
        color: isSender
            ? Colors.blueAccent
            : Colors.grey, // Warna berdasarkan pengirim
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
        softWrap: true,
      ),
    );
  }
}
