// api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/fail_code_model.dart';
import '../models/item_deliver_model.dart';
import '../models/update_status_model.dart';
import 'auth_service.dart';

class DeliveredService {
  Future<List<FailCode>> getFailCodes() async {
    try {
      final String? token = await AuthService().getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}failcode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().startsWith('[') ||
            response.body.trim().startsWith('{')) {
          List jsonResponse = json.decode(response.body);
          return jsonResponse.map((data) => FailCode.fromJson(data)).toList();
        } else {
          throw Exception('Response is not valid JSON: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to load fail codes. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFailCodes: $e');
      rethrow;
    }
  }

  Future<ItemDeliver> postItemDeliver({
    required String username,
    required String keterangan,
    String? codeGagal,
    required String foto,
    required String lat,
    required String lng,
    required String custID,
  }) async {
    try {
      final String? token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}item-deliver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({
          'username': username,
          'keterangan': keterangan,
          'code_gagal': codeGagal,
          'foto': foto,
          'lat': lat,
          'lng': lng,
          'custID': custID,
        }),
      );

      print(
          'Item Deliver Response: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        return ItemDeliver.fromJson(json.decode(response.body));
      } else {
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            if (errorData.containsKey('error') &&
                errorData.containsKey('message')) {
              throw Exception(
                  'Failed to post item deliver: ${errorData['message']}');
            } else {
              throw Exception('Failed to post item deliver: Unknown error');
            }
          } catch (e) {
            throw Exception(
                'Failed to post item deliver: ${response.statusCode}');
          }
        } else {
          throw Exception(
              'Failed to post item deliver: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in postItemDeliver: $e');
      rethrow;
    }
  }

  Future<UpdateStatusResponse> updateStatus({
    required String status,
    required String customerId,
  }) async {
    try {
      final String? token = await AuthService().getToken();

      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}update-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
          'customer_id': customerId,
        }),
      );

      print(
          'Update Status Response: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        // Try to decode the response safely
        final jsonData = json.decode(response.body);
        return UpdateStatusResponse.fromJson(jsonData);
      } else {
        // More descriptive error based on response
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            throw Exception(
                'Failed to update status: ${errorData['error'] ?? 'Unknown error'}');
          } catch (e) {
            throw Exception('Failed to update status: ${response.statusCode}');
          }
        } else {
          throw Exception('Failed to update status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in updateStatus: $e');
      rethrow;
    }
  }
}
