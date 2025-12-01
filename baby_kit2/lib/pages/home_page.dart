import 'dart:convert';
import 'package:baby_kit2/models/products.dart';
import 'package:baby_kit2/pages/obat.dart';
import 'package:baby_kit2/pages/susu_skincare_bayi_page.dart';
import 'package:baby_kit2/pages/makanan_perlengkapan.dart';
import 'package:baby_kit2/pages/product_detail.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionManager _sessionManager = SessionManager();
  String userName = 'BayBox';
  bool isLoadingUser = true;
  String userId = '';

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
        userName = session['name']?.isNotEmpty == true
            ? session['name']!
            : 'BayBox';
        userId = session['user_id']?.toString() ?? '';
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        userName = 'BayBox';
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
          final limited = productsJson.take(6).toList();
          _products = limited.map((json) => Product.fromJson(json)).toList();
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
        Uri.parse('http://192.168.1.9/baby_kit_project/baby_kit_api/get_favorites.php'),
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

  Future<void> _addToCartDirectly(Product product) async {
    if (userId.isEmpty) {
      _showSnackBar(context, 'Silakan login terlebih dahulu', Icons.error);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9/baby_kit_project/baby_kit_api/add_to_cart.php'),
        body: {'user_id': userId, 'product_id': product.product_id},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _showSnackBar(context, 'Ditambahkan ke keranjang', Icons.shopping_cart);
        } else {
          _showSnackBar(context, data['message'] ?? 'Gagal menambahkan ke keranjang', Icons.error);
        }
      } else {
        _showSnackBar(context, 'Gagal terhubung ke server', Icons.error);
      }
    } catch (e) {
      _showSnackBar(context, 'Terjadi kesalahan: $e', Icons.error);
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
              Icon(Icons.favorite, color: Colors.pink[400], size: 24),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Obat & Suplemen Bayi':
        return const Color(0xFFC8A5D8);
      case 'Susu & Skincare Bayi':
        return const Color(0xFF9DC1E8);
      case 'Makanan & Perlengkapan Lainnya':
        return const Color(0xFFFFB5D8);
      default:
        return const Color(0xFFD4A5C8);
    }
  }

  Color _getSubCategoryColor(String subCategory) {
    int hash = subCategory.hashCode.abs();
    List<Color> pastelColors = [
      const Color(0xFFE5B8F4),
      const Color(0xFFB8D4F4),
      const Color(0xFFF4B8D8),
      const Color(0xFFD4B8F4),
      const Color(0xFFB8E5F4),
      const Color(0xFFFFC4DD),
    ];
    return pastelColors[hash % pastelColors.length];
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

  Widget _buildSubCategoryBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getSubCategoryColor(text).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getSubCategoryColor(text).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 45,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: product.image.startsWith('http')
                      ? Image.network(
                          product.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          product.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(product),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.isFavorite
                            ? Colors.pink[400]
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section (Name, Price, Detail)
          Expanded(
            flex: 55,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 18,
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _getCategoryColor(product.category),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    flex: 35,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.price,
                            style: TextStyle(
                              color: Colors.pink[500],
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink[400]!,
                                Colors.pink[300]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                await _addToCartDirectly(product);
                              },
                              child: const Icon(
                                Icons.shopping_cart_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pink[400],
                        elevation: 0,
                        side: BorderSide(
                          color: Colors.pink.shade200,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Lihat Detail",
                        style: TextStyle(
                          color: Colors.pink[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FaIcon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 140,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                isLoadingUser
                    ? SizedBox(
                        height: 24,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.pink[300]!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Memuat...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.pink.shade100.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade50.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari produk bayi...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.pink[300],
                    size: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pink[50],
                ),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidMessage,
                    color: Colors.pink[400],
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pink[50],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_rounded,
                    color: Colors.pink[400],
                    size: 24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    "assets/images/banner.jpg",
                    fit: BoxFit.cover,
                    height: 180,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCategory(
                    FontAwesomeIcons.pills,
                    "Obat & Suplemen Bayi",
                    const Color(0xFFC8A5D8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ObatSuplemenBayiPage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCategory(
                    FontAwesomeIcons.baby,
                    "Susu & Skincare Bayi",
                    const Color(0xFF9DC1E8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SusuSkincareBayiPage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildCategory(
                    FontAwesomeIcons.utensils,
                    "Makanan & Perlengkapan",
                    const Color(0xFFFFB5D8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MakananPerlengkapanPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.pink[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Produk Populer",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoadingProducts
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink[300]!,
                          ),
                        ),
                      ),
                    )
                  : _products.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              'Tidak ada produk',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) =>
                              _buildProductCard(context, _products[index]),
                        ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
