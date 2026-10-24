CREATE DATABASE IF NOT EXISTS api_marche CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE api_marche;

-- USERS (acheteur / vendeur)
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  telephone VARCHAR(30) NOT NULL,
  ville VARCHAR(100) NOT NULL,
  user_image VARCHAR(255) DEFAULT NULL,
  bio TEXT DEFAULT NULL,
  role ENUM('acheteur','vendeur') NOT NULL DEFAULT 'acheteur',
  nom_magasin VARCHAR(150) DEFAULT NULL,
  adresse_entreprise VARCHAR(255) DEFAULT NULL,
  categorie_entreprise VARCHAR(120) DEFAULT NULL,
  description_entreprise TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- CATEGORIES (avec icône)
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  icon VARCHAR(60) NOT NULL DEFAULT 'category',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- PRODUCTS (annonce)
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_title VARCHAR(180) NOT NULL,
  product_description TEXT DEFAULT NULL,
  product_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  ville VARCHAR(100) NOT NULL,
  product_phone VARCHAR(30) NOT NULL,
  product_image VARCHAR(255) DEFAULT NULL,     -- image principale
  category_id INT DEFAULT NULL,
  user_id INT NOT NULL,                        -- vendeur
  duration_days INT NOT NULL DEFAULT 30,       -- durée AUTO de l'annonce
  expires_at DATETIME NOT NULL,                -- calculé automatiquement
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- PRODUCT_IMAGES (jusqu'à 5 photos/annonce)
CREATE TABLE product_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  image_path VARCHAR(255) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- SEED categories
INSERT INTO categories (category_name, icon) VALUES
('Vehicules', 'directions_car'),
('Electronique', 'smartphone'),
('Mode & Beauté', 'checkroom'),
('Immobilier', 'home_work'),
('Electromenager', 'kitchen'),
('Alimentation', 'restaurant');