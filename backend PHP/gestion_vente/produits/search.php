<?php
// produits/search.php
require_once '../config.php';

header("Content-Type: application/json");

$conn = getConnection();

try {
    // Récupérer le terme de recherche
    $search = isset($_GET['q']) ? escapeData($conn, $_GET['q']) : '';
    $limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;

    if (empty($search)) {
        echo json_encode(['status' => 'error', 'message' => 'Terme de recherche requis']);
        exit;
    }

    // Préparer les variables
    $searchId = intval($search);       // pour comparer avec l'ID
    $likeSearch = "%$search%";         // pour LIKE

    // Requête sécurisée
    $query = "SELECT id, nom, prix, stock FROM produits
              WHERE nom LIKE ? OR id = ?
              ORDER BY 
                CASE 
                    WHEN nom LIKE CONCAT(?, '%') THEN 1
                    WHEN nom LIKE ? THEN 2
                    ELSE 3
                END,
                nom ASC
              LIMIT ?";

    $stmt = mysqli_prepare($conn, $query);

    // Il faut **6 variables** pour 6 placeholders dans la requête
    // ? (nom LIKE ?) -> $likeSearch
    // ? (id = ?) -> $searchId
    // ? (nom LIKE CONCAT(?, '%')) -> $search
    // ? (nom LIKE ?) -> $likeSearch
    // ? (LIMIT ?) -> $limit
    // Donc types : s (LIKE) i (id) s (search) s (LIKE) i (limit) = "sis si" → "sissi"

    mysqli_stmt_bind_param($stmt, "sissi", $likeSearch, $searchId, $search, $likeSearch, $limit);

    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $produits = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $produits[] = $row;
    }

    echo json_encode(['status' => 'success', 'message' => 'Recherche effectuée avec succès', 'data' => $produits]);

} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erreur: ' . $e->getMessage()]);
} finally {
    if (isset($stmt)) mysqli_stmt_close($stmt);
    mysqli_close($conn);
}
