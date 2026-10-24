import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  Future<List<Category>> getAll() async {
    final res = await http.get(
      Uri.parse(ApiConfig.categoriesEndpoint),
      headers: ApiService.jsonHeaders,
    );
    final data = await ApiService.handleResponse(res) as List;
    return data.map((e) => Category.fromJson(e)).toList();
  }
}