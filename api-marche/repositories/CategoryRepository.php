<?php
class CategoryRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function findAll(): array {
        $s = $this->db->query("SELECT * FROM categories ORDER BY category_name ASC");
        return array_map(fn($r) => new Category($r), $s->fetchAll());
    }
    public function findById(int $id): ?Category {
        $s = $this->db->prepare("SELECT * FROM categories WHERE id = ?");
        $s->execute([$id]); $r = $s->fetch();
        return $r ? new Category($r) : null;
    }
    public function save(Category $c): Category {
        if ($c->id !== null) {
            $s = $this->db->prepare("UPDATE categories SET category_name=?, icon=? WHERE id=?");
            $s->execute([$c->categoryName,$c->icon,$c->id]);
            return $this->findById($c->id);
        }
        $s = $this->db->prepare("INSERT INTO categories (category_name,icon) VALUES (?,?)");
        $s->execute([$c->categoryName,$c->icon]);
        return $this->findById((int)$this->db->lastInsertId());
    }
    public function delete(int $id): void {
        $s = $this->db->prepare("DELETE FROM categories WHERE id = ?");
        $s->execute([$id]);
    }
}