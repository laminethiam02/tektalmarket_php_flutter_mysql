import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/stats_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../clients/clients_screen.dart';
import '../produits/produits_screen.dart';
import '../commandes/commandes_screen.dart';
import '../stats/stats_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StatsService _statsService = StatsService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _statsService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Provider.of<UserModel>(context, listen: false).logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    final List<Widget> _screens = [
      _buildDashboardContent(),
      const ClientsScreen(),
      const ProduitsScreen(),
      const CommandesScreen(),
    ];

    if (userModel.isAdmin) {
      _screens.add(const StatsScreen());
    }

    final List<BottomNavigationBarItem> _navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: 'Clients',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory),
        label: 'Produits',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Commandes',
      ),
    ];

    if (userModel.isAdmin) {
      _navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Stats',
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading ? const LoadingWidget() : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Aperçu général',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard('Clients', _stats['total_clients'] ?? 0,
                  Icons.people, Colors.blue),
              _buildStatCard('Produits', _stats['total_produits'] ?? 0,
                  Icons.inventory, Colors.green),
              _buildStatCard('Commandes', _stats['total_commandes'] ?? 0,
                  Icons.shopping_cart, Colors.orange),
              _buildStatCard('Chiffre d\'affaires',
                  '${(_stats['chiffre_affaires'] ?? 0).toStringAsFixed(2)} €',
                  Icons.euro, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),
          if (_stats['stocks_bas'] != null && (_stats['stocks_bas'] as List).isNotEmpty)
            _buildLowStockSection(),
          const SizedBox(height: 30),
          if (_stats['commandes_recentes'] != null && (_stats['commandes_recentes'] as List).isNotEmpty)
            _buildRecentOrdersSection(),
        ],
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  'Stocks bas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...(_stats['stocks_bas'] as List).map<Widget>((produit) {
              return ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.red),
                title: Text(produit['nom']),
                subtitle: Text('Stock: ${produit['stock']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Naviguer vers l'édition du produit
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'Commandes récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...(_stats['commandes_recentes'] as List).map<Widget>((commande) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(commande['statut']),
                  child: Text(
                    commande['id'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Commande #${commande['id']}'),
                subtitle: Text('Client: ${commande['client_nom']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${commande['total']} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        _getStatusText(commande['statut']),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(commande['statut']),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'payee': return Colors.green;
      case 'en_attente': return Colors.orange;
      case 'annulee': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'payee': return 'Payée';
      case 'en_attente': return 'En attente';
      case 'annulee': return 'Annulée';
      default: return status;
    }
  }
}