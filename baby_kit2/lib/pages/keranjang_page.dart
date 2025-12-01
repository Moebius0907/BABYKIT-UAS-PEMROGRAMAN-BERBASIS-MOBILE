import 'dart:convert';
import 'package:baby_kit2/models/cart_model.dart';
import 'package:baby_kit2/models/products.dart';
import 'package:baby_kit2/pages/product_detail.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baby_kit2/pages/checkout_page.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final SessionManager _session = SessionManager();
  String userId = '';
  bool selectAll = false;
  Map<int, bool> selectedItems = {}; // cartId -> selected

  Future<List<CartItem>> fetchCart() async {
    final session = await _session.getUserSession();
    userId = session['user_id'].toString();

    final response = await http.get(
      Uri.parse(
        "http://192.168.1.9/baby_kit_project/baby_kit_api/get_cart.php?user_id=$userId",
      ),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      final List raw = data['cart'];
      return raw.map((e) => CartItem.fromJson(e)).toList();
    }
    return [];
  }

  int getTotalSelected(List<CartItem> cartItems) {
    int total = 0;
    for (var item in cartItems) {
      if (selectedItems[item.cartId] == true) {
        final cleanPrice = int.parse(
          item.price.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        total += cleanPrice * item.quantity;
      }
    }
    return total;
  }

  int getSelectedCount(List<CartItem> cartItems) {
    int count = 0;
    for (var item in cartItems) {
      if (selectedItems[item.cartId] == true) {
        count++;
      }
    }
    return count;
  }

  void toggleSelectAll(List<CartItem> cartItems, bool value) {
    setState(() {
      selectAll = value;
      for (var item in cartItems) {
        selectedItems[item.cartId] = value;
      }
    });
  }

  void toggleSelectItem(int cartId, bool? value) {
    setState(() {
      selectedItems[cartId] = value ?? false;
      selectAll = !selectedItems.values.contains(false);
    });
  }

  Future<void> updateQuantity(
    int cartId,
    int newQty,
    String productName,
    bool isIncrease,
  ) async {
    final response = await http.post(
      Uri.parse(
        "http://192.168.1.9/baby_kit_project/baby_kit_api/update_qty.php",
      ),
      body: {"cart_id": cartId.toString(), "quantity": newQty.toString()},
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {});

      // Tampilkan notifikasi
      _showQuantitySnackBar(productName, newQty, isIncrease);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate quantity: ${data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQuantitySnackBar(
    String productName,
    int quantity,
    bool isIncrease,
  ) {
    final action = isIncrease ? 'ditambah' : 'dikurangi';
    final icon = isIncrease ? Icons.add : Icons.remove;
    final Color bgColor = isIncrease
        ? Colors.pinkAccent
        : const Color(0xFFD4A5C8);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isIncrease ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Jumlah item berhasil $action',
                style: TextStyle(
                  fontSize: 14,
                  color: isIncrease ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'OK',
          textColor: isIncrease ? Colors.white : Colors.black,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> deleteCartItem(int cartId, String productName) async {
    final response = await http.post(
      Uri.parse(
        "http://192.168.1.9/baby_kit_project/baby_kit_api/delete_cart.php",
      ),
      body: {"cart_id": cartId.toString()},
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$productName berhasil dihapus"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus item"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang Saya",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink[200],
        elevation: 0,
      ),
      body: FutureBuilder<List<CartItem>>(
        future: fetchCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keranjang masih kosong"));
          }

          final cartItems = snapshot.data!;
          for (var item in cartItems) {
            selectedItems.putIfAbsent(item.cartId, () => false);
          }

          return Column(
            children: [
              // Select All Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selectAll,
                      onChanged: (value) => toggleSelectAll(cartItems, value!),
                      activeColor: Colors.pink[300],
                    ),
                    const Text("Pilih semua"),
                  ],
                ),
              ),

              // List cart items
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final cleanPrice = int.parse(
                      item.price.replaceAll(RegExp(r'[^0-9]'), ''),
                    );
                    final totalPrice = cleanPrice * item.quantity;

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectedItems[item.cartId],
                            onChanged: (value) =>
                                toggleSelectItem(item.cartId, value),
                            activeColor: Colors.pink[300],
                          ),

                          // Gambar produk + klik ke detail
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(
                                    product: Product(
                                      product_id: item.productId,
                                      name: item.name,
                                      price: item.price,
                                      image: item.image,
                                      description: item.description,
                                      category: item.category,
                                      subCategory: item.subCategory,
                                      nutrition: item.nutrition,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[100],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          // Detail + quantity
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailPage(
                                            product: Product(
                                              product_id: item.productId,
                                              name: item.name,
                                              price: item.price,
                                              image: item.image,
                                              description: item.description,
                                              category: item.category,
                                              subCategory: item.subCategory,
                                              nutrition: item.nutrition,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp $totalPrice",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.pink[300],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Quantity + delete
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            updateQuantity(
                                              item.cartId,
                                              item.quantity - 1,
                                              item.name,
                                              false,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Quantity sudah minimum',
                                                ),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      Container(
                                        width: 30,
                                        alignment: Alignment.center,
                                        child: Text(item.quantity.toString()),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.pink[300],
                                        ),
                                        onPressed: () => updateQuantity(
                                          item.cartId,
                                          item.quantity + 1,
                                          item.name,
                                          true,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: () => deleteCartItem(
                                          item.cartId,
                                          item.name,
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

              // Bottom Checkout Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total (${getSelectedCount(cartItems)} item)",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Rp ${getTotalSelected(cartItems)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.pink[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Validasi apakah ada item yang dipilih
                            if (getSelectedCount(cartItems) == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pilih item yang ingin dicheckout',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            // Filter item yang dipilih
                            final selectedCartItems = cartItems
                                .where(
                                  (item) => selectedItems[item.cartId] == true,
                                )
                                .toList();

                            // Navigate ke checkout page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  selectedItems: selectedCartItems,
                                  subtotal: getTotalSelected(cartItems),
                                ),
                              ),
                            ).then((_) {
                              // Refresh cart setelah kembali dari checkout
                              setState(() {});
                            });
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[300],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Checkout",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
