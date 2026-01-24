<?php
// commandes/create.php
require_once '../config.php';
// Pour la démo simple, on ignore le checkAuth
//$user = checkAuth();
$user = ['id' => 1]; // Simuler utilisateur connecté

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    jsonResponse('error', 'Données JSON invalides');
}

// Validation des champs requis
$error = validateRequired($input, ['client_id', 'items']);
if ($error) {
    jsonResponse('error', $error);
}

$conn = getConnection();
$client_id = intval($input['client_id']);
$user_id = $user['id'];
$statut = isset($input['statut']) ? escapeData($conn, $input['statut']) : 'en_attente';
$items = $input['items'];

if (!in_array($statut, ['en_attente', 'payee', 'annulee'])) {
    jsonResponse('error', 'Statut invalide');
}

if (!is_array($items) || empty($items)) {
    jsonResponse('error', 'La commande doit contenir au moins un produit');
}

try {
    mysqli_autocommit($conn, false); // Transaction

    // 1. Vérifier si le client existe
    $checkClientStmt = mysqli_prepare($conn, "SELECT id FROM clients WHERE id = ?");
    mysqli_stmt_bind_param($checkClientStmt, "i", $client_id);
    mysqli_stmt_execute($checkClientStmt);
    mysqli_stmt_store_result($checkClientStmt);
    if (mysqli_stmt_num_rows($checkClientStmt) === 0) {
        throw new Exception('Client non trouvé');
    }

    // 2. Créer la commande
    $commandeStmt = mysqli_prepare($conn, "INSERT INTO commandes (client_id, user_id, statut) VALUES (?, ?, ?)");
    mysqli_stmt_bind_param($commandeStmt, "iis", $client_id, $user_id, $statut);
    mysqli_stmt_execute($commandeStmt);
    $commande_id = mysqli_insert_id($conn);
    $total_commande = 0;

    // 3. Ajouter les items
    foreach ($items as $item) {
        $produit_id = intval($item['produit_id'] ?? 0);
        $quantite = intval($item['quantite'] ?? 0);
        if ($produit_id <= 0 || $quantite <= 0) {
            throw new Exception('Chaque item doit avoir un produit_id et une quantité > 0');
        }

        // Vérifier le produit et le stock
        $produitStmt = mysqli_prepare($conn, "SELECT id, nom, prix, stock FROM produits WHERE id = ? FOR UPDATE");
        mysqli_stmt_bind_param($produitStmt, "i", $produit_id);
        mysqli_stmt_execute($produitStmt);
        $produitResult = mysqli_stmt_get_result($produitStmt);
        $produit = mysqli_fetch_assoc($produitResult);
        if (!$produit) throw new Exception("Produit ID $produit_id non trouvé");
        if ($produit['stock'] < $quantite) throw new Exception("Stock insuffisant pour {$produit['nom']}");

        // Insérer l'item
        $sous_total = $produit['prix'] * $quantite;
        $total_commande += $sous_total;
        $itemStmt = mysqli_prepare($conn, "INSERT INTO commande_items (commande_id, produit_id, quantite, prix_unitaire) VALUES (?, ?, ?, ?)");
        mysqli_stmt_bind_param($itemStmt, "iiid", $commande_id, $produit_id, $quantite, $produit['prix']);
        mysqli_stmt_execute($itemStmt);

        // Mettre à jour le stock
        $newStock = $produit['stock'] - $quantite;
        $updateStockStmt = mysqli_prepare($conn, "UPDATE produits SET stock = ? WHERE id = ?");
        mysqli_stmt_bind_param($updateStockStmt, "ii", $newStock, $produit_id);
        mysqli_stmt_execute($updateStockStmt);

        // Libérer statements
        mysqli_stmt_close($produitStmt);
        mysqli_stmt_close($itemStmt);
        mysqli_stmt_close($updateStockStmt);
    }

    // 4. Mettre à jour total
    $updateTotalStmt = mysqli_prepare($conn, "UPDATE commandes SET total = ? WHERE id = ?");
    mysqli_stmt_bind_param($updateTotalStmt, "di", $total_commande, $commande_id);
    mysqli_stmt_execute($updateTotalStmt);

    mysqli_commit($conn);

    // Récupérer la commande complète
    $selectStmt = mysqli_prepare($conn, "SELECT c.*, cl.nom as client_nom, u.email as vendeur_email 
                                        FROM commandes c 
                                        JOIN clients cl ON c.client_id = cl.id 
                                        JOIN users u ON c.user_id = u.id 
                                        WHERE c.id = ?");
    mysqli_stmt_bind_param($selectStmt, "i", $commande_id);
    mysqli_stmt_execute($selectStmt);
    $commande = mysqli_fetch_assoc(mysqli_stmt_get_result($selectStmt));

    $itemsStmt = mysqli_prepare($conn, "SELECT ci.*, p.nom as produit_nom 
                                        FROM commande_items ci 
                                        JOIN produits p ON ci.produit_id = p.id 
                                        WHERE ci.commande_id = ?");
    mysqli_stmt_bind_param($itemsStmt, "i", $commande_id);
    mysqli_stmt_execute($itemsStmt);
    $itemsResult = mysqli_stmt_get_result($itemsStmt);
    $commande_items = [];
    while ($row = mysqli_fetch_assoc($itemsResult)) {
        $commande_items[] = $row;
    }

    jsonResponse('success', 'Commande créée avec succès', [
        'commande' => $commande,
        'items' => $commande_items,
        'total' => $total_commande
    ]);

} catch (Exception $e) {
    mysqli_rollback($conn);
    jsonResponse('error', 'Erreur: ' . $e->getMessage());
} finally {
    mysqli_autocommit($conn, true);
    $stmts = ['checkClientStmt','commandeStmt','selectStmt','itemsStmt','updateTotalStmt'];
    foreach ($stmts as $stmt) {
        if (isset($$stmt)) mysqli_stmt_close($$stmt);
    }
    mysqli_close($conn);
}
?>
