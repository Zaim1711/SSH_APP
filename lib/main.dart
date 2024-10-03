import 'package:flutter/material.dart';
import 'package:gcom_app/package/DasboardPage.dart';
import 'package:gcom_app/package/LoadPage.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: "Stop Sexual Harasment",
      home: LoadPage(),
      initialRoute: '/', // Rute awal
      routes: {
        '/dashboard': (context) =>
            DasboardPage(), // Rute untuk halaman dashboard
      },
    );
  }
}
