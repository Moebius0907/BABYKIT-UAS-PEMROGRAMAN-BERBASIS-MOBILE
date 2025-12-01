import 'dart:convert';
import 'package:baby_kit2/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:baby_kit2/models/products.dart';
import 'package:baby_kit2/pages/checkout_page.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:http/http.dart' as http;

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final SessionManager _sessionManager = SessionManager();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final session = await _sessionManager.getUserSession();
      setState(() {
        userId = session['user_id']?.toString() ?? '';
      });
    } catch (e) {
      setState(() {
        userId = '';
      });
    }
  }

  Future<void> _addToCartDirectly(Product product) async {
    try {
      if (userId.isEmpty) {
        _showSnackBar('Silakan login terlebih dahulu', Icons.error, Colors.red);
        return;
      }

      if (product.product_id.isEmpty) {
        _showSnackBar('Product ID tidak valid', Icons.error, Colors.red);
        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://192.168.1.9/baby_kit_project/baby_kit_api/add_to_cart.php',
        ),
        body: {'user_id': userId, 'product_id': product.product_id},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _showSnackBar(
            'Ditambahkan ke keranjang',
            Icons.shopping_cart,
            Colors.pink[400]!,
          );
        } else {
          _showSnackBar(
            data['message'] ?? 'Gagal menambahkan ke keranjang',
            Icons.error,
            Colors.red,
          );
        }
      } else {
        _showSnackBar('Gagal terhubung ke server', Icons.error, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Icons.error, Colors.red);
    }
  }

void _toggleFavorite(Product product) async {
  // Jika menambah favorit (bukan menghapus), langsung eksekusi
  if (!product.isFavorite) {
    _executeToggleFavorite(product, true);
    return;
  }

  // Jika menghapus favorit, tampilkan konfirmasi
  _showDeleteConfirmation(product);
}

void _executeToggleFavorite(Product product, bool newStatus) async {
  setState(() {
    product.isFavorite = newStatus;
  });

  if (userId.isEmpty) {
    _showSnackBar('Silakan login terlebih dahulu', Icons.error, Colors.red);
    setState(() {
      product.isFavorite = !newStatus;
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(
        'http://192.168.1.9/baby_kit_project/baby_kit_api/toogle_favorite.php',
      ),
      body: {
        'user_id': userId,
        'product_id': product.product_id,
        'is_favorite': newStatus ? '1' : '0',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        _showSnackBar(
          newStatus ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
          newStatus ? Icons.favorite : Icons.favorite_border,
          Colors.pink[400]!,
        );
      } else {
        setState(() {
          product.isFavorite = !newStatus;
        });
        _showSnackBar('Gagal update favorit', Icons.error, Colors.red);
      }
    } else {
      setState(() {
        product.isFavorite = !newStatus;
      });
      _showSnackBar('Gagal terhubung ke server', Icons.error, Colors.red);
    }
  } catch (e) {
    setState(() {
      product.isFavorite = !newStatus;
    });
    _showSnackBar('Terjadi kesalahan: $e', Icons.error, Colors.red);
  }
}

void _showDeleteConfirmation(Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.pink[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Favorit?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.name}" dari daftar favorit?',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              _executeToggleFavorite(product, false); // Hapus dari favorit
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      );
    },
  );
}

  void _showSnackBar(String message, IconData icon, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Contoh ulasan statis
    final List<Map<String, String>> reviews = [
      {"user": "Delia", "comment": "Produk sangat bagus dan sesuai deskripsi."},
      {"user": "Andi", "comment": "Anak saya suka sekali, kualitas oke!"},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          "Detail Produk",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.pink[100],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk + kategori
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: product.image.startsWith('http')
                        ? Image.network(
                            product.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          )
                        : product.image.isNotEmpty
                        ? Image.asset(
                            product.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 50,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: Colors.pink[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nama + favorit + harga
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: product.isFavorite
                              ? Colors.pink[50]
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: product.isFavorite
                                ? Colors.pink[400]
                                : Colors.grey[400],
                            size: 28,
                          ),
                          onPressed: () => _toggleFavorite(product),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Harga
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.green[700],
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.price,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Deskripsi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Colors.pink[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Keamanan & Gizi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.health_and_safety_outlined,
                          color: Colors.orange[400],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Informasi Keamanan & Gizi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Keamanan: ${product.safetyLevel}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (product.nutrition.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: Colors.blue[700],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Informasi Gizi:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...product.nutrition.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tombol aksi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validasi user login
                        if (userId.isEmpty) {
                          _showSnackBar(
                            'Silakan login terlebih dahulu',
                            Icons.error,
                            Colors.red,
                          );
                          return;
                        }

                        // Buat CartItem dari Product untuk checkout langsung
                        final cartItem = CartItem(
                          cartId: 0, // ID sementara karena langsung checkout
                          productId: product.product_id,
                          name: product.name,
                          price: product.price,
                          image: product.image,
                          quantity: 1, // Default quantity 1
                          description: product.description,
                          category: product.category,
                          subCategory: product.subCategory,
                          nutrition: product.nutrition,
                        );

                        // Parse harga untuk subtotal
                        final cleanPrice = int.parse(
                          product.price.replaceAll(RegExp(r'[^0-9]'), ''),
                        );

                        // Navigate ke checkout
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              selectedItems: [cartItem],
                              subtotal: cleanPrice,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.payment, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Pesan Sekarang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _addToCartDirectly(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Tambah ke Keranjang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Section ulasan produk
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ulasan Produk",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.pink[100],
                            child: Text(
                              review["user"]![0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review["user"]!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(review["comment"]!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
