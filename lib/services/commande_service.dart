import 'package:gestion_vente/models/commande_model.dart';
import 'package:gestion_vente/models/commande_item_model.dart';
import 'api_service.dart';

class CommandeService {
  final ApiService _api = ApiService();

  Future<List<Commande>> getCommandes({
    int page = 1,
    int limit = 20,
    int? clientId,
    String? statut,
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (clientId != null) 'client_id': clientId.toString(),
        if (statut != null) 'statut': statut,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin != null) 'date_fin': dateFin,
      };

      final response = await _api.get('commandes/get.php', params: params);
      final data = response['data']['commandes'] as List;

      return data.map((json) => Commande.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCommandeDetail(int id) async {
    try {
      final response = await _api.get('commandes/get_by_id.php', params: {'id': id.toString()});
      final commande = Commande.fromJson(response['data']['commande']);
      final itemsData = response['data']['items'] as List;
      final items = itemsData.map((json) => CommandeItem.fromJson(json)).toList();

      return {
        'commande': commande,
        'items': items,
        'total': response['data']['total'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCommande(int clientId, List<CommandeItem> items) async {
    try {
      final response = await _api.post('commandes/create.php', {
        'client_id': clientId,
        'items': items.map((item) => item.toJson()).toList(),
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(int id, String statut) async {
    try {
      await _api.post('commandes/update_status.php', {
        'id': id,
        'statut': statut,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCommande(int id) async {
    try {
      await _api.post('commandes/delete.php', {'id': id});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CommandeItem>> getCommandeItems(int commandeId) async {
    try {
      final response = await _api.get('commande_items/get_by_commande.php', params: {'commande_id': commandeId.toString()});
      final data = response['data']['items'] as List;

      return data.map((json) => CommandeItem.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CommandeItem> addCommandeItem(int commandeId, int produitId, int quantite) async {
    try {
      final response = await _api.post('commande_items/add.php', {
        'commande_id': commandeId,
        'produit_id': produitId,
        'quantite': quantite,
      });

      return CommandeItem.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCommandeItem(int id) async {
    try {
      await _api.post('commande_items/delete.php', {'id': id});
    } catch (e) {
      rethrow;
    }
  }
}