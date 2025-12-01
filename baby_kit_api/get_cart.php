<?php
include "config.php";
header("Content-Type: application/json");

// Ambil user_id dari GET
$user_id = $_GET['user_id'] ?? '';

// Validasi user_id
if (!$user_id) {
    echo json_encode(["success" => false, "message" => "User ID tidak ditemukan"]);
    exit; // hentikan eksekusi jika user_id kosong
}

// Query untuk mengambil data cart beserta info produk
$query = mysqli_query($conn, "
    SELECT cart.cart_id, cart.quantity, products.product_id, products.name, 
           products.price, products.image, products.description,
           products.category, products.sub_category
    FROM cart 
    JOIN products ON cart.product_id = products.product_id 
    WHERE cart.user_id='$user_id'
");

$items = [];

// Loop setiap item di cart
while ($row = mysqli_fetch_assoc($query)) {

    // Ambil info nutrisi dari tabel product_nutrition berdasarkan product_id
    $nutritionQuery = mysqli_query($conn, "
        SELECT nutrition_info FROM product_nutrition WHERE product_id = ".$row['product_id']
    );

    $nutrition = [];
    while ($n = mysqli_fetch_assoc($nutritionQuery)) {
        $nutrition[] = $n['nutrition_info']; // Simpan semua info nutrisi ke array
    }

    // Tambahkan data cart + produk + nutrisi ke response
    $items[] = [
        "cart_id" => $row['cart_id'],
        "quantity" => $row['quantity'],
        "product_id" => $row['product_id'],
        "name" => $row['name'],
        "price" => $row['price'],
        "image" => $row['image'],
        "description" => $row['description'],
        "category" => $row['category'],
        "sub_category" => $row['sub_category'],
        "nutrition" => $nutrition
    ];
}

// Kirim response JSON
echo json_encode([
    "success" => true,
    "cart" => $items
]);
?>
