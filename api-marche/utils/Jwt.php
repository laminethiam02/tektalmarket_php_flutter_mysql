<?php
class Jwt {
    private static string $secret = 'CHANGE_ME_SECRET_KEY_API_MARCHE_2024';

    public static function encode(array $payload): string {
        $header  = self::b64e(json_encode(['alg'=>'HS256','typ'=>'JWT']));
        $payload['iat'] = time();
        $payload['exp'] = time() + 60*60*24*7; // 7 jours
        $pl = self::b64e(json_encode($payload));
        $sig = self::b64e(hash_hmac('sha256', "$header.$pl", self::$secret, true));
        return "$header.$pl.$sig";
    }

    public static function decode(string $token): ?array {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return null;
        [$h,$p,$s] = $parts;
        $expected = self::b64e(hash_hmac('sha256', "$h.$p", self::$secret, true));
        if (!hash_equals($expected, $s)) return null;
        $data = json_decode(self::b64d($p), true);
        if (!$data || (isset($data['exp']) && $data['exp'] < time())) return null;
        return $data;
    }

    private static function b64e(string $d): string { return rtrim(strtr(base64_encode($d),'+/','-_'),'='); }
    private static function b64d(string $d): string { return base64_decode(strtr($d,'-_','+/')); }
}