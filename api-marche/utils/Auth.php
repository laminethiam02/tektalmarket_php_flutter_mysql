<?php
class Auth {
    public static function bearer(): ?string {
        $h = getallheaders();
        $a = $h['Authorization'] ?? $h['authorization'] ?? null;
        if ($a && preg_match('/Bearer\s+(.*)$/i', $a, $m)) return $m[1];
        return null;
    }
    public static function current(): ?array {
        $t = self::bearer();
        return $t ? Jwt::decode($t) : null;
    }
    public static function require(): array {
        $u = self::current();
        if (!$u) { http_response_code(401); echo json_encode(['error'=>'Non authentifié']); exit; }
        return $u;
    }
    public static function requireRole(string $role): array {
        $u = self::require();
        if (($u['role'] ?? '') !== $role) {
            http_response_code(403); echo json_encode(['error'=>'Accès refusé']); exit;
        }
        return $u;
    }
}