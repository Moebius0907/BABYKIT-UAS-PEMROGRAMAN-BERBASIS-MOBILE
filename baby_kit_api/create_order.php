<?php
// Set header response menjadi JSON
header('Content-Type: application/json');

// Include konfigurasi koneksi database
include 'config.php';

// Ambil data POST dari client (dengan default jika tidak ada)
$user_id = $_POST['user_id'] ?? '';
$invoice_number = $_POST['invoice_number'] ?? '';
$total_price = $_POST['total_price'] ?? 0;
$shipping_method = $_POST['shipping_method'] ?? '';
$payment_method = $_POST['payment_method'] ?? '';
$customer_name = $_POST['customer_name'] ?? '';
$customer_phone = $_POST['customer_phone'] ?? '';
$customer_address = $_POST['customer_address'] ?? '';
$order_items = json_decode($_POST['order_items'] ?? '[]', true); // decode JSON string menjadi array PHP

// Validasi data penting agar tidak kosong
if (empty($user_id) || empty($invoice_number) || empty($order_items)) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit; // hentikan eksekusi jika data tidak lengkap
}

// Mulai transaksi agar insert ke tabel orders dan order_items bersifat atomik
$conn->begin_transaction();

try {
    // 1. Insert data ke tabel orders
    $query = "INSERT INTO orders (user_id, invoice_number, total_price, shipping_method, payment_method, customer_name, customer_phone, customer_address, status, order_date) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'dikemas', NOW())";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("isdsssss", $user_id, $invoice_number, $total_price, $shipping_method, $payment_method, $customer_name, $customer_phone, $customer_address);
    $stmt->execute();
    
    $order_id = $conn->insert_id; // ambil ID order yang baru saja dibuat
    
    // 2. Insert data ke tabel order_items
    $query_item = "INSERT INTO order_items (order_id, product_name, product_image, price, quantity) VALUES (?, ?, ?, ?, ?)";
    $stmt_item = $conn->prepare($query_item);
    
    foreach ($order_items as $item) {
        // Bind parameter setiap item order
        $stmt_item->bind_param("issii", $order_id, $item['product_name'], $item['product_image'], $item['price'], $item['quantity']);
        $stmt_item->execute();
    }
    
    // Commit transaksi jika semua query berhasil
    $conn->commit();
    echo json_encode(['success' => true, 'order_id' => $order_id]);
    
} catch (Exception $e) {
    // Rollback transaksi jika terjadi error
    $conn->rollback();
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

// Tutup statement dan koneksi
$stmt->close();
$stmt_item->close();
$conn->close();
?>
