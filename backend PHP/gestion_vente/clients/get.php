<?php
require_once '../config.php';

header("Content-Type: application/json");

$conn = getConnection();

try {
    // Paramètres
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    $search = isset($_GET['search']) ? $_GET['search'] : '';

    if ($page < 1) $page = 1;
    if ($limit < 1) $limit = 20;

    $offset = ($page - 1) * $limit;

    // Requête de base
    $where = "";
    if (!empty($search)) {
        $search = mysqli_real_escape_string($conn, $search);
        $where = "WHERE nom LIKE '%$search%' 
                  OR telephone LIKE '%$search%' 
                  OR adresse LIKE '%$search%'";
    }

    // Total
    $countQuery = "SELECT COUNT(*) AS total FROM clients $where";
    $countResult = mysqli_query($conn, $countQuery);
    $total = mysqli_fetch_assoc($countResult)['total'];

    // Données
    $query = "SELECT * FROM clients 
              $where 
              ORDER BY created_at DESC 
              LIMIT $limit OFFSET $offset";

    $result = mysqli_query($conn, $query);

    $clients = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $clients[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "message" => "Clients récupérés avec succès",
        "data" => [
            "clients" => $clients,
            "pagination" => [
                "page" => $page,
                "limit" => $limit,
                "total" => (int)$total,
                "total_pages" => ceil($total / $limit)
            ]
        ]
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur serveur"
    ]);
}

mysqli_close($conn);
