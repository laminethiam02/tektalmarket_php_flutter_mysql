<?php
class User {
    public ?int    $id = null;
    public ?string $nom = null;
    public ?string $email = null;
    public ?string $password = null;
    public ?string $telephone = null;
    public ?string $ville = null;
    public ?string $userImage = null;
    public ?string $bio = null;
    public ?string $role = null;
    public ?string $nomMagasin = null;
    public ?string $adresseEntreprise = null;
    public ?string $categorieEntreprise = null;
    public ?string $descriptionEntreprise = null;
    public ?string $createdAt = null;
    public ?string $updatedAt = null;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id                   = isset($d['id']) ? (int)$d['id'] : null;
        $this->nom                  = $d['nom'] ?? null;
        $this->email                = $d['email'] ?? null;
        $this->password             = $d['password'] ?? null;
        $this->telephone            = $d['telephone'] ?? null;
        $this->ville                = $d['ville'] ?? null;
        $this->userImage            = $d['user_image'] ?? null;
        $this->bio                  = $d['bio'] ?? null;
        $this->role                 = $d['role'] ?? 'acheteur';
        $this->nomMagasin           = $d['nom_magasin'] ?? null;
        $this->adresseEntreprise    = $d['adresse_entreprise'] ?? null;
        $this->categorieEntreprise  = $d['categorie_entreprise'] ?? null;
        $this->descriptionEntreprise= $d['description_entreprise'] ?? null;
        $this->createdAt            = $d['created_at'] ?? null;
        $this->updatedAt            = $d['updated_at'] ?? null;
    }
}