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

// Lire le JSON
$input = json_decode(file_get_contents("php://input"), true);

if (!$input || empty($input['id']) || empty($input['nom'])) {
    echo json_encode([
        "status" => "error",
        "message" => "ID et nom du client sont obligatoires"
    ]);
    exit;
}

$conn = getConnection();

$id = intval($input['id']);
$nom = $input['nom'];
$telephone = isset($input['telephone']) ? $input['telephone'] : null;
$adresse = isset($input['adresse']) ? $input['adresse'] : null;

try {
    // Vérifier si le client existe
    $checkStmt = mysqli_prepare($conn, "SELECT id FROM clients WHERE id = ?");
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

    // Vérifier téléphone unique
    if ($telephone) {
        $phoneStmt = mysqli_prepare($conn, "SELECT id FROM clients WHERE telephone = ? AND id != ?");
        mysqli_stmt_bind_param($phoneStmt, "si", $telephone, $id);
        mysqli_stmt_execute($phoneStmt);
        $phoneResult = mysqli_stmt_get_result($phoneStmt);

        if (mysqli_num_rows($phoneResult) > 0) {
            echo json_encode([
                "status" => "error",
                "message" => "Ce numéro de téléphone est déjà utilisé par un autre client"
            ]);
            exit;
        }
    }

    // Mise à jour
    $updateStmt = mysqli_prepare($conn, "UPDATE clients SET nom = ?, telephone = ?, adresse = ? WHERE id = ?");
    mysqli_stmt_bind_param($updateStmt, "sssi", $nom, $telephone, $adresse, $id);

    if (mysqli_stmt_execute($updateStmt)) {
        // Récupérer le client mis à jour
        $selectStmt = mysqli_prepare($conn, "SELECT * FROM clients WHERE id = ?");
        mysqli_stmt_bind_param($selectStmt, "i", $id);
        mysqli_stmt_execute($selectStmt);
        $client = mysqli_fetch_assoc(mysqli_stmt_get_result($selectStmt));

        echo json_encode([
            "status" => "success",
            "message" => "Client mis à jour avec succès",
            "data" => $client
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Erreur lors de la mise à jour du client"
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur serveur: " . $e->getMessage()
    ]);
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($phoneStmt)) mysqli_stmt_close($phoneStmt);
    if (isset($updateStmt)) mysqli_stmt_close($updateStmt);
    if (isset($selectStmt)) mysqli_stmt_close($selectStmt);
    mysqli_close($conn);
}
