<?php
include "config.php";
header("Content-Type: application/json");

// Pengecekan apakah data POST tersedia
$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : '';
$product_id = isset($_POST['product_id']) ? $_POST['product_id'] : '';
$qty = 1;

// Pengkondisian jika user_id dan product_id kosong
if(empty($user_id) || empty($product_id)) {
    // respon jika kosong 
    echo json_encode([
        "success" => false,
        "message" => "User ID atau Product ID tidak boleh kosong"
    ]);
    exit;
}

// Pengecekan apakah produk sudah ada di cart
$query = $conn->query("SELECT * FROM cart WHERE user_id='$user_id' AND product_id='$product_id'");

// Pengkondisian jika produk sudah ada di cart 
if($query && $query->num_rows > 0){
    // update qty 
    $update = $conn->query("UPDATE cart SET quantity = quantity + 1 WHERE user_id='$user_id' AND product_id='$product_id'");
    if($update){
        echo json_encode([
            "success" => true,
            "message" => "Jumlah diperbarui"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Gagal memperbarui jumlah"
        ]);
    }
} else { // Pengkondisian jika produk belum ada di cart, auto insert ke cart
    $insert = $conn->query("INSERT INTO cart (user_id, product_id, quantity) VALUES ('$user_id', '$product_id', '$qty')");
    if($insert){
        echo json_encode([
            "success" => true,
            "message" => "Berhasil ditambahkan"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Gagal menambahkan ke cart"
        ]);
    }
}
