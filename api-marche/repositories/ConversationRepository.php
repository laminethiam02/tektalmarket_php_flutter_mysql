<?php
class ConversationRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    private const BASE = "
        SELECT c.*, p.product_title, p.product_image,
          IF(c.buyer_id = :uid1, us.nom, ub.nom)               AS other_name,
          IF(c.buyer_id = :uid2, us.user_image, ub.user_image) AS other_image,
          (SELECT content FROM messages m WHERE m.conversation_id=c.id
             ORDER BY m.id DESC LIMIT 1)                       AS last_message,
          (SELECT COUNT(*) FROM messages m
             WHERE m.conversation_id=c.id AND m.sender_id <> :uid3 AND m.is_read=0) AS unread_count
        FROM conversations c
        JOIN products p ON c.product_id = p.id
        JOIN users ub   ON c.buyer_id   = ub.id
        JOIN users us   ON c.seller_id  = us.id
    ";

    private function params(int $uid): array {
        return ['uid1'=>$uid,'uid2'=>$uid,'uid3'=>$uid,'uid4'=>$uid,'uid5'=>$uid];
    }

    public function findById(int $id, int $userId): ?Conversation {
        $s = $this->db->prepare(self::BASE . " WHERE c.id=:id AND (c.buyer_id=:uid4 OR c.seller_id=:uid5)");
        $p = $this->params($userId); $p['id'] = $id;
        $s->execute($p);
        $r = $s->fetch();
        return $r ? new Conversation($r) : null;
    }

    public function findByUser(int $userId): array {
        $s = $this->db->prepare(self::BASE . "
            WHERE c.buyer_id=:uid4 OR c.seller_id=:uid5
            ORDER BY c.last_message_at DESC, c.created_at DESC");
        $s->execute($this->params($userId));
        return array_map(fn($r)=>new Conversation($r), $s->fetchAll());
    }

    public function findExisting(int $productId, int $buyerId, int $sellerId): ?Conversation {
        $s = $this->db->prepare("SELECT * FROM conversations
                                 WHERE product_id=? AND buyer_id=? AND seller_id=?");
        $s->execute([$productId,$buyerId,$sellerId]);
        $r = $s->fetch();
        return $r ? new Conversation($r) : null;
    }

    public function create(int $productId, int $buyerId, int $sellerId): Conversation {
        $s = $this->db->prepare("INSERT INTO conversations (product_id,buyer_id,seller_id)
                                 VALUES (?,?,?)");
        $s->execute([$productId,$buyerId,$sellerId]);
        return new Conversation(['id'=>(int)$this->db->lastInsertId(),
            'product_id'=>$productId,'buyer_id'=>$buyerId,'seller_id'=>$sellerId]);
    }

    public function touch(int $id, string $at): void {
        $s = $this->db->prepare("UPDATE conversations SET last_message_at=? WHERE id=?");
        $s->execute([$at,$id]);
    }

    public function existsForUser(int $id, int $userId): bool {
        $s = $this->db->prepare("SELECT COUNT(*) FROM conversations
                                 WHERE id=? AND (buyer_id=? OR seller_id=?)");
        $s->execute([$id,$userId,$userId]);
        return (int)$s->fetchColumn() > 0;
    }
}