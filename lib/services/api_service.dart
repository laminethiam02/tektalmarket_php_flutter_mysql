import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  static Future<void> saveToken(String t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, t);
  }

  static Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_tokenKey);
  }

  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> authHeaders() async {
    final t = await getToken();
    final h = {'Accept': 'application/json', 'Content-Type': 'application/json'};
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  static Future<Map<String, String>> authMultipartHeaders() async {
    final t = await getToken();
    final h = <String, String>{'Accept': 'application/json'};
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  static Future<dynamic> handleResponse(http.Response r) async {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return null;
      return jsonDecode(utf8.decode(r.bodyBytes));
    }
    String msg = 'Erreur ${r.statusCode}';
    try {
      final d = jsonDecode(utf8.decode(r.bodyBytes));
      if (d is Map && d['error'] != null) msg = d['error'];
    } catch (_) {}
    throw ApiException(r.statusCode, msg);
  }
}