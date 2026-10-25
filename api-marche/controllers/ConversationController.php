<?php
class ConversationController {
    private ConversationService $service;
    public function __construct() { $this->service = new ConversationService(); }

    public function getAll(): void {
        try {
            $u = Auth::require();
            echo json_encode($this->service->getAll((int)$u['sub']));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function getById(int $id): void {
        try {
            $u = Auth::require();
            echo json_encode($this->service->getById($id, (int)$u['sub']));
        } catch (Exception $e) { http_response_code(404); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function create(): void {
        try {
            $u = Auth::require();
            $d = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            $productId = (int)($d['productId'] ?? 0);
            if (!$productId) throw new Exception("productId requis");
            http_response_code(201);
            echo json_encode($this->service->getOrCreate($productId, (int)$u['sub']));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
}