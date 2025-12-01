import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPesanan extends StatelessWidget {
  final Map<String, dynamic> order;

  const DetailPesanan({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final products = List<Map<String, dynamic>>.from(order['products']);
    final currencyFormatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Hitung subtotal produk (tanpa ongkir)
    int subtotalProducts = 0;
    for (var product in products) {
      subtotalProducts += (product['price'] as int) * (product['qty'] as int);
    }

    // Ongkir (asumsi total - subtotal = ongkir)
    int shippingCost = (order['total'] as int) - subtotalProducts;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER STRUK (STATUS)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor(order['status']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _statusIcon(order['status']),
                      size: 48,
                      color: _statusColor(order['status']),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    order['status'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(order['status']),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage(order['status']),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // INFO PESANAN
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Pesanan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow("No. Invoice", order['id']),
                  _buildDivider(),
                  _buildInfoRow("Tanggal Pesanan", order['date']),
                  _buildDivider(),
                  _buildInfoRow("Metode Pembayaran", order['payment'] ?? "-"),
                  _buildDivider(),
                  _buildInfoRow("Kurir", order['shipping'] ?? "-"),
                ],
              ),
            ),

            const SizedBox(height: 12),

      
            // ALAMAT PENGIRIMAN
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.pink[400],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Alamat Pengiriman",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order['customer']['name'] ?? "-",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['customer']['phone'] ?? "-",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order['customer']['address'] ?? "-",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

     
            // DAFTAR PRODUK
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Produk yang Dibeli",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...products.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final isLast = index == products.length - 1;

                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                product['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${currencyFormatter.format(product['price'])} x ${product['qty']}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(
                                          product['price'] * product['qty'],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isLast) ...[
                          const SizedBox(height: 16),
                          Divider(height: 1, color: Colors.grey[200]),
                          const SizedBox(height: 16),
                        ],
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 12),

           
            // RINCIAN PEMBAYARAN
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rincian Pembayaran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentRow(
                    "Subtotal Produk",
                    currencyFormatter.format(subtotalProducts),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentRow(
                    "Ongkos Kirim",
                    currencyFormatter.format(shippingCost),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Pembayaran",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(order['total']),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FOOTER INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Simpan struk ini sebagai bukti pembelian Anda",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

   
            // TOMBOL CETAK STRUK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showReceiptDialog(
                    context,
                    products,
                    currencyFormatter,
                    subtotalProducts,
                    shippingCost,
                  );
                },
                icon: const Icon(Icons.receipt_long, size: 20),
                label: const Text(
                  "Cetak Struk",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200], thickness: 1);
  }

  // Icon berdasarkan status
  IconData _statusIcon(String status) {
    switch (status) {
      case "Dikemas":
        return Icons.inventory_2;
      case "Diantarkan":
        return Icons.local_shipping;
      case "Diterima":
        return Icons.check_circle;
      default:
        return Icons.receipt;
    }
  }

  // Warna status
  Color _statusColor(String status) {
    switch (status) {
      case "Dikemas":
        return Colors.orange;
      case "Diantarkan":
        return Colors.blue;
      case "Diterima":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Pesan status
  String _statusMessage(String status) {
    switch (status) {
      case "Dikemas":
        return "Pesanan Anda sedang dikemas dan akan segera dikirim";
      case "Diantarkan":
        return "Pesanan Anda sedang dalam perjalanan";
      case "Diterima":
        return "Pesanan telah berhasil diterima. Terima kasih!";
      default:
        return "";
    }
  }

  // Dialog struk thermal
  void _showReceiptDialog(
    BuildContext context,
    List<Map<String, dynamic>> products,
    NumberFormat currencyFormatter,
    int subtotalProducts,
    int shippingCost,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Dialog
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400]!, Colors.pink[300]!],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Struk Pembayaran",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Struk Content
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo / Nama Toko
                        Text(
                          "BayBox Store",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Toko Perlengkapan Bayi Terpercaya",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Jl. Merdeka No. 123, Jakarta",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Telp: (021) 1234-5678",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Garis pemisah
                        _buildDashedLine(),

                        const SizedBox(height: 16),

                        // Info Transaksi
                        _buildReceiptRow("No. Invoice", order['id']),
                        _buildReceiptRow("Tanggal", order['date']),
                        _buildReceiptRow("Kasir", "Admin BayBox"),

                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 16),

                        // Daftar Produk
                        ...products.map((product) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${product['qty']} x ${currencyFormatter.format(product['price'])}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        product['price'] * product['qty'],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 12),

                        // Subtotal & Ongkir
                        _buildReceiptRow(
                          "Subtotal",
                          currencyFormatter.format(subtotalProducts),
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptRow(
                          "Ongkos Kirim",
                          currencyFormatter.format(shippingCost),
                        ),

                        const SizedBox(height: 12),
                        Container(height: 2, color: Colors.grey[800]),
                        const SizedBox(height: 12),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "TOTAL",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(order['total']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildDashedLine(),
                        const SizedBox(height: 16),

                        // Pembayaran & Pengiriman
                        _buildReceiptRow("Pembayaran", order['payment'] ?? "-"),
                        const SizedBox(height: 8),
                        _buildReceiptRow("Kurir", order['shipping'] ?? "-"),

                        const SizedBox(height: 20),
                        _buildDashedLine(),
                        const SizedBox(height: 16),

                        // Footer
                        Text(
                          "TERIMA KASIH",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Barang yang sudah dibeli\ntidak dapat dikembalikan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "www.baybox.com",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // QR Code atau Barcode (optional)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order['id'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implementasi share
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fitur share akan segera hadir!"),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("Bagikan"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.pink[400],
                          side: BorderSide(color: Colors.pink[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementasi download/print
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Struk berhasil disimpan!"),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text("Simpan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk row di struk
  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Garis putus-putus
  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        50,
        (index) => Expanded(
          child: Container(
            height: 1,
            color: index % 2 == 0 ? Colors.grey[400] : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
