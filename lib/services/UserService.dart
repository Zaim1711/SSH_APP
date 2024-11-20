import 'dart:convert';

import 'package:gcom_app/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl =
      'http://10.0.2.2:8080/users'; // Update with your API URL

  Future<User> fetchUser(String receiverId) async {
    // Retrieve the access token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(
        'accesToken'); // Ensure the key matches what you used to store the token

    // Make the GET request to fetch the user
    final response = await http.get(
      Uri.parse('$baseUrl/$receiverId'),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Include the token in the headers
      },
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Decode the JSON response and return a User object
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load user'); // Handle error if the request fails
    }
  }
}