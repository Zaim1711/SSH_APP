import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue, // Warna utama aplikasi
        hintColor: Colors.blueAccent, // Warna aksen aplikasi
      ),
      home: InformationPage(),
    );
  }
}

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  List<InformationItem> informationList = [
    InformationItem(
      question: 'Apa itu Hak dan Hukum?',
      answer:
          'Hak dan hukum adalah seperangkat aturan dan norma-norma yang mengatur perilaku manusia dalam suatu masyarakat.',
    ),
    InformationItem(
      question: 'Apa itu Hukum Perdata?',
      answer:
          'Hukum perdata adalah bagian dari hukum yang mengatur hubungan antara individu atau badan hukum yang bersifat pribadi.',
    ),
    InformationItem(
      question: 'Apa itu Hukum pidana?',
      answer:
          'Hukum pidana adalah bagian dari hukum yang mengatur pelanggaran hukum dan menetapkan sanksi atau hukuman terhadap pelaku kejahatan.',
    ),
    // Tambahkan item informasi sesuai kebutuhan Anda
  ];

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi Hak dan Hukum'),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.all(0),
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _expandedIndex = isExpanded ? -1 : index;
            });
          },
          children: informationList.map<ExpansionPanel>((InformationItem item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    item.question,
                    style: TextStyle(
                      color: Colors.black, // Warna teks pertanyaan
                    ),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  item.answer,
                  style: TextStyle(
                    color: Colors.black, // Warna teks jawaban
                  ),
                ),
              ),
              isExpanded: informationList.indexOf(item) == _expandedIndex,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class InformationItem {
  final String question;
  final String answer;

  InformationItem({required this.question, required this.answer});
}
