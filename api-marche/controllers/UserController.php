<?php
class UserController {
    private UserService $service;
    public function __construct() { $this->service = new UserService(); }

    public function getPublicProfile(int $id): void {
        try { echo json_encode($this->service->getById($id)); }
        catch (Exception $e) { http_response_code(404); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function updateProfile(): void {
        try {
            $payload = Auth::require();
            $dto = new UserDTO();
            foreach (['nom','telephone','ville','bio','nomMagasin','adresseEntreprise','categorieEntreprise','descriptionEntreprise'] as $f) {
                if (isset($_POST[$f])) $dto->$f = $_POST[$f];
            }
            $image = $_FILES['userImage'] ?? null;
            echo json_encode($this->service->updateProfile((int)$payload['sub'], $dto, $image));
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(['error'=>$e->getMessage()]);
        }
    }
}