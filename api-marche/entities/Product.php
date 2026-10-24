<?php
class Product {
    public ?int    $id = null;
    public ?string $productTitle = null;
    public ?string $productDescription = null;
    public float   $productPrice = 0.0;
    public ?string $ville = null;
    public ?string $productPhone = null;
    public ?string $productImage = null;
    public ?int    $categoryId = null;
    public ?string $categoryName = null;   // transient
    public ?int    $userId = null;
    public int     $durationDays = 30;
    public ?string $expiresAt = null;
    public bool    $isActive = true;
    public ?string $createdAt = null;
    public ?string $updatedAt = null;

    // seller info (transient)
    public ?string $sellerNom = null;
    public ?string $sellerImage = null;
    public ?string $sellerNomMagasin = null;
    public ?string $sellerVille = null;
    public ?string $sellerTelephone = null;
    public ?string $sellerMembreDepuis = null;

    /** @var ProductImage[] */
    public array $images = [];
}