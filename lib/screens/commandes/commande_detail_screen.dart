import 'package:flutter/material.dart';
import '../../models/commande_model.dart';
import '../../models/commande_item_model.dart';
import '../../services/commande_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';

class CommandeDetailScreen extends StatefulWidget {
  final int commandeId;

  const CommandeDetailScreen({Key? key, required this.commandeId}) : super(key: key);

  @override
  _CommandeDetailScreenState createState() => _CommandeDetailScreenState();
}

class _CommandeDetailScreenState extends State<CommandeDetailScreen> {
  final CommandeService _commandeService = CommandeService();
  Commande? _commande;
  List<CommandeItem> _items = [];
  bool _isLoading = true;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadCommandeDetail();
  }

  Future<void> _loadCommandeDetail() async {
    try {
      final data = await _commandeService.getCommandeDetail(widget.commandeId);
      setState(() {
        _commande = data['commande'] as Commande;
        _items = data['items'] as List<CommandeItem>;
        _total = data['total'] as double;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _commandeService.updateStatus(widget.commandeId, newStatus);
      setState(() {
        if (_commande != null) {
          _commande!.statut = newStatus;
        }
      });
      if (mounted) {
        CustomDialog.showSuccess(context, 'Statut mis à jour');
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
    }
  }

  Future<void> _deleteCommande() async {
    final confirmed = await CustomDialog.showConfirm(
      context,
      'Supprimer cette commande?',
      'Cette action est irréversible.',
    );

    if (confirmed) {
      try {
        await _commandeService.deleteCommande(widget.commandeId);
        if (mounted) {
          CustomDialog.showSuccess(
            context,
            'Commande supprimée avec succès',
            onConfirm: () => Navigator.pop(context),
          );
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
        title: 'Commande #${widget.commandeId}',
        actions: [
          if (_commande?.statut == 'en_attente')
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'payee',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Marquer comme payée'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'annulee',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Annuler la commande'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'payee' || value == 'annulee') {
                  _updateStatus(value);
                } else if (value == 'delete') {
                  _deleteCommande();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _commande == null
          ? const Center(child: Text('Commande non trouvée'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations générales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Commande #${_commande!.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            _commande!.statusText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _commande!.statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Client', _commande!.clientNom ?? 'N/A'),
                    _buildInfoRow('Vendeur', _commande!.vendeurEmail ?? 'N/A'),
                    _buildInfoRow(
                      'Date',
                      _formatDate(_commande!.dateCommande),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_commande!.total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Produits
            const SizedBox(height: 20),
            const Text(
              'Produits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _items.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(item.produitNom ?? 'Produit'),
                      subtitle: Text(
                        '${item.quantite} × ${item.prixUnitaire.toStringAsFixed(2)} €',
                      ),
                      trailing: Text(
                        '${item.sousTotal.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}