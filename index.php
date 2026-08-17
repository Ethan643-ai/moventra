<?php
/**
 * Open MOVENTRA in the browser via XAMPP:
 *   http://localhost/mine/
 * Copy the whole Desktop/mine folder into C:\xampp\htdocs\
 */
$candidates = [
  __DIR__ . DIRECTORY_SEPARATOR . "IDEX-L3-AD.html",
  __DIR__ . DIRECTORY_SEPARATOR . "IDEX L3 AD.HMTL",
];
$file = null;
foreach ($candidates as $path) {
  if (is_file($path)) { $file = $path; break; }
}
if (!$file) {
  http_response_code(404);
  header("Content-Type: text/plain; charset=utf-8");
  echo "MOVENTRA HTML not found. Place IDEX-L3-AD.html in this folder.";
  exit;
}
header("Content-Type: text/html; charset=utf-8");
readfile($file);
