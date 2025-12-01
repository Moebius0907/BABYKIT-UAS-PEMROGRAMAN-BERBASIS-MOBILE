import 'dart:convert';
import 'package:baby_kit2/models/products.dart';
import 'package:baby_kit2/pages/product_detail.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ObatSuplemenBayiPage extends StatefulWidget {
  const ObatSuplemenBayiPage({super.key});

  @override
  State<ObatSuplemenBayiPage> createState() => _ObatSuplemenBayiPageState();
}

class _ObatSuplemenBayiPageState extends State<ObatSuplemenBayiPage> {
  final List<String> categories = ["Semua", "Demam/Flu", "Vitamin", "Lainnya"];
  String selectedCategory = "Semua";

  final SessionManager _sessionManager = SessionManager();
  String userId = '';
  bool isLoadingUser = true;

  List<Product> _products = [];
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadUserData();
    await fetchProducts();
    await _loadFavorites();
  }

  Future<void> _loadUserData() async {
    try {
      final session = await _sessionManager.getUserSession();
      setState(() {
        userId = session['user_id']?.toString() ?? '';
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        userId = '';
        isLoadingUser = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoadingProducts = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.9/baby_kit_project/baby_kit_api/get_products.php',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List productsJson = data['products'];
          final obatProducts = productsJson
              .where(
                (p) => p['category'].toString().toLowerCase().contains('obat'),
              )
              .toList();
          _products = obatProducts
              .map((json) => Product.fromJson(json))
              .toList();
        } else {
          _products = [];
        }
      } else {
        _products = [];
      }
    } catch (e) {
      _products = [];
    } finally {
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    if (userId.isEmpty || _products.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.1.9/baby_kit_project/baby_kit_api/get_favorites.php',
        ),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<String> favoriteIds = List<String>.from(data['favorites']);
          setState(() {
            for (var product in _products) {
              product.isFavorite = favoriteIds.contains(product.product_id);
            }
          });
        }
      }
    } catch (e) {
      print('Gagal load favorites: $e');
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
    _showSnackBar(context, 'Silakan login terlebih dahulu', Icons.error);
    setState(() {
      product.isFavorite = !newStatus;
    });
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.9/baby_kit_project/baby_kit_api/toogle_favorite.php'),
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
          context,
          newStatus ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
          newStatus ? Icons.favorite : Icons.favorite_border,
        );
      } else {
        setState(() {
          product.isFavorite = !newStatus;
        });
        _showSnackBar(context, 'Gagal update favorit', Icons.error);
      }
    } else {
      setState(() {
        product.isFavorite = !newStatus;
      });
      _showSnackBar(context, 'Gagal terhubung ke server', Icons.error);
    }
  } catch (e) {
    setState(() {
      product.isFavorite = !newStatus;
    });
    _showSnackBar(context, 'Terjadi kesalahan: $e', Icons.error);
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

  Future<void> _addToCartDirectly(Product product) async {
    if (userId.isEmpty) {
      _showSnackBar(context, 'Silakan login terlebih dahulu', Icons.error);
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
            context,
            'Ditambahkan ke keranjang',
            Icons.shopping_cart,
          );
        } else {
          _showSnackBar(
            context,
            data['message'] ?? 'Gagal menambahkan ke keranjang',
            Icons.error,
          );
        }
      } else {
        _showSnackBar(context, 'Gagal terhubung ke server', Icons.error);
      }
    } catch (e) {
      _showSnackBar(context, 'Terjadi kesalahan: $e', Icons.error);
    }
  }

  void _showSnackBar(BuildContext context, String message, IconData icon) {
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
        backgroundColor: Colors.pink[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == "Semua"
        ? _products
        : _products
              .where(
                (p) =>
                    p.subCategory != null &&
                    p.subCategory!.toLowerCase() ==
                        selectedCategory.toLowerCase(),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: false,
        title: const Text(
          "Obat & Suplemen Bayi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilihan kategori
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.pink[200],
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) =>
                      setState(() => selectedCategory = category),
                );
              },
            ),
          ),
          Expanded(
            child: isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? const Center(child: Text("Tidak ada produk"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final produk = filteredProducts[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar + favorit
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      produk.image,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _toggleFavorite(produk),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          produk.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: produk.isFavorite
                                              ? Colors.red
                                              : Colors.grey[400],
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Info produk
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        produk.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      produk.price,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProductDetailPage(
                                                        product: produk,
                                                      ),
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.pink.shade100,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Lihat",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          width: 36,
                                          height: 32,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.shopping_cart,
                                              color: Colors.pink.shade200,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _addToCartDirectly(produk),
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
        ],
      ),
    );
  }
}
