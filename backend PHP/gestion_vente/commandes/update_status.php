<?php
// commandes/update_status.php
require_once '../config.php';

// ❌ SUPPRIMÉ : checkAuth()

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    jsonResponse('error', 'Données JSON invalides');
}

// Validation des champs requis
$error = validateRequired($input, ['id', 'statut']);
if ($error) {
    jsonResponse('error', $error);
}

$conn = getConnection();
$id = intval($input['id']);
$statut = escapeData($conn, $input['statut']);

// Validation du statut
$statuts_valides = ['en_attente', 'payee', 'annulee'];
if (!in_array($statut, $statuts_valides)) {
    jsonResponse('error', 'Statut invalide');
}

try {
    mysqli_autocommit($conn, false); // 🔒 Transaction

    // 1. Vérifier si la commande existe
    $checkQuery = "SELECT id, statut FROM commandes WHERE id = ?";
    $checkStmt = mysqli_prepare($conn, $checkQuery);
    mysqli_stmt_bind_param($checkStmt, "i", $id);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);

    if (mysqli_num_rows($checkResult) === 0) {
        throw new Exception('Commande non trouvée');
    }

    $commande = mysqli_fetch_assoc($checkResult);
    $ancien_statut = $commande['statut'];

    // 2. Si annulation → restaurer le stock
    if ($statut === 'annulee' && $ancien_statut !== 'annulee') {

        $itemsQuery = "SELECT produit_id, quantite 
                       FROM commande_items 
                       WHERE commande_id = ?";
        $itemsStmt = mysqli_prepare($conn, $itemsQuery);
        mysqli_stmt_bind_param($itemsStmt, "i", $id);
        mysqli_stmt_execute($itemsStmt);
        $itemsResult = mysqli_stmt_get_result($itemsStmt);

        while ($item = mysqli_fetch_assoc($itemsResult)) {
            $restoreQuery = "UPDATE produits 
                             SET stock = stock + ? 
                             WHERE id = ?";
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

    // 3. Mettre à jour le statut
    $updateQuery = "UPDATE commandes SET statut = ? WHERE id = ?";
    $updateStmt = mysqli_prepare($conn, $updateQuery);
    mysqli_stmt_bind_param($updateStmt, "si", $statut, $id);

    if (!mysqli_stmt_execute($updateStmt)) {
        throw new Exception('Erreur lors de la mise à jour du statut');
    }

    mysqli_commit($conn); // ✅ Valider transaction

    jsonResponse('success', 'Statut de la commande mis à jour avec succès', [
        'id' => $id,
        'ancien_statut' => $ancien_statut,
        'nouveau_statut' => $statut
    ]);

} catch (Exception $e) {
    mysqli_rollback($conn); // ❌ Annuler transaction
    jsonResponse('error', 'Erreur : ' . $e->getMessage());
} finally {
    mysqli_autocommit($conn, true);
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($updateStmt)) mysqli_stmt_close($updateStmt);
    mysqli_close($conn);
}
?>
