import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/usage_car_model.dart';
import 'auth_service.dart';

class UsageCarService {
  Future<bool> sendUsageCar(UsageCar usageCar, File imageFile) async {
    try {
      final String? token = await AuthService().getToken();
      if (token == null) {
        print("Token tidak ditemukan");
        return false;
      }

      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> payload = usageCar.toJson();
      print('payload jnck =<> $payload');
      payload['foto_km'] = base64Image;

      print('payload => ${jsonEncode(payload)}'); // debug

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}usage-car"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Berhasil mengirim data: ${response.body}");
        return true;
      } else {
        print("Gagal mengirim data: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sendUsageCar: $e");
      return false;
    }
  }

  Future<UsageCar?> fetchUsageCar(String username) async {
    final String? token = await AuthService().getToken();
    if (token == null) {
      print("Token tidak ditemukan");
      return null;
    }

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}usage-car/one"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"username": username}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data["usegeCar"] != null) {
        return UsageCar.fromJson(data["usegeCar"]);
      }
    }
    return null;
  }
}
