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

$stmt = mysqli_prepare(
    $conn,
    "SELECT id, email, password, role FROM users WHERE email = ?"
);
mysqli_stmt_bind_param($stmt, "s", $email);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) === 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Email ou mot de passe incorrect"
    ]);
    exit;
}

$user = mysqli_fetch_assoc($result);

// Comparaison simple
if ($password !== $user['password']) {
    echo json_encode([
        "status" => "error",
        "message" => "Email ou mot de passe incorrect"
    ]);
    exit;
}

// Succès
echo json_encode([
    "status" => "success",
    "message" => "Connexion réussie",
    "data" => [
        "id" => $user['id'],
        "email" => $user['email'],
        "role" => $user['role']
    ]
]);

mysqli_close($conn);
