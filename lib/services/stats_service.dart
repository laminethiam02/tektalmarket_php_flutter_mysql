import 'api_service.dart';

class StatsService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _api.get('dashboard.php');
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDetailedStats({String period = 'month'}) async {
    try {
      final response = await _api.get('stats/get_stats.php', params: {'period': period});
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }
}