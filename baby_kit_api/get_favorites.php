<?php
include "config.php";
header("Content-Type: application/json");

// Ambil user_id dari parameter GET
$user_id = $_GET['user_id'] ?? '';

// Validasi user_id
if(empty($user_id)){
    echo json_encode(['success'=>false, 'message'=>'User ID tidak valid']);
    exit; // hentikan eksekusi jika user_id kosong
}

// Query untuk mengambil produk yang difavoritkan oleh user tertentu
$sql = "SELECT p.product_id, p.name, p.price, p.image 
        FROM products p 
        JOIN favorites f ON p.product_id = f.product_id
        WHERE f.user_id = '$user_id'";

$result = mysqli_query($conn, $sql);

// Simpan hasil query ke array
$products = [];
while($row = mysqli_fetch_assoc($result)){
    $products[] = $row;
}

// Kirim response JSON berisi daftar produk favorit
echo json_encode(['success'=>true, 'products'=>$products]);
?>
