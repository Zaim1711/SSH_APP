import 'package:flutter/material.dart';
import 'package:gcom_app/component/My_TextField.dart';
import 'package:gcom_app/component/button_signup.dart';
import 'package:gcom_app/component/my_google_button.dart';
import 'package:gcom_app/package/LoginPage.dart';
import 'package:gcom_app/service.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //signup
  void regisUser(BuildContext context) async {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    final service = Service(); // Buat instance dari Service
    final response = await service.saveUser(username, email, password);

    if (response.statusCode == 201) {
      print('User successfully registered!');

      // Tampilkan dialog sukses
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User successfully registered!'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();

                  // Navigasi ke halaman Login setelah menutup dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(), // Ganti dengan halaman Login yang sesuai
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to register user: ${response.statusCode}');

      // Tampilkan dialog gagal
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to register user: ${response.statusCode}'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  //googleuserin
  void googleUserin() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('lib/image/Logo.png'),

                const SizedBox(height: 20),
                // Username TextField
                MyTextField(
                  controller: usernameController,
                  hintText: 'Enter Your Username',
                  obsecureText: false,
                ),
                const SizedBox(height: 15),
                // Email TextField
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter Your Email',
                  obsecureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Password TextField
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter Your Password',
                  obsecureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                MyButtonSignUp(
                  onTap: () => regisUser(
                      context), // Panggil fungsi regisUser dengan parameter context
                ),
                const SizedBox(height: 15),
                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or sign in with'),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Google button
                MyGoogleBtn(
                  onTap: googleUserin,
                ),
                const SizedBox(height: 15),
                // Sign In row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _navigateToSignIn(context);
                        // Add your sign-up logic here
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF0D187E),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

void _navigateToSignIn(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration:
          const Duration(milliseconds: 200), // Durasi animasi (0.5 detik)
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: LoginPage(),
      ),
    ),
  );
}
