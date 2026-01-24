<?php
// commande_items/add.php
require_once '../config.php';

// Autoriser uniquement POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Méthode non autorisée. Utilisez POST.');
}

// Lire JSON
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    jsonResponse('error', 'Données JSON invalides');
}

// Champs requis
$error = validateRequired($input, ['commande_id', 'produit_id', 'quantite']);
if ($error) {
    jsonResponse('error', $error);
}

$conn = getConnection();

$commande_id = (int)$input['commande_id'];
$produit_id  = (int)$input['produit_id'];
$quantite    = (int)$input['quantite'];

if ($quantite <= 0) {
    jsonResponse('error', 'La quantité doit être supérieure à 0');
}

try {
    /** 1️⃣ Vérifier la commande */
    $sql = "SELECT id, statut FROM commandes WHERE id = ?";
    $stmtCommande = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtCommande, "i", $commande_id);
    mysqli_stmt_execute($stmtCommande);
    $resCommande = mysqli_stmt_get_result($stmtCommande);

    if (mysqli_num_rows($resCommande) === 0) {
        jsonResponse('error', 'Commande non trouvée');
    }

    $commande = mysqli_fetch_assoc($resCommande);

    if ($commande['statut'] !== 'en_attente') {
        jsonResponse('error', 'Commande non modifiable (' . $commande['statut'] . ')');
    }

    /** 2️⃣ Vérifier le produit */
    $sql = "SELECT id, nom, prix, stock FROM produits WHERE id = ?";
    $stmtProduit = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtProduit, "i", $produit_id);
    mysqli_stmt_execute($stmtProduit);
    $resProduit = mysqli_stmt_get_result($stmtProduit);

    if (mysqli_num_rows($resProduit) === 0) {
        jsonResponse('error', 'Produit non trouvé');
    }

    $produit = mysqli_fetch_assoc($resProduit);

    /** 3️⃣ Vérifier l'item existant */
    $sql = "SELECT id, quantite FROM commande_items WHERE commande_id = ? AND produit_id = ?";
    $stmtItem = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtItem, "ii", $commande_id, $produit_id);
    mysqli_stmt_execute($stmtItem);
    $resItem = mysqli_stmt_get_result($stmtItem);

    $quantiteAjoutee = $quantite;

    if (mysqli_num_rows($resItem) > 0) {
        // Item existe → ajouter la différence
        $item = mysqli_fetch_assoc($resItem);
        $nouvelleQuantite = $item['quantite'] + $quantite;

        if ($produit['stock'] < $quantite) {
            jsonResponse('error', "Stock insuffisant ({$produit['stock']})");
        }

        $sql = "UPDATE commande_items SET quantite = ? WHERE id = ?";
        $stmtUpdateItem = mysqli_prepare($conn, $sql);
        mysqli_stmt_bind_param($stmtUpdateItem, "ii", $nouvelleQuantite, $item['id']);
        mysqli_stmt_execute($stmtUpdateItem);

        $item_id = $item['id'];

    } else {
        // Nouvel item
        if ($produit['stock'] < $quantite) {
            jsonResponse('error', "Stock insuffisant ({$produit['stock']})");
        }

        $sql = "INSERT INTO commande_items (commande_id, produit_id, quantite, prix_unitaire)
                VALUES (?, ?, ?, ?)";
        $stmtInsert = mysqli_prepare($conn, $sql);
        mysqli_stmt_bind_param(
            $stmtInsert,
            "iiid",
            $commande_id,
            $produit_id,
            $quantite,
            $produit['prix']
        );
        mysqli_stmt_execute($stmtInsert);

        $item_id = mysqli_insert_id($conn);
    }

    /** 4️⃣ Mettre à jour le stock (différence uniquement) */
    $sql = "UPDATE produits SET stock = stock - ? WHERE id = ?";
    $stmtStock = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtStock, "ii", $quantiteAjoutee, $produit_id);
    mysqli_stmt_execute($stmtStock);

    /** 5️⃣ Mettre à jour le total commande */
    $sous_total = $produit['prix'] * $quantiteAjoutee;

    $sql = "UPDATE commandes SET total = total + ? WHERE id = ?";
    $stmtTotal = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtTotal, "di", $sous_total, $commande_id);
    mysqli_stmt_execute($stmtTotal);

    /** 6️⃣ Retourner l'item */
    $sql = "SELECT ci.*, p.nom AS produit_nom
            FROM commande_items ci
            JOIN produits p ON ci.produit_id = p.id
            WHERE ci.id = ?";
    $stmtSelect = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmtSelect, "i", $item_id);
    mysqli_stmt_execute($stmtSelect);

    $itemFinal = mysqli_fetch_assoc(mysqli_stmt_get_result($stmtSelect));

    jsonResponse('success', 'Item ajouté avec succès', $itemFinal);

} catch (Exception $e) {
    jsonResponse('error', $e->getMessage());
} finally {
    mysqli_close($conn);
}
