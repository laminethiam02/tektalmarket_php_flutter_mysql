<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

spl_autoload_register(function ($class) {
    foreach (['config/','utils/','entities/','dtos/','repositories/','services/','controllers/'] as $p) {
        $f = __DIR__ . '/' . $p . $class . '.php';
        if (file_exists($f)) { require_once $f; return; }
    }
});

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$base = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
if ($base !== '' && strpos($uri, $base) === 0) $uri = substr($uri, strlen($base));
$uri = '/' . trim($uri, '/');
$method = $_SERVER['REQUEST_METHOD'];
if ($method === 'POST' && isset($_POST['_method'])) $method = strtoupper($_POST['_method']);

$authCtrl     = new AuthController();
$userCtrl     = new UserController();
$categoryCtrl = new CategoryController();
$productCtrl  = new ProductController();

try {
    /* --------- AUTH --------- */
    if ($uri === '/api/auth/register' && $method === 'POST') { $authCtrl->register(); exit; }
    if ($uri === '/api/auth/login'    && $method === 'POST') { $authCtrl->login(); exit; }
    if ($uri === '/api/auth/me'       && $method === 'GET')  { $authCtrl->me(); exit; }

    /* --------- USERS --------- */
    if ($uri === '/api/users/profile' && $method === 'PUT')  { $userCtrl->updateProfile(); exit; }
    if (preg_match('#^/api/users/(\d+)$#', $uri, $m) && $method === 'GET') {
        $userCtrl->getPublicProfile((int)$m[1]); exit;
    }

    /* --------- CATEGORIES --------- */
    if ($uri === '/api/categories') {
        if ($method === 'GET')  { $categoryCtrl->getAll();   exit; }
        if ($method === 'POST') { $categoryCtrl->create();   exit; }
        http_response_code(405); echo json_encode(['error'=>'Method Not Allowed']); exit;
    }
    if (preg_match('#^/api/categories/(\d+)$#', $uri, $m)) {
        $id = (int)$m[1];
        if ($method === 'GET')    { $categoryCtrl->getById($id); exit; }
        if ($method === 'PUT')    { $categoryCtrl->update($id);  exit; }
        if ($method === 'DELETE') { $categoryCtrl->delete($id);  exit; }
    }

    /* --------- PRODUCTS --------- */
    if ($uri === '/api/products') {
        if ($method === 'GET')  { $productCtrl->getAll();    exit; }
        if ($method === 'POST') { $productCtrl->create();    exit; }
    }
    if ($uri === '/api/products/search' && $method === 'GET') { $productCtrl->search(); exit; }
    if (preg_match('#^/api/products/category/(\d+)$#', $uri, $m) && $method === 'GET') {
        $productCtrl->getByCategory((int)$m[1]); exit;
    }
    if (preg_match('#^/api/products/user/(\d+)$#', $uri, $m) && $method === 'GET') {
        $productCtrl->getByUser((int)$m[1]); exit;
    }
    if (preg_match('#^/api/products/(\d+)$#', $uri, $m)) {
        $id = (int)$m[1];
        if ($method === 'GET')    { $productCtrl->getById($id); exit; }
        if ($method === 'PUT')    { $productCtrl->update($id);  exit; }
        if ($method === 'DELETE') { $productCtrl->delete($id);  exit; }
    }

    http_response_code(404);
    echo json_encode(['error'=>'Route not found','uri'=>$uri]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error'=>$e->getMessage()]);
}