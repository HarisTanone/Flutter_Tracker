import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/nopol_model.dart';
import 'auth_service.dart';

class NopolService {
  Future<NopolResponse?> getNopol(String username) async {
    try {
      final String? token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}getNopol"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"username": username}),
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey("value") &&
            responseData["value"] is List &&
            responseData["value"].isNotEmpty) {
          return NopolResponse.fromJson(responseData["value"][0]);
        } else {
          print("Empty value received from API");
          return null;
        }
      } else {
        print("Failed to fetch nopol: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error in getNopol: $e");
      return null;
    }
  }
}
