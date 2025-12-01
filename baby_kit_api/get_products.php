<?php
header("Content-Type: application/json");
include "config.php";

// Ambil semua produk dari tabel products
$query = mysqli_query($conn, "SELECT * FROM products");

$products = [];

// Loop setiap produk
while ($row = mysqli_fetch_assoc($query)) {

    // Ambil info nutrisi untuk produk ini dari tabel product_nutrition
    $nutriQuery = mysqli_query($conn, 
        "SELECT nutrition_info FROM product_nutrition WHERE product_id = ".$row['product_id']
    );

    $nutrition = [];
    while ($n = mysqli_fetch_assoc($nutriQuery)) {
        $nutrition[] = $n['nutrition_info']; // Simpan semua info nutrisi ke array
    }

    // Masukkan data produk + nutrisi ke array response
    $products[] = [
        "product_id" => $row['product_id'],
        "name" => $row['name'],
        "price" => $row['price'],
        "image" => $row['image'],
        "description" => $row['description'],
        "category" => $row['category'],          // Kategori utama
        "sub_category" => $row['sub_category'],  // Subkategori baru
        "nutrition" => $nutrition
    ];
}

// Kirim response JSON berisi semua produk
echo json_encode([
    "success" => true,
    "products" => $products
]);
?>
