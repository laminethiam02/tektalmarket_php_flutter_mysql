<?php
class Message {
    public ?int    $id = null;
    public ?int    $conversationId = null;
    public ?int    $senderId = null;
    public ?string $content = null;
    public bool    $isRead = false;
    public ?string $createdAt = null;
    public ?string $senderName = null;
    public ?string $senderImage = null;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id             = isset($d['id']) ? (int)$d['id'] : null;
        $this->conversationId = isset($d['conversation_id']) ? (int)$d['conversation_id'] : null;
        $this->senderId       = isset($d['sender_id']) ? (int)$d['sender_id'] : null;
        $this->content        = $d['content'] ?? null;
        $this->isRead         = (bool)($d['is_read'] ?? false);
        $this->createdAt      = $d['created_at'] ?? null;
        $this->senderName     = $d['sender_name'] ?? null;
        $this->senderImage    = $d['sender_image'] ?? null;
    }
}