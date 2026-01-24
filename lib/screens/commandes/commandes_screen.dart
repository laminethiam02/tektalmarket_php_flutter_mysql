import 'package:flutter/material.dart';
import '../../models/commande_model.dart';
import '../../services/commande_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';
import 'create_commande_screen.dart';
import 'commande_detail_screen.dart';

class CommandesScreen extends StatefulWidget {
  const CommandesScreen({Key? key}) : super(key: key);

  @override
  _CommandesScreenState createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  final CommandeService _commandeService = CommandeService();
  List<Commande> _commandes = [];
  List<Commande> _filteredCommandes = [];
  bool _isLoading = true;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  String _selectedStatus = 'tous';
  final List<String> _statusOptions = ['tous', 'en_attente', 'payee', 'annulee'];

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  Future<void> _loadCommandes({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _commandes.clear();
        _filteredCommandes.clear();
      });
    }

    try {
      final commandes = await _commandeService.getCommandes(
        page: _page,
        limit: _limit,
        statut: _selectedStatus == 'tous' ? null : _selectedStatus,
      );

      setState(() {
        if (reset) {
          _commandes = commandes;
        } else {
          _commandes.addAll(commandes);
        }
        _filteredCommandes = _commandes;
        _hasMore = commandes.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCommande(int id, BuildContext context) async {
    final confirmed = await CustomDialog.showConfirm(
      context,
      'Supprimer cette commande?',
      'Cette action est irréversible.',
    );

    if (confirmed) {
      try {
        await _commandeService.deleteCommande(id);
        setState(() {
          _commandes.removeWhere((commande) => commande.id == id);
          _filteredCommandes.removeWhere((commande) => commande.id == id);
        });
        if (mounted) {
          CustomDialog.showSuccess(context, 'Commande supprimée avec succès');
        }
      } catch (e) {
        if (mounted) {
          CustomDialog.showError(context, 'Erreur: $e');
        }
      }
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await _commandeService.updateStatus(id, newStatus);
      final index = _commandes.indexWhere((c) => c.id == id);
      if (index != -1) {
        setState(() {
          _commandes[index].statut = newStatus;
          _filteredCommandes = List.from(_commandes);
        });
      }
      if (mounted) {
        CustomDialog.showSuccess(context, 'Statut mis à jour');
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Commandes',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateCommandeScreen()),
              );
              await _loadCommandes(reset: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filtrer par statut',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _loadCommandes(reset: true);
              },
            ),
          ),
          Expanded(
            child: _isLoading && _commandes.isEmpty
                ? const LoadingWidget()
                : _filteredCommandes.isEmpty
                ? const Center(
              child: Text('Aucune commande trouvée'),
            )
                : ListView.builder(
              itemCount: _filteredCommandes.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredCommandes.length) {
                  return _buildLoadMoreButton();
                }

                final commande = _filteredCommandes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommandeDetailScreen(commandeId: commande.id),
                        ),
                      );
                      await _loadCommandes(reset: true);
                    },
                    leading: CircleAvatar(
                      backgroundColor: commande.statusColor,
                      child: Text(
                        commande.id.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'Commande #${commande.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${commande.clientNom ?? 'N/A'}'),
                        Text('Vendeur: ${commande.vendeurEmail ?? 'N/A'}'),
                        Text(
                          'Date: ${_formatDate(commande.dateCommande)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${commande.total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            commande.statusText,
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: commande.statusColor,
                        ),
                      ],
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
          _loadCommandes();
        },
        child: const Text('Charger plus'),
      ),
    )
        : const SizedBox();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'tous': return 'Tous';
      case 'en_attente': return 'En attente';
      case 'payee': return 'Payées';
      case 'annulee': return 'Annulées';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}