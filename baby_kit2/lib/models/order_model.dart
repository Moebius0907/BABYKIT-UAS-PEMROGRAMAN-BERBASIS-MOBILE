class Order {
  final int orderId;
  final String invoiceNumber;
  final int totalPrice;
  final String shippingMethod;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String status;
  final DateTime orderDate;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.invoiceNumber,
    required this.totalPrice,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: int.parse(json['order_id'].toString()),
      invoiceNumber: json['invoice_number'],
      totalPrice: double.parse(json['total_price'].toString()).toInt(),
      shippingMethod: json['shipping_method'],
      paymentMethod: json['payment_method'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      status: json['status'],
      orderDate: DateTime.parse(json['order_date']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final String productName;
  final String productImage;
  final int price;
  final int quantity;

  OrderItem({
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'],
      productImage: json['product_image'],
      price: double.parse(json['price'].toString()).toInt(),
      quantity: int.parse(json['quantity'].toString()),
    );
  }
}
