import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcom_app/component/Search.dart';
import 'package:gcom_app/component/bottom_navigator.dart';
import 'package:gcom_app/package/DasboardPage.dart';
import 'package:gcom_app/package/EventDetailPage.dart';
import 'package:gcom_app/package/ProfilePage.dart';
import 'package:gcom_app/package/TestMultiPage.dart';
import 'package:gcom_app/package/community_search.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ViewAllEvent extends StatefulWidget {
  @override
  _ViewAllEvent createState() => _ViewAllEvent();
}

class _ViewAllEvent extends State<ViewAllEvent> {
  int _currentIndex = 2; // Indeks halaman yang dipilih
  List<dynamic> ongoingEvents = [];
  Map<String, dynamic> payload = {};
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadOngoingEvents();
  }

  void _performSearch(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _loadOngoingEvents();
      } else {
        ongoingEvents = ongoingEvents.where((event) {
          String eventName = event['eventName'].toLowerCase();
          String eventDescription = event['eventAddress'].toLowerCase();
          return eventName.contains(searchText.toLowerCase()) ||
              eventDescription.contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MultiPageForm()), // Pastikan ini adalah logika navigasi yang benar
        );
      }

      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()), // Pastikan ini adalah logika navigasi yang benar
        );
      }
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Community_Search()), // Pastikan ini adalah logika navigasi yang benar
        );
      }
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DasboardPage()), // Pastikan ini adalah logika navigasi yang benar
        );
      }
    });
  }

  String formatIsoDateToNormal(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('dd MMMM yyyy, hh:mm a', 'id_ID');
    return formatter.format(dateTime);
  }

  Future<File?> getImageFromLocalStorage(String eventImage) async {
    String imagePath = eventImage;
    print('Image Path: $imagePath');
    File imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      return imageFile;
    } else {
      return null;
    }
  }

  // Fungsi untuk mengambil data acara dari API
  _loadOngoingEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/api/events'));
    if (response.statusCode == 200) {
      setState(() {
        ongoingEvents = json.decode(response.body);
      });
    } else {
      print('Gagal mengambil data acara: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              width: 450,
              height: 180,
              decoration: ShapeDecoration(
                color: const Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Image(
                            image: AssetImage('lib/image/Logo.png'),
                            width: 100,
                            height: 80,
                          ),
                          SearchInput(onSearchChanged: _performSearch),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ongoingEvents.length,
                itemBuilder: (context, index) {
                  final event = ongoingEvents[index];
                  print('Event Image Name: ${event['eventImage']}');
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke EventDetailPage dan kirimkan data event dan imagePath
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(
                            event: event,
                            imagePath: event['eventImage'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15),
                      width: 342,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 93,
                            top: 42,
                            child: Text(
                              formatIsoDateToNormal(
                                  '${event['eventDateTime']}'),
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.47),
                                fontSize: 10,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 93,
                            top: 11,
                            child: SizedBox(
                              width: 249,
                              child: Text(
                                '${event['eventName']}\n${event['eventAddress']}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 7,
                            top: 6,
                            child: Container(
                              width: 71,
                              height: 71,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder<File?>(
                                future: event['eventImage'] != null
                                    ? getImageFromLocalStorage(
                                        event['eventImage'])
                                    : null,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Image.file(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Container(); // Empty container if image is not found
                                  }
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            left: 278,
                            top: 63,
                            child: Text(
                              '${event['eventStatus']}',
                              style: const TextStyle(
                                color: Color(0xFF0E197E),
                                fontSize: 10,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
