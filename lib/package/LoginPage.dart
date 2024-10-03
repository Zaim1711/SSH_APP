// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gcom_app/component/My_TextField.dart';
import 'package:gcom_app/component/my_button.dart';
import 'package:gcom_app/package/DasboardPage.dart';
import 'package:gcom_app/package/SignUpPage.dart';
import 'package:gcom_app/package/user.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  User user = User("", "");
  String url = "http://10.0.2.2:8080/auth/login";

  Future<void> save(BuildContext context) async {
    final uri = Uri.parse(url);

    final Map<String, dynamic> requestData = {
      'email': user.email,
      'password': user.password,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['accesToken'];

      if (accessToken != null && accessToken is String) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

        // Sekarang Anda bisa mengakses bagian-bagian dari token yang sudah didecode
        print('Token payload: $decodedToken');

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('accesToken', accessToken);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DasboardPage()),
        );
      } else {
        print('Invalid accessToken format');
      }
    } else {
      print('Gagal mengirim data: ${response.statusCode}');
    }
  }

  void googleUserIn() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('lib/image/Logo.png'),
                const SizedBox(height: 30.0),
                MyTextField(
                  controller: TextEditingController(text: user.email),
                  onChanged: (val) {
                    user.email = val;
                  },
                  hintText: 'Masukkan Email Anda',
                  obsecureText: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Alamat Email harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: TextEditingController(text: user.password),
                  onChanged: (val) {
                    user.password = val;
                  },
                  hintText: 'Masukkan Kata Sandi Anda',
                  obsecureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan masukkan kata sandi!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                MyButton(
                  onTap: () {
                    save(context);
                  },
                ),
                const SizedBox(height: 15),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _navigateToSignUp(context);
                        },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Color(0xFF0D187E),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

void _navigateToSignUp(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: SignUpPage(),
      ),
    ),
  );
}
