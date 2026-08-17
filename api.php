<?php
declare(strict_types=1);

require_once __DIR__ . "/db.php";

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
  http_response_code(204);
  exit;
}

$action = $_GET["action"] ?? "health";

switch ($action) {
  case "health":
    json_ok(["service" => "MOVENTRA API", "db" => "moventra"]);

  case "bootstrap":
    json_ok(api_bootstrap($db));

  case "fleet":
    json_ok(["fleet" => api_fleet($db), "alt_routes" => api_alt_routes($db)]);

  case "cities":
    json_ok(["cities" => api_cities($db)]);

  case "ports":
    json_ok(["ports" => api_ports($db)]);

  case "loadboard":
    json_ok(["loadboard" => api_loadboard($db)]);

  case "finance":
    json_ok(["finance" => api_finance($db), "escrow" => api_escrow($db)]);

  case "login":
    api_login($db);

  case "quote":
    api_quote($db);

  case "signal":
    api_signal($db);

  default:
    json_err("Unknown action: " . $action, 404);
}

function fetch_all(mysqli $db, string $sql): array {
  $res = $db->query($sql);
  return $res ? $res->fetch_all(MYSQLI_ASSOC) : [];
}

function api_cities(mysqli $db): array {
  $out = [];
  foreach (fetch_all($db, "SELECT name, latitude, longitude FROM cities ORDER BY name") as $row) {
    $out[$row["name"]] = [(float) $row["latitude"], (float) $row["longitude"]];
  }
  return $out;
}

function api_fleet(mysqli $db): array {
  $rows = fetch_all($db, "SELECT * FROM shipments ORDER BY id");
  $wp = fetch_all($db, "SELECT shipment_id, seq, city_name FROM shipment_route_waypoints ORDER BY shipment_id, seq");
  $byShip = [];
  foreach ($wp as $w) {
    $byShip[(int) $w["shipment_id"]][] = $w["city_name"];
  }
  $fleet = [];
  foreach ($rows as $r) {
    $fleet[] = [
      "id" => (int) $r["id"],
      "waybill" => $r["waybill"],
      "plate" => $r["plate"],
      "colour" => $r["colour"],
      "driver" => $r["driver_name"],
      "phone" => $r["driver_phone"],
      "licence" => $r["licence"],
      "type" => $r["truck_type"],
      "cargo" => $r["cargo"],
      "seal" => $r["seal"],
      "origin" => $r["origin"],
      "destination" => $r["destination"],
      "currentCity" => $r["current_city"],
      "eta" => $r["eta"],
      "status" => $r["status"],
      "score" => (int) $r["trust_score"],
      "routeCities" => $byShip[(int) $r["id"]] ?? [],
    ];
  }
  return $fleet;
}

function api_alt_routes(mysqli $db): array {
  $rows = fetch_all($db, "SELECT * FROM alt_routes");
  $wp = fetch_all($db, "SELECT alt_route_id, seq, city_name FROM alt_route_waypoints ORDER BY alt_route_id, seq");
  $byAlt = [];
  foreach ($wp as $w) {
    $byAlt[(int) $w["alt_route_id"]][] = $w["city_name"];
  }
  $out = [];
  foreach ($rows as $r) {
    $out[$r["plate"]] = [
      "cities" => $byAlt[(int) $r["id"]] ?? [],
      "reason" => $r["reason"],
      "save" => $r["save_time"],
      "alert" => (bool) ((int) $r["alert"]),
      "offset" => (bool) ((int) $r["use_offset"]),
    ];
  }
  return $out;
}

function api_ports(mysqli $db): array {
  return fetch_all($db, "SELECT * FROM ports ORDER BY country, id");
}

function api_loadboard(mysqli $db): array {
  $rows = fetch_all($db, "SELECT * FROM loadboard ORDER BY id");
  foreach ($rows as &$r) {
    $r["pay_usd"] = (float) $r["pay_usd"];
  }
  return $rows;
}

function api_finance(mysqli $db): array {
  return fetch_all($db, "SELECT * FROM finance_products ORDER BY id");
}

