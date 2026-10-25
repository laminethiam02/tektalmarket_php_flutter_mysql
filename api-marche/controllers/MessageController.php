<?php
class MessageController {
    private MessageService $service;
    public function __construct() { $this->service = new MessageService(); }

    public function getMessages(int $convId): void {
        try {
            $u = Auth::require();
            echo json_encode($this->service->getMessages($convId, (int)$u['sub']));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function send(int $convId): void {
        try {
            $u = Auth::require();
            $d = json_decode(file_get_contents('php://input'), true) ?? $_POST;
            http_response_code(201);
            echo json_encode($this->service->send($convId, (int)$u['sub'], (string)($d['content'] ?? '')));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function unreadCount(): void {
        try {
            $u = Auth::require();
            echo json_encode(['count'=>$this->service->unreadCount((int)$u['sub'])]);
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
}