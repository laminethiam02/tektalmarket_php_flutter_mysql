<?php
class ProductService {
    private ProductRepository $repo;
    private CategoryRepository $catRepo;
    private ProductImageRepository $imgRepo;
    private string $uploadDir;

    private const DEFAULT_DURATION = 30; // jours - AUTO

    public function __construct() {
        $this->repo    = new ProductRepository();
        $this->catRepo = new CategoryRepository();
        $this->imgRepo = new ProductImageRepository();
        $this->uploadDir = __DIR__ . '/../uploads/products/';
    }

    public function create(ProductDTO $dto, int $sellerId, array $files): array {
        $cat = $this->catRepo->findById($dto->categoryId ?? 0);
        if (!$cat) throw new Exception("Catégorie invalide");

        $p = new Product();
        $p->productTitle = $dto->productTitle;
        $p->productDescription = $dto->productDescription;
        $p->productPrice = (float)$dto->productPrice;
        $p->ville = $dto->ville;
        $p->categoryId = $cat->id;
        $p->userId = $sellerId;
        $p->durationDays = self::DEFAULT_DURATION;
        $p->expiresAt = date('Y-m-d H:i:s', strtotime('+'.self::DEFAULT_DURATION.' days')); // ← durée AUTO
        $p->isActive = true;

        $savedPaths = $this->saveImages($files); // max 5
        if (count($savedPaths) > 0) $p->productImage = $savedPaths[0]; // main = première

        $p = $this->repo->save($p);

        foreach ($savedPaths as $i => $path) {
            $this->imgRepo->save($p->id, $path, $i);
        }
        return $this->toDTO($this->repo->findById($p->id));
    }

    public function update(int $id, ProductDTO $dto, int $currentUserId, array $files): array {
        $p = $this->repo->findById($id);
        if (!$p) throw new Exception("Annonce introuvable");
        if ($p->userId !== $currentUserId) throw new Exception("Non autorisé");

        if ($dto->productTitle !== null) $p->productTitle = $dto->productTitle;
        if ($dto->productDescription !== null) $p->productDescription = $dto->productDescription;
        if ($dto->productPrice !== null) $p->productPrice = (float)$dto->productPrice;
        if ($dto->ville !== null) $p->ville = $dto->ville;
        if ($dto->categoryId !== null) {
            $cat = $this->catRepo->findById($dto->categoryId);
            if (!$cat) throw new Exception("Catégorie invalide");
            $p->categoryId = $cat->id;
        }
        if ($dto->isActive !== null) $p->isActive = $dto->isActive;

        // Remplacement des images si nouvelles images fournies
        if ($this->hasNewImages($files)) {
            $this->imgRepo->deleteByProductId($p->id);
            $paths = $this->saveImages($files);
            if (count($paths) > 0) $p->productImage = $paths[0];
            $this->repo->save($p);
            foreach ($paths as $i => $path) $this->imgRepo->save($p->id, $path, $i);
        } else {
            $this->repo->save($p);
        }
        return $this->toDTO($this->repo->findById($p->id));
    }

    public function getAll(): array {
        return array_map([$this,'toDTO'], $this->repo->findAll());
    }
    public function getById(int $id): array {
        $p = $this->repo->findById($id);
        if (!$p) throw new Exception("Annonce introuvable");
        return $this->toDTO($p);
    }
    public function getByCategory(int $cid): array {
        return array_map([$this,'toDTO'], $this->repo->findByCategoryId($cid));
    }
    public function getByUser(int $uid): array {
        return array_map([$this,'toDTO'], $this->repo->findByUserId($uid));
    }
    public function search(string $kw): array {
        return array_map([$this,'toDTO'], $this->repo->search($kw));
    }
    public function delete(int $id, int $currentUserId): void {
        $p = $this->repo->findById($id);
        if (!$p) throw new Exception("Annonce introuvable");
        if ($p->userId !== $currentUserId) throw new Exception("Non autorisé");
        $this->imgRepo->deleteByProductId($id);
        $this->repo->delete($id);
    }

    // ---- helpers ----
    private function hasNewImages(array $files): bool {
        if (!isset($files['name']) || !is_array($files['name'])) return false;
        foreach ($files['error'] as $err) if ($err === UPLOAD_ERR_OK) return true;
        return false;
    }

    /** @return string[] */
    private function saveImages(array $files): array {
        if (!is_dir($this->uploadDir)) mkdir($this->uploadDir, 0777, true);
        $out = [];
        if (!isset($files['name']) || !is_array($files['name'])) return $out;
        $count = count($files['name']);
        for ($i = 0; $i < $count && count($out) < 5; $i++) {
            if ($files['error'][$i] !== UPLOAD_ERR_OK) continue;
            $name = uniqid('', true) . '_' . preg_replace('/[^a-zA-Z0-9._-]/','_', basename($files['name'][$i]));
            if (move_uploaded_file($files['tmp_name'][$i], $this->uploadDir.$name)) {
                $out[] = '/uploads/products/' . $name;
            }
        }
        return $out;
    }

    private function toDTO(Product $p): array {
        return [
            'id'=>$p->id,'productTitle'=>$p->productTitle,'productDescription'=>$p->productDescription,
            'productPrice'=>$p->productPrice,'ville'=>$p->ville,
            'productImage'=>$p->productImage,'categoryId'=>$p->categoryId,'categoryName'=>$p->categoryName,
            'userId'=>$p->userId,'durationDays'=>$p->durationDays,'expiresAt'=>$p->expiresAt,
            'isActive'=>$p->isActive,'createdAt'=>$p->createdAt,'updatedAt'=>$p->updatedAt,
            'images'=>array_map(fn($i)=>['id'=>$i->id,'imagePath'=>$i->imagePath,'sortOrder'=>$i->sortOrder], $p->images),
            'seller'=>[
                'id'=>$p->userId,
                'nom'=>$p->sellerNom,
                'userImage'=>$p->sellerImage,
                'nomMagasin'=>$p->sellerNomMagasin,
                'ville'=>$p->sellerVille,
                'telephone'=>$p->sellerTelephone,
                'membreDepuis'=>$p->sellerMembreDepuis,
            ],
        ];
    }
}