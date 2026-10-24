<?php
class CategoryDTO
{
    public ?int    $id           = null;
    public ?string $categoryName = null;
    public ?string $icon         = null;
    public ?string $createdAt    = null;
    public ?string $updatedAt    = null;

    /** Depuis un tableau (POST/JSON) */
    public static function fromArray(array $data): self
    {
        $dto              = new self();
        $dto->id          = isset($data['id']) ? (int) $data['id'] : null;
        $dto->categoryName = isset($data['categoryName'])
            ? trim($data['categoryName'])
            : (isset($data['category_name']) ? trim($data['category_name']) : null);
        $dto->icon        = $data['icon'] ?? 'category';
        return $dto;
    }

    /** Vers un tableau (réponse JSON) */
    public function toArray(): array
    {
        return [
            'id'           => $this->id,
            'categoryName' => $this->categoryName,
            'icon'         => $this->icon,
            'createdAt'    => $this->createdAt,
            'updatedAt'    => $this->updatedAt,
        ];
    }
}