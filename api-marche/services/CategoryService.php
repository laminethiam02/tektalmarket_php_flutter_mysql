<?php
class CategoryService {
    private CategoryRepository $repo;
    public function __construct() { $this->repo = new CategoryRepository(); }
    public function getAll(): array {
        return array_map(fn($c)=>$this->toArray($c), $this->repo->findAll());
    }
    public function getById(int $id): array {
        $c = $this->repo->findById($id);
        if (!$c) throw new Exception("Catégorie introuvable");
        return $this->toArray($c);
    }
    public function create(string $name, string $icon): array {
        $c = new Category(); $c->categoryName=$name; $c->icon=$icon;
        return $this->toArray($this->repo->save($c));
    }
    public function update(int $id, string $name, string $icon): array {
        $c = $this->repo->findById($id);
        if (!$c) throw new Exception("Catégorie introuvable");
        $c->categoryName=$name; $c->icon=$icon;
        return $this->toArray($this->repo->save($c));
    }
    public function delete(int $id): void { $this->repo->delete($id); }
    private function toArray(Category $c): array {
        return ['id'=>$c->id,'categoryName'=>$c->categoryName,'icon'=>$c->icon,
                'createdAt'=>$c->createdAt,'updatedAt'=>$c->updatedAt];
    }
}