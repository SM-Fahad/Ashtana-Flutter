class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imagePath;
  final int? categoryId;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imagePath,
    this.categoryId,
    this.stock = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      imagePath: map['image_path'],
      categoryId: map['category_id'],
      stock: map['stock'] ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'category_id': categoryId,
      'stock': stock,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}