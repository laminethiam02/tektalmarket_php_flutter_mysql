class Client {
  int id;
  String nom;
  String? telephone;
  String? adresse;
  DateTime createdAt;

  Client({
    required this.id,
    required this.nom,
    this.telephone,
    this.adresse,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    // Fonction pour parser l'ID de manière robuste
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) return value.toInt();
      return 0;
    }

    // Fonction pour parser la date de manière robuste
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (value is int) {
        // Si c'est un timestamp (secondes ou millisecondes)
        if (value > 1000000000000) {
          // Probablement en millisecondes
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          // Probablement en secondes
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      return DateTime.now();
    }

    return Client(
      id: parseId(json['id']), // Correction ici
      nom: json['nom']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      adresse: json['adresse']?.toString(),
      createdAt: parseDateTime(json['created_at']), // Correction ici
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'adresse': adresse,
      'created_at': createdAt.toIso8601String(),
    };
  }
}