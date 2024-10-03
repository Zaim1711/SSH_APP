import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcom_app/component/bottom_navigator.dart';
import 'package:gcom_app/package/ProfilePage.dart';
import 'package:gcom_app/package/TestMultiPage.dart';
import 'package:gcom_app/package/ViewAllEvent.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DasboardPage extends StatefulWidget {
  @override
  _DasboardPageState createState() => _DasboardPageState();
}

class _DasboardPageState extends State<DasboardPage> {
  int _currentIndex = 2; // Indeks halaman yang dipilih
  List<dynamic> ongoingEvents = [];
  Map<String, dynamic> payload = {};
  String userName = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    decodeToken();
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

  Future<void> decodeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accesToken');

    if (accessToken != null) {
      payload = JwtDecoder.decode(accessToken);
      String name = payload['sub'].split(',')[2];
      String id = payload['sub'].split(',')[0];
      // Mengambil nilai 'name' dari token JWT
      setState(() {
        userName = name;
        userId = id;
      });

      // Panggil _loadDataLaporan dengan userId dan accessToken
      _loadDataLaporan(id, accessToken);
    }
  }

  // Fungsi untuk mengambil data produk dari API
  _loadDataLaporan(String userId, String accessToken) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/pengaduan/user/$userId'),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Menambahkan Authorization header
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        ongoingEvents = json.decode(response.body);
      });
    } else {
      print('Gagal mengambil data laporan : ${response.statusCode}');
    }
  }

  String _getFormattedName(String name) {
    // Memecah nama berdasarkan spasi
    List<String> nameParts = name.split(' ');

    // Mengambil dua nama pertama jika ada lebih dari dua
    if (nameParts.length > 2) {
      return '${nameParts[0]} ${nameParts[1]}'; // Mengembalikan dua nama pertama
    } else {
      return name; // Mengembalikan nama aslinya jika kurang dari atau sama dengan dua
    }
  }

  String formatIsoDateToNormal(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('dd MMMM yyyy, hh:mm a', 'id_ID');
    return formatter.format(dateTime);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DasboardPage()), // Make sure this is the correct navigation logic
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
                  MultiPageForm()), // Make sure this is the correct navigation logic
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
                      height: 80,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 250, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $userName', // Menggunakan variabel userName
                      style: const TextStyle(
                        color: Color(0xFF0E197E),
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Color(0xFF0E197E),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Input pencarian
              // SearchInput(onSearchChanged: _performSearch),
              const SizedBox(
                height: 20,
              ),

              // Kontainer "Welcome!" dengan gambar dan teks
              Container(
                width: 350,
                height: 112,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 350,
                        height: 112,
                        decoration: ShapeDecoration(
                          color: const Color(0x00D9D9D9),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 2, color: Color(0xFF0E197E)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 32,
                      top: 24,
                      child: Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Color(0xFF0E197E),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 32,
                      top: 49,
                      child: Text(
                        'We Care About\nYou',
                        style: TextStyle(
                          color: Color(0x990E197E),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 156,
                      top: 3,
                      child: Container(
                        width: 164,
                        height: 107,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('lib/image/greething_dasboard.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Teks "Ongoing Event"
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                          left: 15,
                        ),
                        child: const Text(
                          'History Pengaduan',
                          style: TextStyle(
                            color: Color(0xFF0E197E),
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewAllEvent(), // Gantilah ViewAllEvent dengan nama halaman yang sesuai
                            ),
                          );
                          // Aksi yang dijalankan saat tombol ditekan
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Warna latar belakang tombol saat normal
                          elevation: 0, // Hilangkan efek bayangan bawaan
                          shadowColor:
                              Colors.grey.withOpacity(0.5), // Warna bayangan
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'view all',
                            style: TextStyle(
                              color: Color.fromARGB(255, 120, 128, 201),
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Daftar History Laporan
                ],
              ),
              const SizedBox(
                height: 15,
              ),

              Column(
                children: ongoingEvents.map((laporan) {
                  print('Event Image Name: ${laporan['bukti_kekerasan']}');
                  // DateTime eventDateTime =
                  //     DateTime.parse(event['eventDateTime']);
                  // if (eventDateTime.isBefore(DateTime.now())) {
                  //   return Container(); // Tidak menampilkan acara yang telah berlalu
                  // }
                  return GestureDetector(
                    onTap: () {
                      // // Navigasi ke halaman detail event dengan membawa data event
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => EventDetailPage(
                      //       event: event,
                      //       imagePath: event['eventImage'],
                      //     ),
                      //   ),
                      // );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      width: 342,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x3F000000),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3))
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 93,
                            top: 50,
                            child: Text(
                              formatIsoDateToNormal(
                                  '${laporan['tanggal_kekerasan']}'),
                              style: TextStyle(
                                color: Colors.black
                                    .withOpacity(0.4699999988079071),
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
                                _getFormattedName(laporan['name']) +
                                    '\n' +
                                    laporan['status_pelapor'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
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
                                future: laporan['bukti_kekerasan'] != null
                                    ? getImageFromLocalStorage(
                                        laporan['bukti_kekerasan'])
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
                              '${laporan['status']}',
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
                }).toList(),
              )
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
