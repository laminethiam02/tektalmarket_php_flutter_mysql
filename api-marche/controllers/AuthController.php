<?php
class AuthController {
    private AuthService $service;
    public function __construct() { $this->service = new AuthService(); }

    public function register(): void {
        try {
            $data = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            $dto = new UserDTO();
            $dto->nom                   = trim($data['nom'] ?? '');
            $dto->email                 = trim($data['email'] ?? '');
            $dto->telephone             = trim($data['telephone'] ?? '');
            $dto->ville                 = trim($data['ville'] ?? '');
            $dto->bio                   = $data['bio'] ?? null;
            $dto->role                  = $data['role'] ?? 'acheteur';
            $dto->nomMagasin            = $data['nomMagasin'] ?? null;
            $dto->adresseEntreprise     = $data['adresseEntreprise'] ?? null;
            $dto->categorieEntreprise   = $data['categorieEntreprise'] ?? null;
            $dto->descriptionEntreprise = $data['descriptionEntreprise'] ?? null;
            $password = $data['password'] ?? '';

            if (!$dto->nom || !$dto->email || !$password || !$dto->telephone || !$dto->ville) {
                throw new Exception("Champs obligatoires manquants");
            }
            if (strlen($password) < 6) throw new Exception("Mot de passe : 6 caractères min.");

            http_response_code(201);
            echo json_encode($this->service->register($dto, $password));
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(['error'=>$e->getMessage()]);
        }
    }

    public function login(): void {
        try {
            $data = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            $email = trim($data['email'] ?? '');
            $password = $data['password'] ?? '';
            if (!$email || !$password) throw new Exception("Email et mot de passe requis");
            echo json_encode($this->service->login($email, $password));
        } catch (Exception $e) {
            http_response_code(401);
            echo json_encode(['error'=>$e->getMessage()]);
        }
    }

    public function me(): void {
        $payload = Auth::require();
        $u = (new UserRepository())->findById((int)$payload['sub']);
        if (!$u) { http_response_code(404); echo json_encode(['error'=>'Introuvable']); return; }
        echo json_encode($this->service->toDTO($u));
    }
}