<?php
class Conversation {
    public ?int    $id = null;
    public ?int    $productId = null;
    public ?int    $buyerId = null;
    public ?int    $sellerId = null;
    public ?string $lastMessageAt = null;
    public ?string $createdAt = null;
    // transient
    public ?string $productTitle = null;
    public ?string $productImage = null;
    public ?string $otherName = null;
    public ?string $otherImage = null;
    public ?string $lastMessage = null;
    public int     $unreadCount = 0;

    public function __construct(array $d = []) {
        if (!$d) return;
        $this->id            = isset($d['id']) ? (int)$d['id'] : null;
        $this->productId     = isset($d['product_id']) ? (int)$d['product_id'] : null;
        $this->buyerId       = isset($d['buyer_id']) ? (int)$d['buyer_id'] : null;
        $this->sellerId      = isset($d['seller_id']) ? (int)$d['seller_id'] : null;
        $this->lastMessageAt = $d['last_message_at'] ?? null;
        $this->createdAt     = $d['created_at'] ?? null;
        $this->productTitle  = $d['product_title'] ?? null;
        $this->productImage  = $d['product_image'] ?? null;
        $this->otherName     = $d['other_name'] ?? null;
        $this->otherImage    = $d['other_image'] ?? null;
        $this->lastMessage   = $d['last_message'] ?? null;
        $this->unreadCount   = isset($d['unread_count']) ? (int)$d['unread_count'] : 0;
    }
}