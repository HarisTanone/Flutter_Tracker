import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constant.dart';
import '../models/user_model.dart';

class AuthService {
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}login'),
        headers: {'Content-Type': 'application/json'}, // Tambahkan ini
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Response: ${response.body}'); // Debugging
      print('Status Code : ${response.statusCode}'); // Debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        final userData = data['data'];

        if (token != null && userData != null) {
          // Simpan token
          await _saveToken(token);

          // Simpan user data setelah parsing ke model User
          final user = User.fromJson(userData);
          await _saveUserData(user);

          return true;
        }
      } else {
        print('Login failed: ${response.body}'); // Debugging
      }

      return false;
    } catch (e) {
      print('Login error: ${e.toString()}');
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, json.encode(user.toJson()));
  }

  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();

    if (token != null) {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Logout Response: ${response.body}'); // Debugging
    }

    await prefs.remove(userKey);
    await prefs.remove(tokenKey);
  }
}
