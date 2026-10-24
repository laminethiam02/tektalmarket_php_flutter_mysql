<?php
class AuthService {
    private UserRepository $repo;
    public function __construct() { $this->repo = new UserRepository(); }

    public function register(UserDTO $dto, string $password): array {
        if ($this->repo->existsByEmail($dto->email)) {
            throw new Exception("Un compte existe déjà avec cet email");
        }
        if (!in_array($dto->role, ['acheteur','vendeur'])) {
            throw new Exception("Rôle invalide");
        }
        $u = new User();
        $u->nom         = $dto->nom;
        $u->email       = $dto->email;
        $u->password    = password_hash($password, PASSWORD_BCRYPT);
        $u->telephone   = $dto->telephone;
        $u->ville       = $dto->ville;
        $u->role        = $dto->role;
        $u->bio         = $dto->bio;
        $u->nomMagasin          = $dto->role==='vendeur' ? $dto->nomMagasin : null;
        $u->adresseEntreprise   = $dto->role==='vendeur' ? $dto->adresseEntreprise : null;
        $u->categorieEntreprise = $dto->role==='vendeur' ? $dto->categorieEntreprise : null;
        $u->descriptionEntreprise = $dto->role==='vendeur' ? $dto->descriptionEntreprise : null;
        $u = $this->repo->save($u);
        return $this->buildAuthResponse($u);
    }

    public function login(string $email, string $password): array {
        $u = $this->repo->findByEmail($email);
        if (!$u || !password_verify($password, $u->password)) {
            throw new Exception("Email ou mot de passe incorrect");
        }
        return $this->buildAuthResponse($u);
    }

    public function buildAuthResponse(User $u): array {
        $token = Jwt::encode(['sub'=>$u->id,'email'=>$u->email,'role'=>$u->role]);
        return [
            'token' => $token,
            'user'  => $this->toDTO($u),
        ];
    }

    public function toDTO(User $u): array {
        return [
            'id'=>$u->id,'nom'=>$u->nom,'email'=>$u->email,'telephone'=>$u->telephone,
            'ville'=>$u->ville,'userImage'=>$u->userImage,'bio'=>$u->bio,'role'=>$u->role,
            'nomMagasin'=>$u->nomMagasin,'adresseEntreprise'=>$u->adresseEntreprise,
            'categorieEntreprise'=>$u->categorieEntreprise,'descriptionEntreprise'=>$u->descriptionEntreprise,
            'createdAt'=>$u->createdAt,'updatedAt'=>$u->updatedAt,
        ];
    }
}