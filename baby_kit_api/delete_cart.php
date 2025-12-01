<?php
include "config.php";
header("Content-Type: application/json");

// ambil cart_id dengan method post
$cart_id = $_POST['cart_id'] ?? '';


// Jika cart_id tidak ditemukan
if (!$cart_id) {
    echo json_encode(["success" => false, "message" => "Cart ID tidak ditemukan"]);
    exit;
}

// query delete dri tabel cart
$query = "DELETE FROM cart WHERE cart_id='$cart_id'";
$result = mysqli_query($conn, $query);

//pengecekan hasil query
if ($result) {
    echo json_encode(["success" => true, "message" => "Item berhasil dihapus"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus item"]);
}
?>
