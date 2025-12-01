<?php
header('Content-Type: application/json');
include 'config.php';

// Ambil user_id dari GET
$user_id = $_GET['user_id'] ?? '';

// Validasi user_id
if (empty($user_id)) {
    echo json_encode(['success' => false, 'message' => 'User ID required']);
    exit; // hentikan eksekusi jika user_id kosong
}

// Ambil semua order milik user tertentu, urut berdasarkan tanggal terbaru
try {
    $query = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $user_id); // "i" = integer
    $stmt->execute();
    $result = $stmt->get_result();
    
    $orders = [];
    
    // Loop setiap order
    while ($order = $result->fetch_assoc()) {
        $order_id = $order['order_id'];
        
        // Ambil semua item untuk order ini
        $items_query = "SELECT * FROM order_items WHERE order_id = ?";
        $items_stmt = $conn->prepare($items_query);
        $items_stmt->bind_param("i", $order_id);
        $items_stmt->execute();
        $items_result = $items_stmt->get_result();
        
        $items = [];
        while ($item = $items_result->fetch_assoc()) {
            $items[] = $item; // tambahkan item ke array
        }
        
        // Masukkan array item ke dalam order
        $order['items'] = $items;
        $orders[] = $order;
        
        // Tutup statement item
        $items_stmt->close();
    }
    
    // Kirim response JSON berisi semua order + items
    echo json_encode(['success' => true, 'orders' => $orders]);
    
    // Tutup statement order
    $stmt->close();
} catch (Exception $e) {
    // Tangani error
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

// Tutup koneksi database
$conn->close();
?>
