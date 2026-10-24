<?php
class Database {
    private static ?Database $instance = null;
    private PDO $connection;

    private string $host='localhost', $dbname='api_marche', $username='root', $password='';

    private function __construct() {
        try {
            $this->connection = new PDO(
                "mysql:host={$this->host};dbname={$this->dbname};charset=utf8mb4",
                $this->username, $this->password,
                [
                    PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES=>false,
                ]
            );
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error'=>'DB connection failed: '.$e->getMessage()]);
            exit;
        }
    }
    public static function getInstance(): Database {
        if (self::$instance === null) self::$instance = new self();
        return self::$instance;
    }
    public function getConnection(): PDO { return $this->connection; }
}