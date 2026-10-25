<?php
class Notification {
    public ?int    $id = null;
    public ?int    $userId = null;
    public ?string $type = 'info';
    public ?string $title = null;
    public ?string $body = null;
    public ?int    $relatedId = null;
    public bool    $isRead = false;
    public ?string $createdAt = null;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id        = isset($d['id']) ? (int)$d['id'] : null;
        $this->userId    = isset($d['user_id']) ? (int)$d['user_id'] : null;
        $this->type      = $d['type'] ?? 'info';
        $this->title     = $d['title'] ?? null;
        $this->body      = $d['body'] ?? null;
        $this->relatedId = isset($d['related_id']) ? (int)$d['related_id'] : null;
        $this->isRead    = (bool)($d['is_read'] ?? false);
        $this->createdAt = $d['created_at'] ?? null;
    }
}