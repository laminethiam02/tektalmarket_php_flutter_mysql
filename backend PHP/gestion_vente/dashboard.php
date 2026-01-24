<?php
// dashboard.php
require_once 'config.php';

$conn = getConnection();

try {
    $stats = [];

    /* 1. Total clients */
    $result = mysqli_query($conn, "SELECT COUNT(*) AS total FROM clients");
    $row = mysqli_fetch_assoc($result);
    $stats['total_clients'] = (int)$row['total'];

    /* 2. Total produits */
    $result = mysqli_query($conn, "SELECT COUNT(*) AS total FROM produits");
    $row = mysqli_fetch_assoc($result);
    $stats['total_produits'] = (int)$row['total'];

    /* 3. Total commandes */
    $result = mysqli_query($conn, "SELECT COUNT(*) AS total FROM commandes");
    $row = mysqli_fetch_assoc($result);
    $stats['total_commandes'] = (int)$row['total'];

    /* 4. Chiffre d’affaires (commandes payées) */
    $result = mysqli_query(
        $conn,
        "SELECT SUM(total) AS total FROM commandes WHERE statut = 'payee'"
    );
    $row = mysqli_fetch_assoc($result);
    $stats['chiffre_affaires'] = (float)($row['total'] ?? 0);

    /* 5. Produits les plus vendus */
    $query = "
        SELECT p.nom, SUM(ci.quantite) AS total_vendu
        FROM commande_items ci
        JOIN produits p ON ci.produit_id = p.id
        GROUP BY ci.produit_id
        ORDER BY total_vendu DESC
        LIMIT 5
    ";
    $result = mysqli_query($conn, $query);
    $stats['produits_populaires'] = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $stats['produits_populaires'][] = $row;
    }

    /* 6. Commandes récentes */
    $query = "
        SELECT c.id, c.date_commande, c.total, c.statut, cl.nom AS client_nom
        FROM commandes c
        JOIN clients cl ON c.client_id = cl.id
        ORDER BY c.date_commande DESC
        LIMIT 10
    ";
    $result = mysqli_query($conn, $query);
    $stats['commandes_recentes'] = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $stats['commandes_recentes'][] = $row;
    }

    /* 7. Stocks bas */
    $result = mysqli_query(
        $conn,
        "SELECT nom, stock FROM produits WHERE stock < 10 ORDER BY stock ASC LIMIT 10"
    );
    $stats['stocks_bas'] = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $stats['stocks_bas'][] = $row;
    }

    /* 8. Commandes par statut */
    $result = mysqli_query(
        $conn,
        "SELECT statut, COUNT(*) AS nombre FROM commandes GROUP BY statut"
    );
    $stats['commandes_par_statut'] = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $stats['commandes_par_statut'][] = $row;
    }

    jsonResponse('success', 'Données du dashboard récupérées', $stats);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    mysqli_close($conn);
}
