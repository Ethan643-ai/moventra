<?php
declare(strict_types=1);

$config = require __DIR__ . "/config.php";

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
  $db = new mysqli(
    $config["host"],
    $config["user"],
    $config["pass"],
    $config["name"],
    (int) $config["port"]
  );
  $db->set_charset("utf8mb4");
} catch (mysqli_sql_exception $e) {
  http_response_code(500);
  header("Content-Type: application/json; charset=utf-8");
  echo json_encode([
    "ok" => false,
    "error" => "Cannot connect to MySQL. Import moventra.sql in phpMyAdmin, then start XAMPP MySQL.",
    "detail" => $e->getMessage(),
  ]);
  exit;
}

function json_ok(array $data = []): void {
  header("Content-Type: application/json; charset=utf-8");
  echo json_encode(["ok" => true] + $data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
  exit;
}

function json_err(string $message, int $code = 400): void {
  http_response_code($code);
  header("Content-Type: application/json; charset=utf-8");
  echo json_encode(["ok" => false, "error" => $message], JSON_UNESCAPED_UNICODE);
  exit;
}

function read_json_body(): array {
  $raw = file_get_contents("php://input");
  if (!$raw) return $_POST ?: [];
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}
