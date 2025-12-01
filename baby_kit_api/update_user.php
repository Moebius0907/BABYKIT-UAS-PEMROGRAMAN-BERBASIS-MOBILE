<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
require 'config.php'; 

// Ambil data JSON dari request body
$data = json_decode(file_get_contents("php://input"), true);

// Validasi user_id
if (!isset($data['user_id'])) {
    echo json_encode(["status" => "error", "message" => "User ID dibutuhkan"]);
    exit;
}

// Ambil data dari request, gunakan real_escape_string untuk keamanan dasar
$user_id = intval($data['user_id']);
$name    = $conn->real_escape_string($data['name'] ?? '');
$phone   = $conn->real_escape_string($data['phone'] ?? '');
$address = $conn->real_escape_string($data['address'] ?? '');

// Query untuk update data user
$sql = "UPDATE users SET name='$name', phone='$phone', address='$address' WHERE user_id=$user_id";

// Eksekusi query dan kirim response
if ($conn->query($sql)) {
    echo json_encode(["status" => "success", "message" => "Profil berhasil diperbarui"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

// Tutup koneksi database
$conn->close();
?>
