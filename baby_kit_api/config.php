<?php
// Konfigurasi ke database 
$host = "localhost";
$user = "root"; 
$pass = "";
$db   = "baby_kit_db"; //nama db nya 

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
