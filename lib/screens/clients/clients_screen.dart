import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientService _clientService = ClientService();
  final TextEditingController _searchController = TextEditingController();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _clients.clear();
        _filteredClients.clear();
      });
    }

    try {
      final clients = await _clientService.getClients(
        page: _page,
        limit: _limit,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        if (reset) {
          _clients = clients;
        } else {
          _clients.addAll(clients);
        }
        _filteredClients = _clients;
        _hasMore = clients.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _clients.where((client) {
        return client.nom.toLowerCase().contains(query) ||
            (client.telephone?.toLowerCase().contains(query) ?? false) ||
            (client.adresse?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _deleteClient(int id, BuildContext context) async {
    final confirmed = await CustomDialog.showConfirm(
      context,
      'Supprimer ce client?',
      'Cette action est irréversible.',
    );

    if (confirmed) {
      try {
        await _clientService.deleteClient(id);
        setState(() {
          _clients.removeWhere((client) => client.id == id);
          _filteredClients.removeWhere((client) => client.id == id);
        });
        if (mounted) {
          CustomDialog.showSuccess(context, 'Client supprimé avec succès');
        }
      } catch (e) {
        if (mounted) {
          CustomDialog.showError(context, 'Erreur: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Clients',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClientScreen()),
              );
              await _loadClients(reset: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _clients.isEmpty
                ? const LoadingWidget()
                : _filteredClients.isEmpty
                ? const Center(
              child: Text('Aucun client trouvé'),
            )
                : ListView.builder(
              itemCount: _filteredClients.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredClients.length) {
                  return _buildLoadMoreButton();
                }

                final client = _filteredClients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(client.nom[0].toUpperCase()),
                    ),
                    title: Text(
                      client.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (client.telephone != null)
                          Text('📞 ${client.telephone}'),
                        if (client.adresse != null)
                          Text('📍 ${client.adresse}'),
                        Text(
                          'Créé le ${_formatDate(client.createdAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Modifier'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditClientScreen(client: client),
                            ),
                          ).then((_) => _loadClients(reset: true));
                        } else if (value == 'delete') {
                          _deleteClient(client.id, context);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return _isLoading
        ? const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    )
        : _hasMore
        ? Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _page++;
            _isLoading = true;
          });
          _loadClients();
        },
        child: const Text('Charger plus'),
      ),
    )
        : const SizedBox();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}