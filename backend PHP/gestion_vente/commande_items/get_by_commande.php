<?php
// commande_items/get_by_commande.php
require_once '../config.php';

// ❌ suppression de l'authentification
// $user = checkAuth();

if (!isset($_GET['commande_id']) || intval($_GET['commande_id']) <= 0) {
    jsonResponse('error', 'ID de commande invalide');
}

$conn = getConnection();
$commande_id = intval($_GET['commande_id']);

try {
    $query = "
        SELECT 
            ci.id,
            ci.commande_id,
            ci.produit_id,
            ci.quantite,
            ci.prix_unitaire,
            p.nom AS produit_nom,
            p.prix AS prix_actuel
        FROM commande_items ci
        JOIN produits p ON ci.produit_id = p.id
        WHERE ci.commande_id = ?
    ";

    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "i", $commande_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $items = [];
    $total = 0;

    while ($row = mysqli_fetch_assoc($result)) {
        $row['sous_total'] = $row['prix_unitaire'] * $row['quantite'];
        $total += $row['sous_total'];
        $items[] = $row;
    }

    jsonResponse('success', 'Items récupérés avec succès', [
        'commande_id' => $commande_id,
        'items' => $items,
        'total' => $total,
        'count' => count($items)
    ]);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    if (isset($stmt)) {
        mysqli_stmt_close($stmt);
    }
    mysqli_close($conn);
}
?>
