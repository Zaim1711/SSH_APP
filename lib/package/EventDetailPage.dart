import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcom_app/component/bottom_navigator.dart';
import 'package:gcom_app/package/DasboardPage.dart';
import 'package:gcom_app/package/EventFormPage.dart';
import 'package:gcom_app/package/ProfilePage.dart';
import 'package:gcom_app/package/community_search.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final String imagePath; // Parameter untuk path gambar

  EventDetailPage({required this.event, required this.imagePath});

  // Tambahkan constructor default tanpa parameter dengan nilai default
  EventDetailPage.empty()
      : event = const {},
        imagePath = '';

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _currentIndex = 2; // Indeks halaman yang dipilih

  String formatIsoDateToNormal(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('dd MMMM yyyy, hh:mm a', 'id_ID');
    return formatter.format(dateTime);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EventFormPage()), // Make sure this is the correct navigation logic
        );
      }
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DasboardPage(),
          ),
        );
      }

      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()), // Make sure this is the correct navigation logic
        );
      }
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Community_Search()), // Make sure this is the correct navigation logic
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Bagian atas tampilan
              Container(
                padding: const EdgeInsets.all(5.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image(
                      image: AssetImage('lib/image/Logo.png'),
                      width: 100,
                      height: 40,
                    ),
                  ],
                ),
              ),

              Container(
                width: 900,
                height: 700,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 10,
                      child: Container(
                        width: 420,
                        height: 251,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF0E197E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(4, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(-4, -4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ),

                    // Informasi event
                    Stack(
                      children: <Widget>[
                        Positioned(
                          left: 0,
                          top: 10,
                          child: Image.file(
                            File(widget.imagePath),
                            width: 400,
                            height: 250,
                          ),
                        ),
                        Container(
                          width: 700,
                          height: 700,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 55,
                                top: 200,
                                child: Container(
                                  width: 300,
                                  height: 100,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4F4F4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(4, 4),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(-4, -4),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20, // Sesuaikan posisi horizontal
                                top: 200, // Sesuaikan posisi vertikal
                                child: Text(
                                  '${widget.event['eventName']}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Positioned(
                                left: 135, // Sesuaikan posisi horizontal
                                top: 225, // Sesuaikan posisi vertikal
                                child: Text(
                                  '${widget.event['eventAddress']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Positioned(
                                left: 100, // Sesuaikan posisi horizontal
                                top: 245, // Sesuaikan posisi vertikal
                                child: Text(
                                  '${formatIsoDateToNormal(widget.event['eventDateTime'])}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Positioned(
                                left: 170, // Sesuaikan posisi horizontal
                                top: 265, // Sesuaikan posisi vertikal
                                child: Text(
                                  '${widget.event['eventStatus']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),

                          // Tambahkan widget lain sesuai dengan data event yang Anda miliki
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
