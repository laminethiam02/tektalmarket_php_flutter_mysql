<?php
// config.php - Configuration principale
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json');

// Gestion des requêtes OPTIONS pour CORS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'gestion_vente');

// Clé secrète pour les tokens JWT (à changer en production)
define('JWT_SECRET', 'votre_cle_secrete_ici');

// Fonction de connexion à la base de données
function getConnection() {
    $conn = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if (!$conn) {
        http_response_code(500);
        echo json_encode([
            "status" => "error",
            "message" => "Connexion à la base de données échouée: " . mysqli_connect_error()
        ]);
        exit();
    }
    
    mysqli_set_charset($conn, "utf8mb4");
    return $conn;
}

// Fonction pour vérifier l'authentification (simplifiée)
function checkAuth() {
    $headers = getallheaders();
    
    if (!isset($headers['Authorization']) && !isset($headers['authorization'])) {
        http_response_code(401);
        echo json_encode([
            "status" => "error",
            "message" => "Token d'authentification manquant"
        ]);
        exit();
    }
    
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : $headers['authorization'];
    
    // Format: "Bearer {token}"
    $token = str_replace('Bearer ', '', $authHeader);
    
    if (empty($token)) {
        http_response_code(401);
        echo json_encode([
            "status" => "error",
            "message" => "Token invalide"
        ]);
        exit();
    }
    
    // Dans une application réelle, vérifier le token JWT
    // Pour simplifier, on vérifie juste si l'utilisateur existe
    return validateToken($token);
}

// Fonction pour valider le token (simplifiée)
function validateToken($token) {
    $conn = getConnection();
    
    // Récupérer l'utilisateur basé sur le token (simulé)
    $userId = intval($token); // Pour simplifier, le token est l'ID utilisateur
    
    $query = "SELECT id, email, role FROM users WHERE id = ?";
    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "i", $userId);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    
    if (mysqli_num_rows($result) == 1) {
        $user = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);
        mysqli_close($conn);
        return $user;
    }
    
    mysqli_stmt_close($stmt);
    mysqli_close($conn);
    
    http_response_code(401);
    echo json_encode([
        "status" => "error",
        "message" => "Token invalide ou expiré"
    ]);
    exit();
}

// Fonction pour générer une réponse JSON
function jsonResponse($status, $message, $data = null) {
    $response = [
        "status" => $status,
        "message" => $message
    ];
    
    if ($data !== null) {
        $response["data"] = $data;
    }
    
    echo json_encode($response);
    exit();
}

// Fonction pour échapper les données
function escapeData($conn, $data) {
    if (is_array($data)) {
        foreach ($data as $key => $value) {
            $data[$key] = mysqli_real_escape_string($conn, trim($value));
        }
        return $data;
    }
    return mysqli_real_escape_string($conn, trim($data));
}

// Fonction pour valider les données requises
function validateRequired($data, $requiredFields) {
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            return "Le champ '$field' est requis";
        }
    }
    return null;
}
?>