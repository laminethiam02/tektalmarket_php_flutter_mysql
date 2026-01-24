<?php
require_once 'config.php';

header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "status" => "error",
        "message" => "Méthode non autorisée"
    ]);
    exit;
}

$input = json_decode(file_get_contents("php://input"), true);

if (!$input || empty($input['email']) || empty($input['password'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Email et mot de passe requis"
    ]);
    exit;
}

$conn = getConnection();

$email = $input['email'];
$password = $input['password'];
$role = isset($input['role']) ? $input['role'] : 'vendeur';

// Vérifier rôle
if (!in_array($role, ['admin', 'vendeur'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Rôle invalide"
    ]);
    exit;
}

// Vérifier si email existe
$check = mysqli_prepare($conn, "SELECT id FROM users WHERE email = ?");
mysqli_stmt_bind_param($check, "s", $email);
mysqli_stmt_execute($check);
$result = mysqli_stmt_get_result($check);

if (mysqli_num_rows($result) > 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Email déjà utilisé"
    ]);
    exit;
}

// Insertion simple (mot de passe en clair)
$stmt = mysqli_prepare(
    $conn,
    "INSERT INTO users (email, password, role) VALUES (?, ?, ?)"
);
mysqli_stmt_bind_param($stmt, "sss", $email, $password, $role);

if (mysqli_stmt_execute($stmt)) {
    echo json_encode([
        "status" => "success",
        "message" => "Utilisateur créé avec succès",
        "data" => [
            "id" => mysqli_insert_id($conn),
            "email" => $email,
            "role" => $role
        ]
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Erreur lors de l'inscription"
    ]);
}

mysqli_close($conn);
