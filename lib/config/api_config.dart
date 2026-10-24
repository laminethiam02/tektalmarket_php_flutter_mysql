class ApiConfig {
  // Android Emulator : http://10.0.2.2/api-marche
  // iOS/Web/Desktop : http://localhost/api-marche
  static const String baseUrl = 'http://localhost/api-marche';

  static const String authEndpoint       = '$baseUrl/api/auth';
  static const String usersEndpoint      = '$baseUrl/api/users';
  static const String categoriesEndpoint = '$baseUrl/api/categories';
  static const String productsEndpoint   = '$baseUrl/api/products';

  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}