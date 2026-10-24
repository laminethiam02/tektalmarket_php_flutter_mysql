<?php
class Category {
    public ?int    $id = null;
    public ?string $categoryName = null;
    public ?string $icon = null;
    public ?string $createdAt = null;
    public ?string $updatedAt = null;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id           = isset($d['id']) ? (int)$d['id'] : null;
        $this->categoryName = $d['category_name'] ?? null;
        $this->icon         = $d['icon'] ?? null;
        $this->createdAt    = $d['created_at'] ?? null;
        $this->updatedAt    = $d['updated_at'] ?? null;
    }
}