<?php
class ProductRepository {
    private PDO $db;
    private ProductImageRepository $imgRepo;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
        $this->imgRepo = new ProductImageRepository();
    }

    private const BASE = "
        SELECT p.*, c.category_name,
               u.nom AS seller_nom, u.user_image AS seller_image,
               u.nom_magasin AS seller_nom_magasin, u.ville AS seller_ville,
               u.telephone AS seller_telephone, u.created_at AS seller_membre_depuis
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        INNER JOIN users u ON p.user_id = u.id
    ";

    private function hydrate(array $r): Product {
        $p = new Product();
        $p->id = (int)$r['id'];
        $p->productTitle = $r['product_title'];
        $p->productDescription = $r['product_description'];
        $p->productPrice = (float)$r['product_price'];
        $p->ville = $r['ville'];
        $p->productImage = $r['product_image'];
        $p->categoryId = $r['category_id'] !== null ? (int)$r['category_id'] : null;
        $p->categoryName = $r['category_name'] ?? null;
        $p->userId = (int)$r['user_id'];
        $p->durationDays = (int)$r['duration_days'];
        $p->expiresAt = $r['expires_at'];
        $p->isActive = (bool)$r['is_active'];
        $p->createdAt = $r['created_at'];
        $p->updatedAt = $r['updated_at'];
        $p->sellerNom = $r['seller_nom'] ?? null;
        $p->sellerImage = $r['seller_image'] ?? null;
        $p->sellerNomMagasin = $r['seller_nom_magasin'] ?? null;
        $p->sellerVille = $r['seller_ville'] ?? null;
        $p->sellerTelephone = $r['seller_telephone'] ?? null;
        $p->sellerMembreDepuis = $r['seller_membre_depuis'] ?? null;
        $p->images = $this->imgRepo->findByProductId($p->id);
        return $p;
    }

    public function findAll(): array {
        $s = $this->db->query(self::BASE . " WHERE p.is_active=1 AND p.expires_at > NOW() ORDER BY p.id DESC");
        return array_map([$this,'hydrate'], $s->fetchAll());
    }
    public function findById(int $id): ?Product {
        $s = $this->db->prepare(self::BASE . " WHERE p.id=?");
        $s->execute([$id]); $r = $s->fetch();
        return $r ? $this->hydrate($r) : null;
    }
    public function findByCategoryId(int $cid): array {
        $s = $this->db->prepare(self::BASE . " WHERE p.category_id=? AND p.is_active=1 AND p.expires_at > NOW() ORDER BY p.id DESC");
        $s->execute([$cid]);
        return array_map([$this,'hydrate'], $s->fetchAll());
    }
    public function findByUserId(int $uid): array {
        $s = $this->db->prepare(self::BASE . " WHERE p.user_id=? ORDER BY p.id DESC");
        $s->execute([$uid]);
        return array_map([$this,'hydrate'], $s->fetchAll());
    }
    public function search(string $kw): array {
        $s = $this->db->prepare(self::BASE . " WHERE (LOWER(p.product_title) LIKE LOWER(?) OR LOWER(p.ville) LIKE LOWER(?)) AND p.is_active=1 AND p.expires_at > NOW() ORDER BY p.id DESC");
        $s->execute(['%'.$kw.'%','%'.$kw.'%']);
        return array_map([$this,'hydrate'], $s->fetchAll());
    }
    public function existsById(int $id): bool {
        $s = $this->db->prepare("SELECT COUNT(*) FROM products WHERE id=?");
        $s->execute([$id]); return (int)$s->fetchColumn() > 0;
    }
    public function save(Product $p): Product {
        if ($p->id !== null) {
            $s = $this->db->prepare("UPDATE products SET
                product_title=?, product_description=?, product_price=?, ville=?,
                product_image=?, category_id=?, duration_days=?,
                expires_at=?, is_active=? WHERE id=?");
            $s->execute([
                $p->productTitle,$p->productDescription,$p->productPrice,$p->ville,
                $p->productImage,$p->categoryId,$p->durationDays,
                $p->expiresAt,$p->isActive?1:0,$p->id
            ]);
            return $this->findById($p->id);
        }
        $s = $this->db->prepare("INSERT INTO products
            (product_title,product_description,product_price,ville,
             product_image,category_id,user_id,duration_days,expires_at,is_active)
            VALUES (?,?,?,?,?,?,?,?,?,?)");
        $s->execute([
            $p->productTitle,$p->productDescription,$p->productPrice,$p->ville,
            $p->productImage,$p->categoryId,$p->userId,$p->durationDays,$p->expiresAt,$p->isActive?1:0
        ]);
        return $this->findById((int)$this->db->lastInsertId());
    }
    public function delete(int $id): void {
        $s = $this->db->prepare("DELETE FROM products WHERE id=?");
        $s->execute([$id]);
    }
}