<?php
class UserService {
    private UserRepository $repo;
    private string $uploadDir;

    public function __construct() {
        $this->repo = new UserRepository();
        $this->uploadDir = __DIR__ . '/../uploads/users/';
    }

    public function getById(int $id): array {
        $u = $this->repo->findById($id);
        if (!$u) throw new Exception("Utilisateur introuvable");
        return $this->toPublicDTO($u);
    }

    public function updateProfile(int $id, UserDTO $dto, ?array $image): array {
        $u = $this->repo->findById($id);
        if (!$u) throw new Exception("Utilisateur introuvable");

        if ($dto->nom !== null) $u->nom = $dto->nom;
        if ($dto->telephone !== null) $u->telephone = $dto->telephone;
        if ($dto->ville !== null) $u->ville = $dto->ville;
        if ($dto->bio !== null) $u->bio = $dto->bio;
        if ($dto->nomMagasin !== null) $u->nomMagasin = $dto->nomMagasin;
        if ($dto->adresseEntreprise !== null) $u->adresseEntreprise = $dto->adresseEntreprise;
        if ($dto->categorieEntreprise !== null) $u->categorieEntreprise = $dto->categorieEntreprise;
        if ($dto->descriptionEntreprise !== null) $u->descriptionEntreprise = $dto->descriptionEntreprise;

        if ($image && $image['error'] === UPLOAD_ERR_OK) {
            $u->userImage = $this->saveImage($image);
        }
        $u = $this->repo->save($u);
        return (new AuthService())->toDTO($u);
    }

    private function saveImage(array $file): string {
        if (!is_dir($this->uploadDir)) mkdir($this->uploadDir, 0777, true);
        $name = uniqid('', true) . '_' . preg_replace('/[^a-zA-Z0-9._-]/','_', basename($file['name']));
        if (!move_uploaded_file($file['tmp_name'], $this->uploadDir.$name)) {
            throw new Exception("Erreur upload image");
        }
        return '/uploads/users/' . $name;
    }

    private function toPublicDTO(User $u): array {
        return [
            'id'=>$u->id,'nom'=>$u->nom,'ville'=>$u->ville,'userImage'=>$u->userImage,
            'bio'=>$u->bio,'role'=>$u->role,'nomMagasin'=>$u->nomMagasin,
            'adresseEntreprise'=>$u->adresseEntreprise,
            'categorieEntreprise'=>$u->categorieEntreprise,
            'descriptionEntreprise'=>$u->descriptionEntreprise,
            'telephone'=>$u->telephone,'createdAt'=>$u->createdAt,
        ];
    }
}