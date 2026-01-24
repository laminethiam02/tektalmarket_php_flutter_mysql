<?php
// commande_items/delete.php
require_once '../config.php';

// ❌ suppression de l'authentification
// $user = checkAuth();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

$input = json_decode(file_get_contents('php://input'), true);

if (!is_array($input)) {
    jsonResponse('error', 'Données JSON invalides');
}

if (!isset($input['id']) || intval($input['id']) <= 0) {
    jsonResponse('error', 'ID de l\'item invalide');
}

$conn = getConnection();
$id = intval($input['id']);

try {
    // Récupérer l'item avec la commande et le produit
    $query = "
        SELECT 
            ci.id,
            ci.commande_id,
            ci.produit_id,
            ci.quantite,
            ci.prix_unitaire,
            c.statut AS commande_statut,
            p.nom AS produit_nom
        FROM commande_items ci
        JOIN commandes c ON ci.commande_id = c.id
        JOIN produits p ON ci.produit_id = p.id
        WHERE ci.id = ?
    ";

    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) === 0) {
        jsonResponse('error', 'Item non trouvé');
    }

    $item = mysqli_fetch_assoc($result);

    // Vérifier le statut de la commande
    if ($item['commande_statut'] !== 'en_attente') {
        jsonResponse(
            'error',
            "Suppression impossible : commande {$item['commande_statut']}"
        );
    }

    // Restaurer le stock
    $restoreQuery = "UPDATE produits SET stock = stock + ? WHERE id = ?";
    $restoreStmt = mysqli_prepare($conn, $restoreQuery);
    mysqli_stmt_bind_param(
        $restoreStmt,
        "ii",
        $item['quantite'],
        $item['produit_id']
    );

    if (!mysqli_stmt_execute($restoreStmt)) {
        throw new Exception('Erreur lors de la restauration du stock');
    }

    // Mettre à jour le total de la commande
    $sous_total = $item['prix_unitaire'] * $item['quantite'];
    $updateTotalQuery = "UPDATE commandes SET total = total - ? WHERE id = ?";
    $updateTotalStmt = mysqli_prepare($conn, $updateTotalQuery);
    mysqli_stmt_bind_param(
        $updateTotalStmt,
        "di",
        $sous_total,
        $item['commande_id']
    );

    if (!mysqli_stmt_execute($updateTotalStmt)) {
        throw new Exception('Erreur lors de la mise à jour du total');
    }

    // Supprimer l'item
    $deleteQuery = "DELETE FROM commande_items WHERE id = ?";
    $deleteStmt = mysqli_prepare($conn, $deleteQuery);
    mysqli_stmt_bind_param($deleteStmt, "i", $id);

    if (!mysqli_stmt_execute($deleteStmt)) {
        throw new Exception('Erreur lors de la suppression de l\'item');
    }

    jsonResponse('success', 'Item supprimé avec succès', [
        'item_id' => $id,
        'produit' => $item['produit_nom'],
        'quantite' => $item['quantite'],
        'commande_id' => $item['commande_id']
    ]);

} catch (Exception $e) {
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    if (isset($stmt)) mysqli_stmt_close($stmt);
    if (isset($restoreStmt)) mysqli_stmt_close($restoreStmt);
    if (isset($updateTotalStmt)) mysqli_stmt_close($updateTotalStmt);
    if (isset($deleteStmt)) mysqli_stmt_close($deleteStmt);
    mysqli_close($conn);
}
?>
