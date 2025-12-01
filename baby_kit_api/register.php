<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

include "config.php"; // koneksi database

// Ambil data dari request body
$name     = $_POST['name'] ?? '';
$email    = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$phone    = $_POST['phone'] ?? '';
$address  = $_POST['address'] ?? '';

// Validasi input kosong
if (!$name || !$email || !$password) {
    echo json_encode([
        "success" => false,
        "message" => "Name, email, dan password wajib diisi!"
    ]);
    exit;
}

// Cek email sudah digunakan atau belum
$check = $conn->prepare("SELECT * FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$result = $check->get_result();

if ($result->num_rows > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Email sudah terdaftar!"
    ]);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

// Insert ke database
$query = $conn->prepare("
    INSERT INTO users (name, email, password, phone, address)
    VALUES (?, ?, ?, ?, ?)
");
$query->bind_param("sssss", $name, $email, $hashedPassword, $phone, $address);

if ($query->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Registrasi berhasil!"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal register!"
    ]);
}
?>
