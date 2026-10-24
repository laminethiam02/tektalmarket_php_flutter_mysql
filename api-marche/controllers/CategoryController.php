<?php
class CategoryController {
    private CategoryService $service;
    public function __construct() { $this->service = new CategoryService(); }

    public function getAll(): void { echo json_encode($this->service->getAll()); }

    public function getById(int $id): void {
        try { echo json_encode($this->service->getById($id)); }
        catch (Exception $e) { http_response_code(404); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function create(): void {
        try {
            Auth::require();
            $d = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            http_response_code(201);
            echo json_encode($this->service->create($d['categoryName'] ?? '', $d['icon'] ?? 'category'));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function update(int $id): void {
        try {
            Auth::require();
            $d = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            echo json_encode($this->service->update($id, $d['categoryName'] ?? '', $d['icon'] ?? 'category'));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function delete(int $id): void {
        try { Auth::require(); $this->service->delete($id); http_response_code(204); }
        catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
}