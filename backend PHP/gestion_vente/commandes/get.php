<?php
// commandes/get.php
require_once '../config.php';
// $user = checkAuth(); // Supprimé si tu ne veux pas d'authentification

$conn = getConnection();

try {
    // Paramètres
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
    $client_id = isset($_GET['client_id']) ? intval($_GET['client_id']) : null;
    $statut = isset($_GET['statut']) ? $_GET['statut'] : null;
    $date_debut = isset($_GET['date_debut']) ? $_GET['date_debut'] : null;
    $date_fin = isset($_GET['date_fin']) ? $_GET['date_fin'] : null;

    $offset = ($page - 1) * $limit;

    // Requête de base
    $query = "SELECT c.*, cl.nom AS client_nom, u.email AS vendeur_email
              FROM commandes c
              JOIN clients cl ON c.client_id = cl.id
              JOIN users u ON c.user_id = u.id
              WHERE 1=1";

    $countQuery = "SELECT COUNT(*) AS total
                   FROM commandes c
                   JOIN clients cl ON c.client_id = cl.id
                   JOIN users u ON c.user_id = u.id
                   WHERE 1=1";

    $params = [];
    $types = '';

    // Filtres
    if ($client_id) {
        $query .= " AND c.client_id = ?";
        $countQuery .= " AND c.client_id = ?";
        $params[] = $client_id;
        $types .= 'i';
    }

    if ($statut) {
        $query .= " AND c.statut = ?";
        $countQuery .= " AND c.statut = ?";
        $params[] = $statut;
        $types .= 's';
    }

    if ($date_debut) {
        $query .= " AND DATE(c.date_commande) >= ?";
        $countQuery .= " AND DATE(c.date_commande) >= ?";
        $params[] = $date_debut;
        $types .= 's';
    }

    if ($date_fin) {
        $query .= " AND DATE(c.date_commande) <= ?";
        $countQuery .= " AND DATE(c.date_commande) <= ?";
        $params[] = $date_fin;
        $types .= 's';
    }

    // Compter le total
    $countStmt = mysqli_prepare($conn, $countQuery);
    if ($types) {
        mysqli_stmt_bind_param($countStmt, $types, ...$params);
    }
    mysqli_stmt_execute($countStmt);
    $countResult = mysqli_stmt_get_result($countStmt);
    $totalRow = mysqli_fetch_assoc($countResult);
    $total = intval($totalRow['total']);
    mysqli_stmt_close($countStmt);

    // Pagination
    $query .= " ORDER BY c.date_commande DESC LIMIT ? OFFSET ?";
    $params[] = $limit;
    $params[] = $offset;
    $types .= 'ii';

    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, $types, ...$params);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $commandes = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $commandes[] = $row;
    }

    mysqli_stmt_close($stmt);

    // Pagination info
    $totalPages = ceil($total / $limit);

    jsonResponse('success', 'Commandes récupérées avec succès', [
        'commandes' => $commandes,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => $totalPages,
            'has_next' => $page < $totalPages,
            'has_prev' => $page > 1
        ]
    ]);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur: ' . $e->getMessage());
} finally {
    mysqli_close($conn);
}
?>
