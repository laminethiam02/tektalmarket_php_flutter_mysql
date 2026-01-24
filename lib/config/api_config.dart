import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost/gestion_vente');
  static int get timeout => int.parse(dotenv.get('API_TIMEOUT', fallback: '30000'));

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String getFullUrl(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    return '$baseUrl/$endpoint';
  }
}