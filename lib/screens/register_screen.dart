import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _tel = TextEditingController();
  final _ville = TextEditingController();
  final _bio = TextEditingController();
  final _nomMagasin = TextEditingController();
  final _adresse = TextEditingController();
  final _categorie = TextEditingController();
  final _descEntreprise = TextEditingController();

  String _role = 'acheteur';
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().register(
      nom: _nom.text.trim(), email: _email.text.trim(),
      password: _pass.text, telephone: _tel.text.trim(),
      ville: _ville.text.trim(), role: _role,
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      nomMagasin: _role == 'vendeur' ? _nomMagasin.text.trim() : null,
      adresseEntreprise: _role == 'vendeur' ? _adresse.text.trim() : null,
      categorieEntreprise: _role == 'vendeur' ? _categorie.text.trim() : null,
      descriptionEntreprise: _role == 'vendeur' ? _descEntreprise.text.trim() : null,
    );
    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.pop(context);
      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Erreur'),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nom,
              decoration: const InputDecoration(
                  labelText: 'Nom complet *', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Mot de passe *', prefixIcon: Icon(Icons.lock_outline)),
              validator: (v) => (v == null || v.length < 6) ? '6 caractères min.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Téléphone *', prefixIcon: Icon(Icons.phone_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ville,
              decoration: const InputDecoration(
                  labelText: 'Ville *', prefixIcon: Icon(Icons.location_on_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            const Text('Je suis :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'acheteur', label: Text('Acheteur'), icon: Icon(Icons.shopping_bag_outlined)),
                ButtonSegment(value: 'vendeur', label: Text('Vendeur'), icon: Icon(Icons.store_outlined)),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bio,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Bio (optionnel)', prefixIcon: Icon(Icons.info_outline)),
            ),
            if (_role == 'vendeur') ...[
              const SizedBox(height: 24),
              const Text('Informations entreprise',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomMagasin,
                decoration: const InputDecoration(
                    labelText: 'Nom du magasin/entreprise *',
                    prefixIcon: Icon(Icons.store)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adresse,
                decoration: const InputDecoration(
                    labelText: 'Adresse entreprise *',
                    prefixIcon: Icon(Icons.place_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categorie,
                decoration: const InputDecoration(
                    labelText: 'Catégorie entreprise *',
                    prefixIcon: Icon(Icons.category_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descEntreprise,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Description de l'entreprise",
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined)),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}