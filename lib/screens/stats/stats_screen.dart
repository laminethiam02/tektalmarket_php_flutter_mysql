import 'package:flutter/material.dart';
import '../../services/stats_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StatsService _statsService = StatsService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedPeriod = 'month';
  final List<String> _periods = [
    'day',
    'week',
    'month',
    'year',
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _statsService.getDetailedStats(period: _selectedPeriod);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  // Helper pour convertir une valeur en double avant d'appeler toStringAsFixed
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    return 0.0;
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Méthode alternative pour le graphique (sans syncfusion)
  Widget _buildSalesChart() {
    final ventes = _stats['ventes_par_periode'] as List<dynamic>?;
    if (ventes == null || ventes.isEmpty) {
      return const SizedBox(height: 0);
    }

    final maxValue = ventes.fold<double>(0, (max, item) {
      final value = _safeToDouble(item['chiffre_affaires']);
      return value > max ? value : max;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution des ventes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: ventes.map<Widget>((item) {
                  final value = _safeToDouble(item['chiffre_affaires']);
                  final double height = maxValue > 0 ? (value / maxValue * 150) : 0.0;
                  // Assurer une hauteur minimale pour les valeurs non nulles
                  const double minHeight = 5.0;
                  final double finalHeight = value > 0 && height < minHeight ? minHeight : height;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${value.toStringAsFixed(0)}€',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: finalHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['periode'].toString(),
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Statistiques',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de période
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Période',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _periods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(_getPeriodText(period)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPeriod = value!);
                        _loadStats();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Statistiques globales
            const SizedBox(height: 20),
            const Text(
              'Aperçu global',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Commandes',
                  _stats['global_stats']?['total_commandes'] ?? 0,
                  Icons.shopping_cart,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Chiffre d\'affaires',
                  '${_safeToDouble(_stats['global_stats']?['chiffre_affaires']).toStringAsFixed(2)} €',
                  Icons.euro,
                  Colors.green,
                ),
                _buildStatCard(
                  'Moyenne commande',
                  '${_safeToDouble(_stats['global_stats']?['moyenne_commande']).toStringAsFixed(2)} €',
                  Icons.analytics,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Clients actifs',
                  _stats['global_stats']?['clients_actifs'] ?? 0,
                  Icons.people,
                  Colors.purple,
                ),
              ],
            ),

            // Graphique des ventes
            if (_stats['ventes_par_periode'] != null &&
                (_stats['ventes_par_periode'] as List).isNotEmpty) ...[
              const SizedBox(height: 30),
              _buildSalesChart(),
            ],

            // Top clients
            if (_stats['top_clients'] != null &&
                (_stats['top_clients'] as List).isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text(
                'Top 10 clients',
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
                    children: (_stats['top_clients'] as List).map<Widget>((client) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (client['client_nom'] as String).isNotEmpty
                                ? (client['client_nom'] as String)[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(client['client_nom'].toString()),
                        subtitle: Text('${client['nombre_commandes']} commandes'),
                        trailing: Text(
                          '${_safeToDouble(client['total_depense']).toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // Top produits
            if (_stats['top_produits'] != null &&
                (_stats['top_produits'] as List).isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text(
                'Top 10 produits',
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
                    children: (_stats['top_produits'] as List).map<Widget>((produit) {
                      return ListTile(
                        leading: const Icon(Icons.inventory, color: Colors.blue),
                        title: Text(produit['produit_nom'].toString()),
                        subtitle: Text('${produit['total_vendu']} unités vendues'),
                        trailing: Text(
                          '${_safeToDouble(produit['chiffre_affaires_produit']).toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'day': return 'Aujourd\'hui';
      case 'week': return 'Cette semaine';
      case 'month': return 'Ce mois';
      case 'year': return 'Cette année';
      default: return period;
    }
  }
}