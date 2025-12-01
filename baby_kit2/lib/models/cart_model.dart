class CartItem {
  final int cartId;
  final String productId;
  final String name;
  final String image;
  final String price;
  final String description;
  final String category;
  final String subCategory;
  final List<String> nutrition;
  int quantity;

  // Constructor
  CartItem({
    required this.cartId,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.nutrition,
    required this.quantity,
  });

  // Factory method untuk membuat CartItem dari JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: int.parse(json['cart_id']),
      productId: json['product_id'].toString(),
      name: json['name'],
      image: json['image'],
      price: json['price'],
      description: json['description'] ?? "-",
      category: json['category'] ?? "Produk",
      subCategory: json['sub_category'] ?? "Lainnya",
      nutrition: json["nutrition"] != null
          ? List<String>.from(json["nutrition"])
          : [],
      quantity: int.parse(json['quantity']),
    );
  }
}
