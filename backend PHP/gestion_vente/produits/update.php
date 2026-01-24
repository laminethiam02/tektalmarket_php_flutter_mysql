<?php
// produits/update.php
require_once '../config.php';

header("Content-Type: application/json");

// Vérifier la méthode POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Méthode non autorisée. Utilisez POST.']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    echo json_encode(['status' => 'error', 'message' => 'Données JSON invalides']);
    exit;
}

// Validation des champs requis
if (empty($input['id']) || empty($input['nom']) || !isset($input['prix'])) {
    echo json_encode(['status' => 'error', 'message' => 'ID, nom et prix sont requis']);
    exit;
}

$conn = getConnection();

$id = intval($input['id']);
$nom = escapeData($conn, $input['nom']);
$prix = floatval($input['prix']);
$stock = isset($input['stock']) ? intval($input['stock']) : 0;

// Validation
if ($prix <= 0) {
    echo json_encode(['status' => 'error', 'message' => 'Le prix doit être supérieur à 0']);
    exit;
}

if ($stock < 0) {
    echo json_encode(['status' => 'error', 'message' => 'Le stock ne peut pas être négatif']);
    exit;
}

try {
    // Vérifier si le produit existe
    $checkQuery = "SELECT id FROM produits WHERE id = ?";
    $checkStmt = mysqli_prepare($conn, $checkQuery);
    mysqli_stmt_bind_param($checkStmt, "i", $id);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);

    if (mysqli_num_rows($checkResult) === 0) {
        echo json_encode(['status' => 'error', 'message' => 'Produit non trouvé']);
        exit;
    }

    // Vérifier si le nom existe déjà pour un autre produit
    $nameQuery = "SELECT id FROM produits WHERE nom = ? AND id != ?";
    $nameStmt = mysqli_prepare($conn, $nameQuery);
    mysqli_stmt_bind_param($nameStmt, "si", $nom, $id);
    mysqli_stmt_execute($nameStmt);
    $nameResult = mysqli_stmt_get_result($nameStmt);

    if (mysqli_num_rows($nameResult) > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Un produit avec ce nom existe déjà']);
        exit;
    }

    // Mettre à jour le produit
    $updateQuery = "UPDATE produits SET nom = ?, prix = ?, stock = ? WHERE id = ?";
    $updateStmt = mysqli_prepare($conn, $updateQuery);
    mysqli_stmt_bind_param($updateStmt, "sdii", $nom, $prix, $stock, $id);

    if (mysqli_stmt_execute($updateStmt)) {
        // Récupérer le produit mis à jour
        $selectQuery = "SELECT * FROM produits WHERE id = ?";
        $selectStmt = mysqli_prepare($conn, $selectQuery);
        mysqli_stmt_bind_param($selectStmt, "i", $id);
        mysqli_stmt_execute($selectStmt);
        $produit = mysqli_fetch_assoc(mysqli_stmt_get_result($selectStmt));

        echo json_encode(['status' => 'success', 'message' => 'Produit mis à jour avec succès', 'data' => $produit]);
    } else {
        throw new Exception('Erreur lors de la mise à jour du produit');
    }

} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erreur: ' . $e->getMessage()]);
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($nameStmt)) mysqli_stmt_close($nameStmt);
    if (isset($updateStmt)) mysqli_stmt_close($updateStmt);
    if (isset($selectStmt)) mysqli_stmt_close($selectStmt);
    mysqli_close($conn);
}
