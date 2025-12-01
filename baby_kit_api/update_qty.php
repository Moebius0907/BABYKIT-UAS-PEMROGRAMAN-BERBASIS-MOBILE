<?php
include "config.php";

// ambil cart_id dan quantity lewat POST
$cart_id = $_POST['cart_id'];
$quantity = $_POST['quantity'];

// update qty 
if ($cart_id && $quantity) {
    $query = $conn->query("UPDATE cart SET quantity='$quantity' WHERE cart_id='$cart_id'");
    
    if ($query) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false]);
    }
}
?>
