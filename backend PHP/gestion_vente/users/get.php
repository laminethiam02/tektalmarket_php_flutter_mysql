<?php
// users/get.php
require_once '../config.php';
$user = checkAuth();

// Seuls les admins peuvent voir la liste des utilisateurs
if ($user['role'] !== 'admin') {
    jsonResponse('error', 'Accès non autorisé. Rôle admin requis.');
}

$conn = getConnection();

try {
    $query = "SELECT id, email, role, created_at, last_login FROM users ORDER BY created_at DESC";
    $result = mysqli_query($conn, $query);
    
    $users = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $users[] = $row;
    }
    
    jsonResponse('success', 'Utilisateurs récupérés avec succès', $users);
    
} catch (Exception $e) {
    jsonResponse('error', 'Erreur: ' . $e->getMessage());
} finally {
    mysqli_close($conn);
}
?>