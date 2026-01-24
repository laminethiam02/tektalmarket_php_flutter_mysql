<?php
// produits/get.php
require_once '../config.php';

header("Content-Type: application/json");

$conn = getConnection();

try {
    // Récupérer les paramètres
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
    $search = isset($_GET['search']) ? escapeData($conn, $_GET['search']) : '';
    $minPrice = isset($_GET['min_price']) ? floatval($_GET['min_price']) : null;
    $maxPrice = isset($_GET['max_price']) ? floatval($_GET['max_price']) : null;
    $lowStock = isset($_GET['low_stock']) ? boolval($_GET['low_stock']) : false;

    $offset = ($page - 1) * $limit;

    // Construire la requête
    $query = "SELECT * FROM produits WHERE 1=1";
    $countQuery = "SELECT COUNT(*) as total FROM produits WHERE 1=1";

    // Filtres
    if ($search) {
        $query .= " AND nom LIKE '%$search%'";
        $countQuery .= " AND nom LIKE '%$search%'";
    }

    if ($minPrice !== null) {
        $query .= " AND prix >= $minPrice";
        $countQuery .= " AND prix >= $minPrice";
    }

    if ($maxPrice !== null) {
        $query .= " AND prix <= $maxPrice";
        $countQuery .= " AND prix <= $maxPrice";
    }

    if ($lowStock) {
        $query .= " AND stock < 10";
        $countQuery .= " AND stock < 10";
    }

    // Exécuter le comptage
    $countResult = mysqli_query($conn, $countQuery);
    $totalRow = mysqli_fetch_assoc($countResult);
    $total = intval($totalRow['total']);

    // Ajouter pagination et tri
    $query .= " ORDER BY created_at DESC LIMIT $limit OFFSET $offset";

    // Exécuter la requête principale
    $result = mysqli_query($conn, $query);

    $produits = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $produits[] = $row;
    }

    // Calculer la pagination
    $totalPages = ceil($total / $limit);

    echo json_encode([
        'status' => 'success',
        'message' => 'Produits récupérés avec succès',
        'data' => [
            'produits' => $produits,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'total_pages' => $totalPages,
                'has_next' => $page < $totalPages,
                'has_prev' => $page > 1
            ]
        ]
    ]);

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Erreur: ' . $e->getMessage()
    ]);
} finally {
    mysqli_close($conn);
}
