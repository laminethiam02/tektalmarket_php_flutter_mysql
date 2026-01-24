import 'package:gestion_vente/models/produit_model.dart';
import 'api_service.dart';

class ProduitService {
  final ApiService _api = ApiService();

  Future<List<Produit>> getProduits({
    int page = 1,
    int limit = 20,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool lowStock = false,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        'low_stock': lowStock.toString(),
      };

      final response = await _api.get('produits/get.php', params: params);
      final data = response['data']['produits'] as List;

      return data.map((json) => Produit.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Produit>> searchProduits(String query) async {
    try {
      final response = await _api.get('produits/search.php', params: {'q': query});
      final data = response['data'] as List;

      return data.map((json) => Produit.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Produit> addProduit(String nom, double prix, int stock) async {
    try {
      final response = await _api.post('produits/add.php', {
        'nom': nom,
        'prix': prix,
        'stock': stock,
      });

      return Produit.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Produit> updateProduit(int id, String nom, double prix, int stock) async {
    try {
      final response = await _api.post('produits/update.php', {
        'id': id, // Important : inclure l'ID
        'nom': nom,
        'prix': prix,
        'stock': stock,
      });
      return Produit.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduit(int id) async {
    try {
      await _api.post('produits/delete.php', {'id': id});
    } catch (e) {
      rethrow;
    }
  }
}