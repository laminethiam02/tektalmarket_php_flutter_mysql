<?php
class NotificationService {
    private NotificationRepository $repo;
    public function __construct() { $this->repo = new NotificationRepository(); }

    public function getAll(int $userId): array {
        return array_map(fn($n)=>$this->toDTO($n), $this->repo->findByUser($userId));
    }
    public function markRead(int $id, int $userId): void  { $this->repo->markRead($id, $userId); }
    public function markAllRead(int $userId): void        { $this->repo->markAllRead($userId); }
    public function delete(int $id, int $userId): void    { $this->repo->delete($id, $userId); }
    public function unreadCount(int $userId): int         { return $this->repo->unreadCount($userId); }

    private function toDTO(Notification $n): array {
        return [
            'id'=>$n->id,'type'=>$n->type,'title'=>$n->title,'body'=>$n->body,
            'relatedId'=>$n->relatedId,'isRead'=>$n->isRead,'createdAt'=>$n->createdAt,
        ];
    }
}