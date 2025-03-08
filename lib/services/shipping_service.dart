import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/shipping_model.dart';
import '../services/auth_service.dart';

class ShippingService {
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await AuthService().getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Get shipping documents by customer ID
  Future<ShippingDocumentsByCustomerResponse> getShippingDocumentsByCustomer(
      String custID) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}getsjbycustID'),
        headers: headers,
        body: jsonEncode({
          'custID': custID,
        }),
      );

      if (response.statusCode == 200) {
        return ShippingDocumentsByCustomerResponse.fromJson(
            jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load shipping documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting shipping documents: $e');
    }
  }

  // Get shipping document details by legal number
  Future<ShippingDocumentDetailsResponse> getShippingDocumentDetails(
      String legalNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}getSJ'),
        headers: headers,
        body: jsonEncode({
          'legalNumber': legalNumber,
        }),
      );

      if (response.statusCode == 200) {
        return ShippingDocumentDetailsResponse.fromJson(
            jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load shipping document details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting shipping document details: $e');
    }
  }
}
