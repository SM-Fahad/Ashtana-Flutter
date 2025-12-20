class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String? productImage;
  final int quantity;
  final int stock;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage,
    required this.quantity,
    required this.stock,
    required this.addedAt,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      productName: map['name'],
      productPrice: map['price'].toDouble(),
      productImage: map['image_path'],
      quantity: map['quantity'],
      stock: map['stock'] ?? 0,
      addedAt: DateTime.parse(map['added_at']),
    );
  }

  double get totalPrice => productPrice * quantity;
}