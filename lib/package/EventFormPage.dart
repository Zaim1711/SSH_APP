import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcom_app/component/Submit_form_button.dart';
import 'package:gcom_app/package/DasboardPage.dart';
import 'package:gcom_app/package/ProfilePage.dart';
import 'package:gcom_app/package/community_search.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Impor image_picker
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/bottom_navigator.dart';

class EventFormPage extends StatefulWidget {
  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentIndex = 3;

  String _eventName = '';
  String _eventAddress = '';
  String _eventDescription = "";
  DateTime _eventDateTime = DateTime.now();
  String _eventStatus = 'Gathering';

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  File? savedImage;

  Future<String> saveImageToDirectory(File imageFile) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imagePath =
        '${directory.path}/image_form/${DateTime.now().millisecondsSinceEpoch}.png';

    // Buat direktori jika belum ada
    await Directory('${directory.path}/image_form/').create(recursive: true);

    File savedImage = await imageFile.copy(imagePath);
    return savedImage.path;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String formattedDateTime = _eventDateTime.toIso8601String();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString('accesToken') ?? '';

      // Save the image to local storage
      if (_selectedImage != null) {
        String imagePath = await saveImageToDirectory(_selectedImage!);

        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/events'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(<String, dynamic>{
            'eventName': _eventName,
            'eventAddress': _eventAddress,
            'eventDescription': _eventDescription,
            'eventDateTime': formattedDateTime,
            'eventStatus': _eventStatus,
            'eventImage': imagePath,
          }),
        );

        if (response.statusCode == 200) {
          print('Event saved successfully');
        } else {
          print('Error saving event: ${response.body}');
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
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
            builder: (context) => ProfilePage(),
          ),
        );
      }
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Community_Search(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                width: 450,
                height: 150,
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
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image(
                              image: AssetImage('lib/image/Logo.png'),
                              width: 100,
                              height: 80,
                            ),
                            SizedBox(height: 16),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Form Event",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D187E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _selectedImage == null
                              ? Icon(Icons.add_a_photo)
                              : Image.file(_selectedImage!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nama Event',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.all(10.0),
                            enabledBorder: const OutlineInputBorder(),
                            fillColor: const Color(0xFFF4F4F4),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Nama Event harus diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _eventName = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Alamat Event',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.all(10.0),
                            enabledBorder: const OutlineInputBorder(),
                            fillColor: const Color(0xFFF4F4F4),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Alamat Event harus diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _eventAddress = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          maxLines: 5,
                          minLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description Event',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: const EdgeInsets.all(10.0),
                            enabledBorder: const OutlineInputBorder(),
                            fillColor: const Color(0xFFF4F4F4),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Description Event harus diisi';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _eventDescription = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        child: Row(
                          children: [
                            const Text('Tanggal Event:'),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () async {
                                final selectedDateTime = await showDatePicker(
                                  context: context,
                                  initialDate: _eventDateTime,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (selectedDateTime != null) {
                                  final selectedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (selectedTime != null) {
                                    setState(() {
                                      _eventDateTime = DateTime(
                                        selectedDateTime.year,
                                        selectedDateTime.month,
                                        selectedDateTime.day,
                                        selectedTime.hour,
                                        selectedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              child: Text(
                                '${_eventDateTime.day}/${_eventDateTime.month}/${_eventDateTime.year} ${_eventDateTime.hour}:${_eventDateTime.minute}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              hintText: 'Status Event',
                              border: InputBorder.none,
                            ),
                            value: _eventStatus,
                            onChanged: (newValue) {
                              setState(() {
                                _eventStatus = newValue!;
                              });
                            },
                            items: ['Gathering', 'Pameran']
                                .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      MyButtonSubmit(onTap: _submitForm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