function api_escrow(mysqli $db): array {
  return fetch_all($db, "
    SELECT e.id, s.waybill, s.plate, e.amount_usd, e.status, e.release_rule, e.created_at
    FROM escrow_holds e
    JOIN shipments s ON s.id = e.shipment_id
    ORDER BY e.id
  ");
}

function api_settings(mysqli $db): array {
  $out = [];
  foreach (fetch_all($db, "SELECT k, v FROM settings") as $row) {
    $out[$row["k"]] = $row["v"];
  }
  return $out;
}

function api_bootstrap(mysqli $db): array {
  return [
    "php" => true,
    "fleet" => api_fleet($db),
    "alt_routes" => api_alt_routes($db),
    "cities" => api_cities($db),
    "ports" => api_ports($db),
    "loadboard" => api_loadboard($db),
    "finance" => api_finance($db),
    "escrow" => api_escrow($db),
    "settings" => api_settings($db),
    "process" => [
      "Tanzania" => fetch_all($db, "SELECT step_no, title, description FROM port_process_steps WHERE country='Tanzania' ORDER BY step_no"),
      "Kenya" => fetch_all($db, "SELECT step_no, title, description FROM port_process_steps WHERE country='Kenya' ORDER BY step_no"),
    ],
    "gaps" => fetch_all($db, "SELECT area, problem, opportunity FROM port_friction_gaps ORDER BY id"),
  ];
}

function api_login(mysqli $db): void {
  if ($_SERVER["REQUEST_METHOD"] !== "POST") json_err("POST required", 405);
  $body = read_json_body();
  $email = trim((string) ($body["email"] ?? ""));
  $password = (string) ($body["password"] ?? "");
  $role = trim((string) ($body["role"] ?? ""));
  if ($password === "") json_err("Password required");

  $user = null;
  if ($email !== "") {
    $stmt = $db->prepare("SELECT id, full_name, email, phone, company, role, is_active FROM users WHERE email = ? AND password_hash = SHA2(?, 256) LIMIT 1");
    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();
  }
  if (!$user && $role !== "") {
    $stmt = $db->prepare("SELECT id, full_name, email, phone, company, role, is_active FROM users WHERE role = ? AND password_hash = SHA2(?, 256) LIMIT 1");
    $stmt->bind_param("ss", $role, $password);
    $stmt->execute();
    $user = $stmt->get_result()->fetch_assoc();
  }
  if (!$user) json_err("Invalid email or password", 401);
  if (!(int) $user["is_active"]) json_err("Account is inactive", 403);

  log_event($db, "login", null, json_encode(["email" => $user["email"], "role" => $user["role"]]));
  json_ok(["user" => $user]);
}

function api_quote(mysqli $db): void {
  if ($_SERVER["REQUEST_METHOD"] !== "POST") json_err("POST required", 405);
  $body = read_json_body();
  $origin = trim((string) ($body["origin"] ?? ""));
  $dest = trim((string) ($body["destination"] ?? ""));
  $type = trim((string) ($body["cargo_type"] ?? ""));
  $weight = (float) ($body["weight_mt"] ?? 0);
  $rate = (float) ($body["rate_usd"] ?? 0);
  $days = (float) ($body["transit_days"] ?? 0);
  $booked = !empty($body["booked"]) ? 1 : 0;
  if ($origin === "" || $dest === "") json_err("Origin and destination required");

  $stmt = $db->prepare("INSERT INTO rate_quotes (origin, destination, cargo_type, weight_mt, rate_usd, transit_days, booked) VALUES (?,?,?,?,?,?,?)");
  $stmt->bind_param("sssdddi", $origin, $dest, $type, $weight, $rate, $days, $booked);
  $stmt->execute();
  json_ok(["id" => $db->insert_id]);
}

function api_signal(mysqli $db): void {
  if ($_SERVER["REQUEST_METHOD"] !== "POST") json_err("POST required", 405);
  $body = read_json_body();
  $plate = trim((string) ($body["plate"] ?? ""));
  log_event($db, "driver_signal", $plate, json_encode($body));
  json_ok(["logged" => true]);
}

function log_event(mysqli $db, string $type, ?string $plate, ?string $payload): void {
  try {
    $stmt = $db->prepare("INSERT INTO event_log (event_type, plate, payload) VALUES (?,?,?)");
    $stmt->bind_param("sss", $type, $plate, $payload);
    $stmt->execute();
  } catch (Throwable $e) {
    // table optional on older dumps
  }
}
