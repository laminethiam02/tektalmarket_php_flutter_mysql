<?php
// commandes/get_by_id.php
require_once '../config.php';

// ❌ SUPPRIMÉ : checkAuth()

if (!isset($_GET['id'])) {
    jsonResponse('error', 'ID de commande requis');
}

$conn = getConnection();
$id = intval($_GET['id']);

try {
    // 1. Récupérer la commande
    $query = "SELECT c.*, 
                     cl.nom AS client_nom,
                     cl.telephone AS client_telephone,
                     cl.adresse AS client_adresse,
                     u.email AS vendeur_email
              FROM commandes c
              JOIN clients cl ON c.client_id = cl.id
              JOIN users u ON c.user_id = u.id
              WHERE c.id = ?";

    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) === 0) {
        jsonResponse('error', 'Commande non trouvée');
    }

    // ✅ CORRECT
    $commande = mysqli_fetch_assoc($result);

    // 2. Récupérer les items de la commande
    $itemsQuery = "SELECT ci.*, 
                          p.nom AS produit_nom,
                          p.prix AS prix_actuel
                   FROM commande_items ci
                   JOIN produits p ON ci.produit_id = p.id
                   WHERE ci.commande_id = ?";

    $itemsStmt = mysqli_prepare($conn, $itemsQuery);
    mysqli_stmt_bind_param($itemsStmt, "i", $id);
    mysqli_stmt_execute($itemsStmt);
    $itemsResult = mysqli_stmt_get_result($itemsStmt);

    $items = [];
    $total_commande = 0;

    while ($item = mysqli_fetch_assoc($itemsResult)) {
        $items[] = $item;
        $total_commande += $item['prix_unitaire'] * $item['quantite'];
    }

    // 3. Réponse finale
    jsonResponse('success', 'Commande récupérée avec succès', [
        'commande' => $commande,
        'items' => $items,
        'total' => $total_commande
    ]);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    if (isset($stmt)) mysqli_stmt_close($stmt);
    if (isset($itemsStmt)) mysqli_stmt_close($itemsStmt);
    mysqli_close($conn);
}
?>
