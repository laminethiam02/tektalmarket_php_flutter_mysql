<?php
require_once '../config.php';

header("Content-Type: application/json");

// Vérifier méthode
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "status" => "error",
        "message" => "Méthode non autorisée"
    ]);
    exit;
}

// Lire le JSON
$input = json_decode(file_get_contents("php://input"), true);

if (!$input || empty($input['nom'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Le nom du client est obligatoire"
    ]);
    exit;
}

$conn = getConnection();

$nom = $input['nom'];
$telephone = isset($input['telephone']) ? $input['telephone'] : null;
$adresse = isset($input['adresse']) ? $input['adresse'] : null;

// Vérifier téléphone unique
if ($telephone) {
    $check = mysqli_prepare($conn, "SELECT id FROM clients WHERE telephone = ?");
    mysqli_stmt_bind_param($check, "s", $telephone);
    mysqli_stmt_execute($check);
    $res = mysqli_stmt_get_result($check);

    if (mysqli_num_rows($res) > 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Ce numéro de téléphone est déjà utilisé"
        ]);
        exit;
    }
}

// Insertion simple
$stmt = mysqli_prepare(
    $conn,
    "INSERT INTO clients (nom, telephone, adresse) VALUES (?, ?, ?)"
);
mysqli_stmt_bind_param($stmt, "sss", $nom, $telephone, $adresse);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode([
        "status" => "success",
        "message" => "Client ajouté avec succès",
        "data" => [
            "id" => mysqli_insert_id($conn),
            "nom" => $nom,
            "telephone" => $telephone,
            "adresse" => $adresse
        ]
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur lors de l'ajout du client"
    ]);
}

mysqli_close($conn);
