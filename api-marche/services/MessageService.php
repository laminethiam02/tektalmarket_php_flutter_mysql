<?php
class MessageService {
    private MessageRepository $msgRepo;
    private ConversationRepository $convRepo;
    private NotificationRepository $notifRepo;
    private UserRepository $userRepo;

    public function __construct() {
        $this->msgRepo   = new MessageRepository();
        $this->convRepo  = new ConversationRepository();
        $this->notifRepo = new NotificationRepository();
        $this->userRepo  = new UserRepository();
    }

    public function getMessages(int $convId, int $userId): array {
        if (!$this->convRepo->existsForUser($convId, $userId)) throw new Exception("Non autorisé");
        $this->msgRepo->markRead($convId, $userId);
        return array_map(fn($m)=>$this->toDTO($m), $this->msgRepo->findByConversation($convId));
    }

    public function send(int $convId, int $userId, string $content): array {
        $content = trim($content);
        if ($content === '') throw new Exception("Message vide");
        if (mb_strlen($content) > 2000) throw new Exception("Message trop long (2000 max)");

        $conv = $this->convRepo->findById($convId, $userId);
        if (!$conv) throw new Exception("Conversation introuvable");

        $msg = $this->msgRepo->create($convId, $userId, $content);
        $this->convRepo->touch($convId, date('Y-m-d H:i:s'));

        $recipientId = ($conv->buyerId === $userId) ? $conv->sellerId : $conv->buyerId;
        $sender      = $this->userRepo->findById($userId);

        $n = new Notification();
        $n->userId    = $recipientId;
        $n->type      = 'message';
        $n->title     = 'Nouveau message de ' . ($sender->nom ?? 'Utilisateur');
        $n->body      = mb_substr($content, 0, 120);
        $n->relatedId = $convId;
        $this->notifRepo->create($n);

        return $this->toDTO($msg);
    }

    public function unreadCount(int $userId): int {
        return $this->msgRepo->unreadCountForUser($userId);
    }

    private function toDTO(Message $m): array {
        return [
            'id'=>$m->id,'conversationId'=>$m->conversationId,'senderId'=>$m->senderId,
            'content'=>$m->content,'isRead'=>$m->isRead,'createdAt'=>$m->createdAt,
            'senderName'=>$m->senderName,'senderImage'=>$m->senderImage,
        ];
    }
}