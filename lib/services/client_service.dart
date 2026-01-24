import 'package:gestion_vente/models/client_model.dart';
import 'api_service.dart';

class ClientService {
  final ApiService _api = ApiService();

  Future<List<Client>> getClients({int page = 1, int limit = 20, String? search}) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _api.get('clients/get.php', params: params);

      // DEBUG: Log pour voir la structure
      print('=== DEBUG CLIENT SERVICE ===');
      print('Réponse complète: $response');

      if (response['data'] == null || response['data']['clients'] == null) {
        print('Aucun client trouvé ou structure incorrecte');
        return [];
      }

      final data = response['data']['clients'] as List;

      if (data.isNotEmpty) {
        print('Premier élément brut: ${data[0]}');
        print('Type de id: ${data[0]['id'].runtimeType}');
        print('Type de created_at: ${data[0]['created_at'].runtimeType}');
      }
      print('==========================');

      List<Client> clients = [];
      for (var item in data) {
        try {
          clients.add(Client.fromJson(item));
        } catch (e) {
          print('Erreur parsing client: $e');
          print('Données problématiques: $item');
        }
      }

      return clients;
    } catch (e) {
      print('Erreur getClients: $e');
      rethrow;
    }
  }

  Future<Client> addClient(String nom, String? telephone, String? adresse) async {
    try {
      final response = await _api.post('clients/add.php', {
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
      });

      print('Réponse addClient: $response');

      if (response['data'] == null) {
        throw Exception('Aucune donnée dans la réponse');
      }

      return Client.fromJson(response['data']);
    } catch (e) {
      print('Erreur addClient: $e');
      rethrow;
    }
  }

  Future<Client> updateClient(int id, String nom, String? telephone, String? adresse) async {
    try {
      final response = await _api.post('clients/update.php', {
        'id': id.toString(), // Toujours envoyer comme string pour l'API
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
      });

      print('Réponse updateClient: $response');

      if (response['data'] == null) {
        throw Exception('Aucune donnée dans la réponse');
      }

      return Client.fromJson(response['data']);
    } catch (e) {
      print('Erreur updateClient: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      final response = await _api.post('clients/delete.php', {'id': id.toString()});
      print('Réponse deleteClient: $response');
    } catch (e) {
      print('Erreur deleteClient: $e');
      rethrow;
    }
  }
}