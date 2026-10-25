<?php
class MessageRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function findByConversation(int $convId, int $limit = 200): array {
        $s = $this->db->prepare("SELECT m.*, u.nom AS sender_name, u.user_image AS sender_image
                                 FROM messages m JOIN users u ON m.sender_id = u.id
                                 WHERE m.conversation_id=? ORDER BY m.id ASC LIMIT $limit");
        $s->execute([$convId]);
        return array_map(fn($r)=>new Message($r), $s->fetchAll());
    }

    public function create(int $convId, int $senderId, string $content): Message {
        $s = $this->db->prepare("INSERT INTO messages (conversation_id,sender_id,content)
                                 VALUES (?,?,?)");
        $s->execute([$convId,$senderId,$content]);
        $id = (int)$this->db->lastInsertId();
        $s = $this->db->prepare("SELECT m.*, u.nom AS sender_name, u.user_image AS sender_image
                                 FROM messages m JOIN users u ON m.sender_id = u.id
                                 WHERE m.id=?");
        $s->execute([$id]);
        return new Message($s->fetch());
    }

    public function markRead(int $convId, int $userId): void {
        $s = $this->db->prepare("UPDATE messages SET is_read=1
                                 WHERE conversation_id=? AND sender_id<>? AND is_read=0");
        $s->execute([$convId,$userId]);
    }

    public function unreadCountForUser(int $userId): int {
        $s = $this->db->prepare("SELECT COUNT(*) FROM messages m
                                 JOIN conversations c ON m.conversation_id=c.id
                                 WHERE (c.buyer_id=? OR c.seller_id=?)
                                   AND m.sender_id<>? AND m.is_read=0");
        $s->execute([$userId,$userId,$userId]);
        return (int)$s->fetchColumn();
    }
}