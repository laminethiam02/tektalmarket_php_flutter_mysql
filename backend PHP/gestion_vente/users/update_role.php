<?php
// users/update_role.php
require_once '../config.php';
$user = checkAuth();

// Seuls les admins peuvent modifier les rôles
if ($user['role'] !== 'admin') {
    jsonResponse('error', 'Accès non autorisé. Rôle admin requis.');
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    jsonResponse('error', 'Données JSON invalides');
}

// Validation des champs requis
$error = validateRequired($input, ['id', 'role']);
if ($error) {
    jsonResponse('error', $error);
}

$conn = getConnection();
$id = intval($input['id']);
$role = escapeData($conn, $input['role']);

// Validation du rôle
if (!in_array($role, ['admin', 'vendeur'])) {
    jsonResponse('error', 'Rôle invalide. Utilisez "admin" ou "vendeur"');
}

// Empêcher de modifier son propre rôle
if ($id === $user['id']) {
    jsonResponse('error', 'Vous ne pouvez pas modifier votre propre rôle');
}

try {
    // Vérifier si l'utilisateur existe
    $checkQuery = "SELECT id, email FROM users WHERE id = ?";
    $checkStmt = mysqli_prepare($conn, $checkQuery);
    mysqli_stmt_bind_param($checkStmt, "i", $id);
    mysqli_stmt_execute($checkStmt);
    $checkResult = mysqli_stmt_get_result($checkStmt);
    
    if (mysqli_num_rows($checkResult) === 0) {
        jsonResponse('error', 'Utilisateur non trouvé');
    }
    
    $targetUser = mysqli_fetch_assoc($checkResult);
    
    // Mettre à jour le rôle
    $updateQuery = "UPDATE users SET role = ? WHERE id = ?";
    $updateStmt = mysqli_prepare($conn, $updateQuery);
    mysqli_stmt_bind_param($updateStmt, "si", $role, $id);
    
    if (mysqli_stmt_execute($updateStmt)) {
        jsonResponse('success', 'Rôle mis à jour avec succès', [
            'id' => $id,
            'email' => $targetUser['email'],
            'ancien_utilisateur' => $user['email'],
            'nouveau_role' => $role
        ]);
    } else {
        throw new Exception('Erreur lors de la mise à jour du rôle');
    }
    
} catch (Exception $e) {
    jsonResponse('error', 'Erreur: ' . $e->getMessage());
} finally {
    if (isset($checkStmt)) mysqli_stmt_close($checkStmt);
    if (isset($updateStmt)) mysqli_stmt_close($updateStmt);
    mysqli_close($conn);
}
?>