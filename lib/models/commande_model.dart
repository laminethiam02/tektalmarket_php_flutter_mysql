import 'package:flutter/material.dart';

class Commande {
  int id;
  int clientId;
  int userId;
  double total;
  String statut;
  DateTime dateCommande;
  String? clientNom;
  String? vendeurEmail;

  Commande({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.total,
    required this.statut,
    required this.dateCommande,
    this.clientNom,
    this.vendeurEmail,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      clientId: json['client_id'],
      userId: json['user_id'],
      total: double.parse(json['total'].toString()),
      statut: json['statut'],
      dateCommande: DateTime.parse(json['date_commande']),
      clientNom: json['client_nom'],
      vendeurEmail: json['vendeur_email'],
    );
  }

  String get statusText {
    switch (statut) {
      case 'en_attente': return 'En attente';
      case 'payee': return 'Payée';
      case 'annulee': return 'Annulée';
      default: return statut;
    }
  }

  Color get statusColor {
    switch (statut) {
      case 'en_attente': return Colors.orange;
      case 'payee': return Colors.green;
      case 'annulee': return Colors.red;
      default: return Colors.grey;
    }
  }
}