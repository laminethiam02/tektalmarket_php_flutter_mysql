import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../utils/image_helper.dart';
import 'product_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Product> _myProducts = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    setState(() => _loadingProducts = true);
    try {
      final list = await ProductService().getByUser(auth.user!.id!);
      if (mounted) {
        setState(() {
          _myProducts = list;
          _loadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingProducts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement annonces : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editProfile() async {
    final auth = context.read<AuthProvider>();
    final u = auth.user!;

    final nom = TextEditingController(text: u.nom);
    final tel = TextEditingController(text: u.telephone);
    final ville = TextEditingController(text: u.ville);
    final bio = TextEditingController(text: u.bio);
    final nomMagasin = TextEditingController(text: u.nomMagasin);
    final adresse = TextEditingController(text: u.adresseEntreprise);
    final catEnt = TextEditingController(text: u.categorieEntreprise);
    final descEnt = TextEditingController(text: u.descriptionEntreprise);

    XFile? newImage;
    Uint8List? imageBytes;
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Modifier mon profil',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final f = await ImageHelper.pickSingle();
                          if (f != null) {
                            final bytes = await f.readAsBytes();
                            setSheet(() {
                              newImage = f;
                              imageBytes = bytes;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: imageBytes != null
                              ? MemoryImage(imageBytes!)
                              : (ApiConfig.imageUrl(u.userImage) != null
                              ? CachedNetworkImageProvider(ApiConfig.imageUrl(u.userImage)!)
                              : null),
                          child: imageBytes == null && u.userImage == null
                              ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field(nom, 'Nom'),
                      _field(tel, 'Téléphone'),
                      _field(ville, 'Ville'),
                      _field(bio, 'Bio', maxLines: 2),
                      if (u.isVendeur) ...[
                        const SizedBox(height: 12),
                        const Text('Informations entreprise',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _field(nomMagasin, 'Nom du magasin'),
                        _field(adresse, 'Adresse'),
                        _field(catEnt, 'Catégorie'),
                        _field(descEnt, 'Description', maxLines: 3),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : () async {
                            setSheet(() => isSaving = true);
                            try {
                              await context.read<AuthProvider>().updateProfile(
                                nom: nom.text.trim(),
                                telephone: tel.text.trim(),
                                ville: ville.text.trim(),
                                bio: bio.text.trim(),
                                nomMagasin: u.isVendeur ? nomMagasin.text.trim() : null,
                                adresseEntreprise: u.isVendeur ? adresse.text.trim() : null,
                                categorieEntreprise: u.isVendeur ? catEnt.text.trim() : null,
                                descriptionEntreprise: u.isVendeur ? descEnt.text.trim() : null,
                                userImage: newImage,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              setSheet(() => isSaving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          },
                          child: isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Enregistrer'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    if (u == null) return const SizedBox();

    final img = ApiConfig.imageUrl(u.userImage);
    final membre = u.createdAt != null
        ? DateFormat('MMMM yyyy', 'fr_FR').format(
        DateTime.tryParse(u.createdAt!.replaceAll(' ', 'T')) ?? DateTime.now())
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
              }
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: _loadProducts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: img != null ? CachedNetworkImageProvider(img) : null,
                    child: img == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(u.nom ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Center(
                  child: Chip(
                    label: Text(u.role == 'vendeur' ? 'Vendeur' : 'Acheteur'),
                    backgroundColor: u.role == 'vendeur' ? Colors.green.shade100 : Colors.blue.shade100,
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text(u.email ?? '', style: const TextStyle(color: Colors.grey))),
                Center(child: Text(u.telephone ?? '', style: const TextStyle(color: Colors.grey))),
                Center(
                  child: Text('Membre depuis $membre',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ),
                if ((u.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(u.bio!),
                ],
                if (u.isVendeur && u.nomMagasin != null) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Informations entreprise',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _row('Magasin', u.nomMagasin),
                  _row('Adresse', u.adresseEntreprise),
                  _row('Catégorie', u.categorieEntreprise),
                  if ((u.descriptionEntreprise ?? '').isNotEmpty)
                    _row('Description', u.descriptionEntreprise),
                ],
                if (u.isVendeur) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const Text('Mes annonces',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_loadingProducts)
                    const Center(child: CircularProgressIndicator())
                  else if (_myProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucune annonce publiée', textAlign: TextAlign.center),
                    )
                  else
                    Column(
                      children: _myProducts.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: p.productImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: ApiConfig.imageUrl(p.productImage)!,
                              width: 50, height: 50, fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: Colors.grey.shade200),
                              errorWidget: (_, __, ___) => const Icon(Icons.image),
                            ),
                          )
                              : const Icon(Icons.image),
                          title: Text(p.productTitle ?? ''),
                          subtitle: Text('${p.ville} • ${p.dureeLabel}'),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id!)),
                          ).then((_) => _loadProducts()),
                        ),
                      )).toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}