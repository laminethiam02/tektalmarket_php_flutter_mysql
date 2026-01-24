<?php
// produits/delete.php
require_once '../config.php';

header("Content-Type: application/json");

// Vérification de la méthode
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Méthode non autorisée. Utilisez POST.']);
    exit;
}

// Récupérer les données JSON
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    echo json_encode(['status' => 'error', 'message' => 'Données JSON invalides']);
    exit;
}

// Vérifier l'ID
if (!isset($input['id'])) {
    echo json_encode(['status' => 'error', 'message' => "L'ID du produit est requis"]);
    exit;
}

$conn = getConnection();
$id = intval($input['id']);

try {
    // Vérifier si le produit existe
    $stmt = mysqli_prepare($conn, "SELECT id, nom FROM produits WHERE id = ?");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Produit non trouvé']);
        exit;
    }

    $produit = mysqli_fetch_assoc($result);

    // Vérifier si le produit est utilisé dans des commandes
    $stmtCmd = mysqli_prepare($conn, "SELECT COUNT(*) AS total FROM commande_items WHERE produit_id = ?");
    mysqli_stmt_bind_param($stmtCmd, "i", $id);
    mysqli_stmt_execute($stmtCmd);
    $cmdResult = mysqli_fetch_assoc(mysqli_stmt_get_result($stmtCmd));

    if ($cmdResult['total'] > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Impossible de supprimer ce produit car il est utilisé dans des commandes']);
        exit;
    }

    // Supprimer le produit
    $stmtDel = mysqli_prepare($conn, "DELETE FROM produits WHERE id = ?");
    mysqli_stmt_bind_param($stmtDel, "i", $id);

    if (mysqli_stmt_execute($stmtDel)) {
        echo json_encode([
            'status' => 'success',
            'message' => 'Produit supprimé avec succès',
            'data' => [
                'id' => $id,
                'nom' => $produit['nom']
            ]
        ]);
    } else {
        throw new Exception('Erreur lors de la suppression du produit');
    }

} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erreur: ' . $e->getMessage()]);
} finally {
    if (isset($stmt)) mysqli_stmt_close($stmt);
    if (isset($stmtCmd)) mysqli_stmt_close($stmtCmd);
    if (isset($stmtDel)) mysqli_stmt_close($stmtDel);
    mysqli_close($conn);
}
?>
