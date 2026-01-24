<?php
// stats/get_stats.php
require_once '../config.php';

// ❌ suppression de l'authentification
// $user = checkAuth();

$conn = getConnection();

try {
    // Période (day | week | month | year)
    $period = isset($_GET['period']) ? $_GET['period'] : 'month';

    switch ($period) {
        case 'day':
            $date_condition = "DATE(date_commande) = CURDATE()";
            $date_format = '%H:00';
            break;

        case 'week':
            $date_condition = "date_commande >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
            $date_format = '%Y-%m-%d';
            break;

        case 'month':
            $date_condition = "date_commande >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
            $date_format = '%Y-%m-%d';
            break;

        case 'year':
            $date_condition = "date_commande >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)";
            $date_format = '%Y-%m';
            break;

        default:
            $date_condition = "1=1";
            $date_format = '%Y-%m-%d';
    }

    /* ======================================================
       1️⃣ VENTES PAR PÉRIODE
    ====================================================== */
    $salesQuery = "
        SELECT 
            DATE_FORMAT(date_commande, '$date_format') AS periode,
            COUNT(*) AS nombre_commandes,
            SUM(total) AS chiffre_affaires,
            AVG(total) AS moyenne_commande
        FROM commandes
        WHERE statut = 'payee' AND $date_condition
        GROUP BY periode
        ORDER BY periode ASC
    ";

    $salesResult = mysqli_query($conn, $salesQuery);
    $ventes_par_periode = mysqli_fetch_all($salesResult, MYSQLI_ASSOC);

    /* ======================================================
       2️⃣ TOP CLIENTS
    ====================================================== */
    $topClientsQuery = "
        SELECT 
            c.client_id,
            cl.nom AS client_nom,
            COUNT(*) AS nombre_commandes,
            SUM(c.total) AS total_depense
        FROM commandes c
        JOIN clients cl ON c.client_id = cl.id
        WHERE c.statut = 'payee'
        GROUP BY c.client_id
        ORDER BY total_depense DESC
        LIMIT 10
    ";

    $top_clients = mysqli_fetch_all(
        mysqli_query($conn, $topClientsQuery),
        MYSQLI_ASSOC
    );

    /* ======================================================
       3️⃣ PRODUITS LES PLUS VENDUS
    ====================================================== */
    $topProduitsQuery = "
        SELECT 
            ci.produit_id,
            p.nom AS produit_nom,
            SUM(ci.quantite) AS total_vendu,
            SUM(ci.quantite * ci.prix_unitaire) AS chiffre_affaires_produit
        FROM commande_items ci
        JOIN produits p ON ci.produit_id = p.id
        JOIN commandes c ON ci.commande_id = c.id
        WHERE c.statut = 'payee'
        GROUP BY ci.produit_id
        ORDER BY total_vendu DESC
        LIMIT 10
    ";

    $top_produits = mysqli_fetch_all(
        mysqli_query($conn, $topProduitsQuery),
        MYSQLI_ASSOC
    );

    /* ======================================================
       4️⃣ TOP VENDEURS
    ====================================================== */
    $topVendeursQuery = "
        SELECT 
            c.user_id,
            u.email AS vendeur_email,
            COUNT(*) AS nombre_commandes,
            SUM(c.total) AS chiffre_affaires_vendeur
        FROM commandes c
        JOIN users u ON c.user_id = u.id
        WHERE c.statut = 'payee'
        GROUP BY c.user_id
        ORDER BY chiffre_affaires_vendeur DESC
        LIMIT 10
    ";

    $top_vendeurs = mysqli_fetch_all(
        mysqli_query($conn, $topVendeursQuery),
        MYSQLI_ASSOC
    );

    /* ======================================================
       5️⃣ STATISTIQUES GLOBALES
    ====================================================== */
    $globalQuery = "
        SELECT
            (SELECT COUNT(*) FROM commandes WHERE $date_condition) AS total_commandes,
            (SELECT SUM(total) FROM commandes WHERE statut = 'payee' AND $date_condition) AS chiffre_affaires,
            (SELECT AVG(total) FROM commandes WHERE statut = 'payee' AND $date_condition) AS moyenne_commande,
            (SELECT COUNT(DISTINCT client_id) FROM commandes WHERE $date_condition) AS clients_actifs
    ";

    $global_stats = mysqli_fetch_assoc(
        mysqli_query($conn, $globalQuery)
    );

    /* ======================================================
       RÉPONSE
    ====================================================== */
    jsonResponse('success', 'Statistiques récupérées avec succès', [
        'periode' => $period,
        'global_stats' => $global_stats,
        'ventes_par_periode' => $ventes_par_periode,
        'top_clients' => $top_clients,
        'top_produits' => $top_produits,
        'top_vendeurs' => $top_vendeurs
    ]);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    mysqli_close($conn);
}
?>
