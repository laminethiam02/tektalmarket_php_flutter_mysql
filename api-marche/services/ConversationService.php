<?php
class ConversationService {
    private ConversationRepository $repo;
    private ProductRepository $prodRepo;
    private MessageRepository $msgRepo;

    public function __construct() {
        $this->repo     = new ConversationRepository();
        $this->prodRepo = new ProductRepository();
        $this->msgRepo  = new MessageRepository();
    }

    public function getOrCreate(int $productId, int $buyerId): array {
        $p = $this->prodRepo->findById($productId);
        if (!$p) throw new Exception("Annonce introuvable");
        if ($p->userId === $buyerId) throw new Exception("Vous ne pouvez pas vous contacter vous-même");

        $existing = $this->repo->findExisting($productId, $buyerId, $p->userId);
        if ($existing) {
            return $this->toDTO($this->repo->findById($existing->id, $buyerId));
        }
        $c = $this->repo->create($productId, $buyerId, $p->userId);
        return $this->toDTO($this->repo->findById($c->id, $buyerId));
    }

    public function getAll(int $userId): array {
        return array_map(fn($c)=>$this->toDTO($c), $this->repo->findByUser($userId));
    }

    public function getById(int $id, int $userId): array {
        $c = $this->repo->findById($id, $userId);
        if (!$c) throw new Exception("Conversation introuvable");
        $this->msgRepo->markRead($id, $userId);
        return $this->toDTO($c);
    }

    private function toDTO(?Conversation $c): array {
        if (!$c) return [];
        return [
            'id'=>$c->id,'productId'=>$c->productId,'buyerId'=>$c->buyerId,'sellerId'=>$c->sellerId,
            'productTitle'=>$c->productTitle,'productImage'=>$c->productImage,
            'otherName'=>$c->otherName,'otherImage'=>$c->otherImage,
            'lastMessage'=>$c->lastMessage,'lastMessageAt'=>$c->lastMessageAt,
            'unreadCount'=>$c->unreadCount,'createdAt'=>$c->createdAt,
        ];
    }
}