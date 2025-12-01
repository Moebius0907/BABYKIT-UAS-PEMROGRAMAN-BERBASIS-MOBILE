class Product {
  final String product_id;
  final String name;
  final String price;
  final String image;
  final String description;
  final String category;
  final String subCategory;
  final List<String> nutrition;


  bool isFavorite;

  Product({
    required this.product_id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    this.subCategory = 'Lainnya',
    this.nutrition = const [],
    this.isFavorite = false, // default false
  });

  String get id => product_id;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product_id: json["product_id"]?.toString() ?? "",
      name: json["name"],
      price: json["price"],
      image: json["image"],
      description: json["description"],
      category: json["category"],
      subCategory: json["sub_category"] ?? 'Lainnya',
      nutrition: json["nutrition"] != null
          ? List<String>.from(json["nutrition"])
          : [],
      isFavorite: json["is_favorite"] == 1, // jika API mengirim
    );
  }

  String get safetyLevel {
    switch (category) {
      case "Makanan & Perlengkapan Lainnya":
        return "Food Grade / Aman Dikonsumsi";
      case "Obat & Suplemen Bayi":
        return "Dikonsultasikan dengan dokter / Gunakan sesuai dosis";
      case "Susu & Skincare Bayi":
        return "Aman untuk bayi / Bebas bahan berbahaya";
      default:
        return "Aman digunakan";
    }
  }
}
