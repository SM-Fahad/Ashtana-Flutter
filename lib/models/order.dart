class Order {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String? shippingAddress;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    this.status = 'pending',
    this.shippingAddress,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderNumber: map['order_number'],
      totalAmount: map['total_amount'].toDouble(),
      status: map['status'],
      shippingAddress: map['shipping_address'],
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Processing';
    }
  }
}