import 'dart:convert';
import 'package:baby_kit2/models/products.dart';
import 'package:baby_kit2/pages/product_detail.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  final SessionManager _sessionManager = SessionManager();
  String userId = '';
  List<Product> _favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadUserData();
    await _loadFavoriteProducts();
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

  Future<void> _loadFavoriteProducts() async {
    if (userId.isEmpty) {
      setState(() {
        isLoading = false;
        _favoriteProducts = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

// Response dikirim ke get_favorites.php
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.9/baby_kit_project/baby_kit_api/get_favorites.php?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List productsJson = data['products'];
          setState(() {
            _favoriteProducts = productsJson.map((json) {
              // Buat Product pakai default value untuk field yang tidak dikirim API
              return Product(
                product_id: json["product_id"],
                name: json["name"],
                price: json["price"],
                image: json["image"],
                description: "",          // default kosong
                category: "Lainnya",      // default
                subCategory: "Lainnya",   // default
                nutrition: [],
                isFavorite: true,         // wajib true karena ini favorit
              );
            }).toList();
          });
        } else {
          setState(() {
            _favoriteProducts = [];
          });
        }
      } else {
        setState(() {
          _favoriteProducts = [];
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _favoriteProducts = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Product product) async {
    if (userId.isEmpty) {
      _showSnackBar('Silakan login terlebih dahulu', Icons.error, Colors.red);
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
          'is_favorite': '0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _favoriteProducts.removeWhere(
              (p) => p.product_id == product.product_id,
            );
          });
          _showSnackBar(
            '${product.name} dihapus dari favorit',
            Icons.favorite_border,
            Colors.red,
          );
        } else {
          _showSnackBar('Gagal menghapus favorit', Icons.error, Colors.red);
        }
      } else {
        _showSnackBar('Gagal terhubung ke server', Icons.error, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Icons.error, Colors.red);
    }
  }

  Future<void> _addToCart(Product product) async {
    if (userId.isEmpty) {
      _showSnackBar('Silakan login terlebih dahulu', Icons.error, Colors.red);
      return;
    }

    try {
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
            '${product.name} ditambahkan ke keranjang',
            Icons.shopping_cart,
            Colors.pink,
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

  void _showSnackBar(String message, IconData icon, Color? color) {
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
        backgroundColor: color ?? Colors.pink[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        title: const Text(
          "Produk Favorit",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.pink[100],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_favoriteProducts.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_favoriteProducts.length} Item",
                    style: TextStyle(
                      color: Colors.pink[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[300]!),
              ),
            )
          : _favoriteProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada produk favorit",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tambahkan produk favorit Anda di sini",
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavoriteProducts,
                  color: Colors.pink[400],
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = _favoriteProducts[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: product.image.startsWith('http')
                                        ? Image.network(
                                            product.image,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            product.image,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _removeFavorite(product),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.price,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink[400],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailPage(
                                                      product: product,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.pink[400],
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Lihat",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.pink[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.shopping_cart_outlined,
                                              color: Colors.pink[400],
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            onPressed: () => _addToCart(product),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
