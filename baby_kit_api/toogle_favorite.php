<?php
include "config.php"; // koneksi database
header("Content-Type: application/json");

// ambil user_id dan product_id lewat POST
$user_id = $_POST['user_id'] ?? '';
$product_id = $_POST['product_id'] ?? '';

if(empty($user_id) || empty($product_id)){
    echo json_encode(['success'=>false, 'message'=>'User ID atau Product ID tidak valid']);
    exit;
}

// cek apakah sudah favorit
$sql_check = "SELECT * FROM favorites WHERE user_id='$user_id' AND product_id='$product_id'";
$result = mysqli_query($conn, $sql_check);

if(mysqli_num_rows($result) > 0){
    // hapus favorite
    mysqli_query($conn, "DELETE FROM favorites WHERE user_id='$user_id' AND product_id='$product_id'");
    echo json_encode(['success'=>true, 'action'=>'removed']);
} else {
    // tambah favorite
    mysqli_query($conn, "INSERT INTO favorites(user_id, product_id) VALUES('$user_id','$product_id')");
    echo json_encode(['success'=>true, 'action'=>'added']);
}
?>
