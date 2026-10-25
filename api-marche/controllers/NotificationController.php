<?php
class NotificationController {
    private NotificationService $service;
    public function __construct() { $this->service = new NotificationService(); }

    public function getAll(): void {
        try {
            $u = Auth::require();
            echo json_encode($this->service->getAll((int)$u['sub']));
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function unreadCount(): void {
        try {
            $u = Auth::require();
            echo json_encode(['count'=>$this->service->unreadCount((int)$u['sub'])]);
        } catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }

    public function markRead(int $id): void {
        try { $u = Auth::require(); $this->service->markRead($id, (int)$u['sub']); echo json_encode(['ok'=>true]); }
        catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function markAllRead(): void {
        try { $u = Auth::require(); $this->service->markAllRead((int)$u['sub']); echo json_encode(['ok'=>true]); }
        catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
    public function delete(int $id): void {
        try { $u = Auth::require(); $this->service->delete($id, (int)$u['sub']); http_response_code(204); }
        catch (Exception $e) { http_response_code(400); echo json_encode(['error'=>$e->getMessage()]); }
    }
}