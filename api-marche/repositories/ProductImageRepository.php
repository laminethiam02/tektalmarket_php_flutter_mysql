<?php
class ProductImageRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function findByProductId(int $productId): array {
        $s = $this->db->prepare("SELECT * FROM product_images WHERE product_id=? ORDER BY sort_order ASC, id ASC");
        $s->execute([$productId]);
        return array_map(fn($r) => new ProductImage($r), $s->fetchAll());
    }
    public function save(int $productId, string $path, int $sort): void {
        $s = $this->db->prepare("INSERT INTO product_images (product_id,image_path,sort_order) VALUES (?,?,?)");
        $s->execute([$productId,$path,$sort]);
    }
    public function deleteByProductId(int $productId): void {
        $s = $this->db->prepare("DELETE FROM product_images WHERE product_id=?");
        $s->execute([$productId]);
    }
}