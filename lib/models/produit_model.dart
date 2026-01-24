class Produit {
  int id;
  String nom;
  double prix;
  int stock;
  DateTime createdAt;

  Produit({
    required this.id,
    required this.nom,
    required this.prix,
    required this.stock,
    required this.createdAt,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nom: json['nom']?.toString() ?? '',
      prix: double.tryParse(json['prix'].toString()) ?? 0.0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prix': prix,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
  }
}