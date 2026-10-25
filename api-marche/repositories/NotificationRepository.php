<?php
class NotificationRepository {
    private PDO $db;
    public function __construct() { $this->db = Database::getInstance()->getConnection(); }

    public function findByUser(int $userId, int $limit = 60): array {
        $s = $this->db->prepare("SELECT * FROM notifications WHERE user_id=?
                                 ORDER BY id DESC LIMIT $limit");
        $s->execute([$userId]);
        return array_map(fn($r)=>new Notification($r), $s->fetchAll());
    }

    public function create(Notification $n): Notification {
        $s = $this->db->prepare("INSERT INTO notifications (user_id,type,title,body,related_id)
                                 VALUES (?,?,?,?,?)");
        $s->execute([$n->userId,$n->type,$n->title,$n->body,$n->relatedId]);
        $n->id = (int)$this->db->lastInsertId();
        return $n;
    }

    public function markRead(int $id, int $userId): void {
        $s = $this->db->prepare("UPDATE notifications SET is_read=1 WHERE id=? AND user_id=?");
        $s->execute([$id,$userId]);
    }
    public function markAllRead(int $userId): void {
        $s = $this->db->prepare("UPDATE notifications SET is_read=1 WHERE user_id=?");
        $s->execute([$userId]);
    }
    public function delete(int $id, int $userId): void {
        $s = $this->db->prepare("DELETE FROM notifications WHERE id=? AND user_id=?");
        $s->execute([$id,$userId]);
    }
    public function unreadCount(int $userId): int {
        $s = $this->db->prepare("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0");
        $s->execute([$userId]);
        return (int)$s->fetchColumn();
    }
}