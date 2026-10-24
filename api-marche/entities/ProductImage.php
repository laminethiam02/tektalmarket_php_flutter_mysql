<?php
class ProductImage {
    public ?int    $id = null;
    public ?int    $productId = null;
    public ?string $imagePath = null;
    public int     $sortOrder = 0;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id        = isset($d['id']) ? (int)$d['id'] : null;
        $this->productId = isset($d['product_id']) ? (int)$d['product_id'] : null;
        $this->imagePath = $d['image_path'] ?? null;
        $this->sortOrder = isset($d['sort_order']) ? (int)$d['sort_order'] : 0;
    }
}