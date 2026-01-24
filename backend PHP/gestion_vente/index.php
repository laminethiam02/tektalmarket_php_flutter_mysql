<?php
// index.php - Page d'accueil/Test
require_once 'config.php';

echo json_encode([
    "status" => "success",
    "message" => "API Gestion de Vente",
    "version" => "1.0.0",
    "endpoints" => [
        "auth" => [
            "POST /login.php" => "Connexion utilisateur",
            "POST /register.php" => "Inscription utilisateur",
            "POST /logout.php" => "Déconnexion"
        ],
        "clients" => [
            "GET /clients/get.php" => "Liste des clients",
            "POST /clients/add.php" => "Ajouter un client",
            "POST /clients/update.php" => "Modifier un client",
            "POST /clients/delete.php" => "Supprimer un client"
        ],
        "produits" => [
            "GET /produits/get.php" => "Liste des produits",
            "POST /produits/add.php" => "Ajouter un produit",
            "POST /produits/update.php" => "Modifier un produit",
            "POST /produits/delete.php" => "Supprimer un produit",
            "GET /produits/search.php?q=" => "Rechercher un produit"
        ],
        "commandes" => [
            "GET /commandes/get.php" => "Liste des commandes",
            "GET /commandes/get_by_id.php?id=" => "Détails d'une commande",
            "POST /commandes/create.php" => "Créer une commande",
            "POST /commandes/update_status.php" => "Modifier statut",
            "POST /commandes/delete.php" => "Supprimer une commande"
        ],
        "dashboard" => [
            "GET /dashboard.php" => "Tableau de bord",
            "GET /stats/get_stats.php" => "Statistiques"
        ]
    ],
    "instructions" => [
        "1. Commencez par créer un utilisateur via /register.php",
        "2. Connectez-vous via /login.php",
        "3. Utilisez le token retourné dans les headers Authorization: Bearer {token}",
        "4. Explorez les différentes fonctionnalités"
    ]
]);
?>