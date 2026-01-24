<?php
require_once '../config.php';

header("Content-Type: application/json");

// Vérifier méthode
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "status" => "error",
        "message" => "Méthode non autorisée. Utilisez POST."
    ]);
    exit;
}

// Lire JSON
$input = json_decode(file_get_contents("php://input"), true);

if (!$input || !isset($input['id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "L'ID du client est requis"
    ]);
    exit;
}

$conn = getConnection();
$id = intval($input['id']);

try {
    // Vérifier si le client existe
    $checkStmt = mysqli_prepare($conn, "SELECT id, nom FROM clients WHERE id = ?");
    mysqli_stmt_bind_param($checkStmt, "i", $id);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);

    if (mysqli_num_rows($checkResult) === 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Client non trouvé"
        ]);
        exit;
    }

    $client = mysqli_fetch_assoc($checkResult);

    // Vérifier si le client a des commandes
    $commandesStmt = mysqli_prepare($conn, "SELECT COUNT(*) as total FROM commandes WHERE client_id = ?");
    mysqli_stmt_bind_param($commandesStmt, "i", $id);
    mysqli_stmt_execute($commandesStmt);
    $commandesResult = mysqli_fetch_assoc(mysqli_stmt_get_result($commandesStmt));

    if ($commandesResult['total'] > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Impossible de supprimer ce client car il a des commandes associées"
        ]);
        exit;
    }

    // Supprimer le client
    $deleteStmt = mysqli_prepare($conn, "DELETE FROM clients WHERE id = ?");
    mysqli_stmt_bind_param($deleteStmt, "i", $id);

    if (mysqli_stmt_execute($deleteStmt)) {
        echo json_encode([
            "status" => "success",
            "message" => "Client supprimé avec succès",
            "data" => [
                "id" => $id,
                "nom" => $client['nom']
            ]
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Erreur lors de la suppression du client"
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur serveur: " . $e->getMessage()
    ]);
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($commandesStmt)) mysqli_stmt_close($commandesStmt);
    if (isset($deleteStmt)) mysqli_stmt_close($deleteStmt);
    mysqli_close($conn);
}
