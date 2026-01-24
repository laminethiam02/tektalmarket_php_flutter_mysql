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

if (!$input || empty($input['nom']) || !isset($input['prix'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Nom et prix du produit sont requis"
    ]);
    exit;
}

$conn = getConnection();

$nom = $input['nom'];
$prix = floatval($input['prix']);
$stock = isset($input['stock']) ? intval($input['stock']) : 0;

// Validation
if ($prix <= 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Le prix doit être supérieur à 0"
    ]);
    exit;
}

if ($stock < 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Le stock ne peut pas être négatif"
    ]);
    exit;
}

try {
    // Vérifier si le produit existe déjà
    $checkStmt = mysqli_prepare($conn, "SELECT id FROM produits WHERE nom = ?");
    mysqli_stmt_bind_param($checkStmt, "s", $nom);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);

    if (mysqli_num_rows($checkResult) > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Un produit avec ce nom existe déjà"
        ]);
        exit;
    }

    // Insérer le produit
    $insertStmt = mysqli_prepare($conn, "INSERT INTO produits (nom, prix, stock) VALUES (?, ?, ?)");
    mysqli_stmt_bind_param($insertStmt, "sdi", $nom, $prix, $stock);

    if (mysqli_stmt_execute($insertStmt)) {
        $produitId = mysqli_insert_id($conn);

        // Récupérer le produit créé
        $selectStmt = mysqli_prepare($conn, "SELECT * FROM produits WHERE id = ?");
        mysqli_stmt_bind_param($selectStmt, "i", $produitId);
        mysqli_stmt_execute($selectStmt);
        $produit = mysqli_fetch_assoc(mysqli_stmt_get_result($selectStmt));

        echo json_encode([
            "status" => "success",
            "message" => "Produit ajouté avec succès",
            "data" => $produit
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Erreur lors de l'ajout du produit"
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur serveur: " . $e->getMessage()
    ]);
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($insertStmt)) mysqli_stmt_close($insertStmt);
    if (isset($selectStmt)) mysqli_stmt_close($selectStmt);
    mysqli_close($conn);
}
