import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await ApiConfig.getHeaders();
    final response = await http.post(
      Uri.parse(ApiConfig.getFullUrl(endpoint)),
      headers: headers,
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? params}) async {
    final headers = await ApiConfig.getHeaders();
    Uri uri = Uri.parse(ApiConfig.getFullUrl(endpoint));

    if (params != null) {
      uri = uri.replace(queryParameters: params);
    }

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await ApiConfig.getHeaders();
    final response = await http.put(
      Uri.parse(ApiConfig.getFullUrl(endpoint)),
      headers: headers,
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint, Map<String, dynamic> data) async {
    final headers = await ApiConfig.getHeaders();
    final response = await http.delete(
      Uri.parse(ApiConfig.getFullUrl(endpoint)),
      headers: headers,
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur inconnue');
    }
  }
}