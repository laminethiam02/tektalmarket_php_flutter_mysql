class CommandeItem {
  int id;
  int commandeId;
  int produitId;
  int quantite;
  double prixUnitaire;
  String? produitNom;

  CommandeItem({
    required this.id,
    required this.commandeId,
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
    this.produitNom,
  });

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    return CommandeItem(
      id: json['id'],
      commandeId: json['commande_id'],
      produitId: json['produit_id'],
      quantite: json['quantite'],
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      produitNom: json['produit_nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produit_id': produitId,
      'quantite': quantite,
    };
  }

  double get sousTotal => prixUnitaire * quantite;
}