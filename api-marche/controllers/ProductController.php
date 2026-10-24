<?php
class ProductController {
    private ProductService $service;
    public function __construct() { $this->service = new ProductService(); }

    private function buildDTO(): ProductDTO {
        $d = new ProductDTO();
        $d->productTitle       = $_POST['productTitle']       ?? null;
        $d->productDescription = $_POST['productDescription'] ?? null;
        $d->productPrice       = isset($_POST['productPrice']) ? (float)$_POST['productPrice'] : null;
        $d->ville              = $_POST['ville']              ?? null;
        $d->categoryId         = isset($_POST['categoryId']) ? (int)$_POST['categoryId'] : null;
        if (isset($_POST['isActive'])) $d->isActive = filter_var($_POST['isActive'], FILTER_VALIDATE_BOOLEAN);
        return $d;
    }

    public function create(): void {
        try {
            $u = Auth::requireRole('vendeur');
            $dto = $this->buildDTO();
            $files = $_FILES['productImages'] ?? [];
            http_response_code(201);
            echo json_encode($this->service->create($dto, (int)$u['sub'], $files));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function update(int $id): void {
        try {
            $u = Auth::requireRole('vendeur');
            $dto = $this->buildDTO();
            $files = $_FILES['productImages'] ?? [];
            echo json_encode($this->service->update($id, $dto, (int)$u['sub'], $files));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function delete(int $id): void {
        try {
            $u = Auth::requireRole('vendeur');
            $this->service->delete($id, (int)$u['sub']);
            http_response_code(204);
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function getAll(): void { echo json_encode($this->service->getAll()); }
    public function getById(int $id): void {
        try { echo json_encode($this->service->getById($id)); }
        catch (Exception $e) { http_response_code(404); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function getByCategory(int $cid): void { echo json_encode($this->service->getByCategory($cid)); }
    public function getByUser(int $uid): void     { echo json_encode($this->service->getByUser($uid)); }
    public function search(): void {
        $kw = $_GET['keyword'] ?? '';
        echo json_encode($this->service->search($kw));
    }
}