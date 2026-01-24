<?php
// logout.php
require_once 'config.php';

// Dans une application réelle, on invaliderait le token côté serveur
// Pour cette version simplifiée, on retourne simplement un succès

jsonResponse('success', 'Déconnexion réussie', [
    'note' => 'Dans une application réelle, le token serait invalidé côté serveur'
]);
?>