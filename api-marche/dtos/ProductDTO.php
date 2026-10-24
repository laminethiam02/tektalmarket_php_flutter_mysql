<?php
class ProductDTO {
    public ?int    $id = null;
    public ?string $productTitle = null;
    public ?string $productDescription = null;
    public ?float  $productPrice = null;
    public ?string $ville = null;
    public ?string $productPhone = null;
    public ?int    $categoryId = null;
    public ?string $categoryName = null;
    public ?int    $userId = null;
    public ?string $productImage = null;
    public ?int    $durationDays = null;
    public ?string $expiresAt = null;
    public ?bool   $isActive = null;
    public ?string $createdAt = null;
    public ?string $updatedAt = null;
    /** @var string[] */
    public array $imagePaths = [];
    public ?string $sellerNom = null;
    public ?string $sellerImage = null;
    public ?string $sellerNomMagasin = null;
    public ?string $sellerVille = null;
    public ?string $sellerTelephone = null;
    public ?string $sellerMembreDepuis = null;
}