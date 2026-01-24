<?php
// commandes/delete.php
require_once '../config.php';

// Autoriser uniquement POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

// Lire le JSON
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    jsonResponse('error', 'Données JSON invalides');
}

// Vérifier l'ID
if (!isset($input['id'])) {
    jsonResponse('error', 'ID de commande requis');
}

$conn = getConnection();
$id = intval($input['id']);

try {
    /** 1️⃣ Vérifier si la commande existe */
    $checkQuery = "SELECT id, statut FROM commandes WHERE id = ?";
    $checkStmt = mysqli_prepare($conn, $checkQuery);
    mysqli_stmt_bind_param($checkStmt, "i", $id);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);

    if (mysqli_num_rows($checkResult) === 0) {
        jsonResponse('error', 'Commande non trouvée');
    }

    // ✅ CORRECTION ICI
    $commande = mysqli_fetch_assoc($checkResult);

    /** 2️⃣ Interdire la suppression si payée */
    if ($commande['statut'] === 'payee') {
        jsonResponse('error', 'Impossible de supprimer une commande payée');
    }

    /** 3️⃣ Restaurer le stock si nécessaire */
    if ($commande['statut'] !== 'annulee') {
        $itemsQuery = "SELECT produit_id, quantite FROM commande_items WHERE commande_id = ?";
        $itemsStmt = mysqli_prepare($conn, $itemsQuery);
        mysqli_stmt_bind_param($itemsStmt, "i", $id);
        mysqli_stmt_execute($itemsStmt);
        $itemsResult = mysqli_stmt_get_result($itemsStmt);

        while ($item = mysqli_fetch_assoc($itemsResult)) {
            $restoreQuery = "UPDATE produits SET stock = stock + ? WHERE id = ?";
            $restoreStmt = mysqli_prepare($conn, $restoreQuery);
            mysqli_stmt_bind_param(
                $restoreStmt,
                "ii",
                $item['quantite'],
                $item['produit_id']
            );
            mysqli_stmt_execute($restoreStmt);
            mysqli_stmt_close($restoreStmt);
        }

        mysqli_stmt_close($itemsStmt);
    }

    /** 4️⃣ Supprimer la commande */
    $deleteQuery = "DELETE FROM commandes WHERE id = ?";
    $deleteStmt = mysqli_prepare($conn, $deleteQuery);
    mysqli_stmt_bind_param($deleteStmt, "i", $id);

    if (!mysqli_stmt_execute($deleteStmt)) {
        throw new Exception('Erreur lors de la suppression');
    }

    jsonResponse('success', 'Commande supprimée avec succès', [
        'id' => $id
    ]);

} catch (Exception $e) {
    jsonResponse('error', $e->getMessage());
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($deleteStmt)) mysqli_stmt_close($deleteStmt);
    mysqli_close($conn);
}
