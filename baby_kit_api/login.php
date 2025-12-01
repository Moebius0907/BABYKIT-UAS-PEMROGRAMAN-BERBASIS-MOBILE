<?php
header("Content-Type: application/json");
include "config.php";

// Jika diakses lewat browser menggunakan GET, beri peringatan
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    echo json_encode([
        "success" => false,
        "message" => "Gunakan POST method untuk login."
    ]);
    exit;
}

// Jika request POST
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // Ambil email dan password dari request POST
    $email = $_POST["email"] ?? "";
    $password = $_POST["password"] ?? "";

    // Validasi input
    if (empty($email) || empty($password)) {
        echo json_encode([
            "success" => false,
            "message" => "Email dan password wajib diisi!"
        ]);
        exit;
    }

    // Cek user berdasarkan email
    $query = mysqli_query($conn, "SELECT * FROM users WHERE email='$email' LIMIT 1");

    // Jika email tidak ditemukan
    if (mysqli_num_rows($query) == 0) {
        echo json_encode([
            "success" => false,
            "message" => "Akun tidak ditemukan!"
        ]);
        exit;
    }

    $user = mysqli_fetch_assoc($query);

    // Cek password yang di-hash
    if (password_verify($password, $user['password'])) {
        
        // Hapus password dari response untuk keamanan
        unset($user['password']);
        
        // Kirim response sukses
        echo json_encode([
            "success" => true,
            "message" => "Login berhasil!",
            "data" => $user
        ]);

    } else {
        // Password salah
        echo json_encode([
            "success" => false,
            "message" => "Password salah!"
        ]);
    }
}
?>
