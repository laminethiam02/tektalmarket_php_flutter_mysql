-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 24 jan. 2026 à 11:50
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `gestion_vente`
--

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `clients`
--

INSERT INTO `clients` (`id`, `nom`, `telephone`, `adresse`, `created_at`) VALUES
(2, 'Awa Ndiaye', '778899001', 'Thiès', '2026-01-11 15:01:49'),
(3, 'khady THIAM', '774659878', 'Mboro', '2026-01-11 18:29:27'),
(4, 'Samba Ndiaye', '775460967', 'Mbour', '2026-01-11 18:57:24'),
(5, 'Lamine THIAM', '776560978', 'Darou khoudoss', '2026-01-11 19:27:40'),
(6, 'Adama Faye', '785649867', 'Mboro', '2026-01-12 14:47:49');

-- --------------------------------------------------------

--
-- Structure de la table `commandes`
--

CREATE TABLE `commandes` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date_commande` datetime DEFAULT current_timestamp(),
  `total` decimal(10,2) DEFAULT 0.00,
  `statut` enum('en_attente','payee','annulee') DEFAULT 'en_attente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commandes`
--

INSERT INTO `commandes` (`id`, `client_id`, `user_id`, `date_commande`, `total`, `statut`) VALUES
(2, 2, 1, '2026-01-11 16:49:27', 60000.00, 'payee'),
(3, 3, 1, '2026-01-11 20:05:27', 353.00, 'en_attente'),
(4, 4, 1, '2026-01-11 20:26:52', 354.98, 'en_attente'),
(5, 5, 1, '2026-01-11 20:28:54', 376.98, 'en_attente'),
(6, 6, 1, '2026-01-12 16:21:05', 2172.32, 'en_attente'),
(7, 4, 1, '2026-01-12 16:28:58', 1884.90, 'annulee'),
(8, 4, 1, '2026-01-14 11:47:17', 1507.92, 'en_attente');

-- --------------------------------------------------------

--
-- Structure de la table `commande_items`
--

CREATE TABLE `commande_items` (
  `id` int(11) NOT NULL,
  `commande_id` int(11) NOT NULL,
  `produit_id` int(11) NOT NULL,
  `quantite` int(11) NOT NULL,
  `prix_unitaire` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commande_items`
--

INSERT INTO `commande_items` (`id`, `commande_id`, `produit_id`, `quantite`, `prix_unitaire`) VALUES
(2, 2, 2, 3, 15000.00),
(3, 2, 2, 1, 15000.00),
(4, 3, 7, 1, 353.00),
(5, 4, 11, 1, 354.98),
(6, 5, 13, 1, 376.98),
(7, 6, 17, 4, 543.08),
(8, 7, 13, 5, 376.98),
(9, 8, 13, 4, 376.98);

-- --------------------------------------------------------

--
-- Structure de la table `produits`
--

CREATE TABLE `produits` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prix` decimal(10,2) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produits`
--

INSERT INTO `produits` (`id`, `nom`, `prix`, `stock`, `created_at`) VALUES
(1, 'Farine 10kg', 9000.00, 30, '2026-01-11 09:00:00'),
(2, 'Huile végétale 5L', 15000.00, 16, '2026-01-11 09:00:00'),
(3, 'Sucre 5kg', 8000.00, 15, '2026-01-11 09:00:00'),
(4, 'Farine 5kg', 5000.00, 50, '2026-01-11 15:23:01'),
(6, 'Mil 5kg', 1500.00, 78, '2026-01-11 15:28:00'),
(7, 'Bonbon', 353.00, 4, '2026-01-11 18:58:14'),
(8, 'Tangal menthe', 250.00, 10, '2026-01-11 19:12:25'),
(9, 'HSjssjss', 363.00, 35, '2026-01-11 19:18:29'),
(10, 'Yonbon', 253.78, 2, '2026-01-11 19:24:08'),
(11, 'Hongou', 354.98, 3, '2026-01-11 19:25:15'),
(12, 'Morhion', 376.87, 5, '2026-01-11 19:26:03'),
(13, 'Orange', 376.98, 2, '2026-01-11 19:28:03'),
(14, 'Banana', 345.89, 50, '2026-01-12 14:56:45'),
(15, 'Tonpou', 243.08, 7, '2026-01-12 15:03:57'),
(16, 'Goulon', 237.08, 15, '2026-01-12 15:06:15'),
(17, 'Joipli', 543.08, 3, '2026-01-12 15:12:27');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','vendeur') DEFAULT 'vendeur',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'admin@test.com', '123456', 'admin', '2026-01-11 09:00:00'),
(2, 'test@example.com', '123456', 'vendeur', '2026-01-11 14:25:09'),
(3, 'lamine@gmail.com', '123456', 'vendeur', '2026-01-11 14:37:33'),
(4, 'fatou@gmail.com', '123456', 'vendeur', '2026-01-11 14:47:05'),
(5, 'maguette@gmail.com', '123456', 'admin', '2026-01-12 12:39:44');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `telephone` (`telephone`);

--
-- Index pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_commande_client` (`client_id`),
  ADD KEY `fk_commande_user` (`user_id`);

--
-- Index pour la table `commande_items`
--
ALTER TABLE `commande_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_item_commande` (`commande_id`),
  ADD KEY `fk_item_produit` (`produit_id`);

--
-- Index pour la table `produits`
--
ALTER TABLE `produits`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `commandes`
--
ALTER TABLE `commandes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `commande_items`
--
ALTER TABLE `commande_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `produits`
--
ALTER TABLE `produits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD CONSTRAINT `fk_commande_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_commande_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `commande_items`
--
ALTER TABLE `commande_items`
  ADD CONSTRAINT `fk_item_commande` FOREIGN KEY (`commande_id`) REFERENCES `commandes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_item_produit` FOREIGN KEY (`produit_id`) REFERENCES `produits` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
