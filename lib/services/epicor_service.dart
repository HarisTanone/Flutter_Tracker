import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/epicor_model.dart';
import '../services/auth_service.dart';

class EpicorService {
  Future<EpicorData?> fetchEpicorData(
      String username, String lat, String lng) async {
    final Uri url = Uri.parse("${ApiConstants.baseUrl}getDataEpicor");
    final String? token = await AuthService().getToken();

    if (token == null) return null;

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "username": username,
        "lat": lat,
        "lng": lng,
      }),
    );
    // print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return EpicorData.fromJson(data);
    } else {
      return null;
    }
  }
}
