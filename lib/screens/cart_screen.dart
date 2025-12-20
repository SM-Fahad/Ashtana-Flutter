import 'package:flutter/material.dart';
import 'package:ashtana/services/database_service.dart';
import 'package:ashtana/models/cart_item.dart';
import 'package:ashtana/screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> _cartItemsFuture;
  final DatabaseService _db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      _cartItemsFuture = _getCartItems();
    });
  }

  Future<List<CartItem>> _getCartItems() async {
    final items = await _db.getCartItems();
    return items.map((item) => CartItem.fromMap(item)).toList();
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    await _db.updateCartQuantity(cartItemId, newQuantity);
    _loadCartItems();
  }

  Future<void> _removeItem(int cartItemId) async {
    await _db.removeFromCart(cartItemId);
    _loadCartItems();
  }

  Future<void> _clearCart() async {
    await _db.clearCart();
    _loadCartItems();
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Are you sure you want to clear your cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await _clearCart();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your bag is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add some items to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to home or categories
                      Navigator.of(context).pop();
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }
          
          final total = _calculateTotal(items);
          
          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                image: item.productImage != null
                                    ? DecorationImage(
                                        image: AssetImage(item.productImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.productImage == null
                                  ? const Icon(Icons.shopping_bag, color: Colors.grey)
                                  : null,
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.productPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: item.quantity > 1
                                            ? () => _updateQuantity(item.id, item.quantity - 1)
                                            : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          item.quantity.toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: item.quantity < item.stock
                                            ? () => _updateQuantity(item.id, item.quantity + 1)
                                            : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _removeItem(item.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Checkout Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 16)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping', style: TextStyle(fontSize: 16)),
                        Text(
                          '\$${(total * 0.05).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tax', style: TextStyle(fontSize: 16)),
                        Text(
                          '\$${(total * 0.08).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${(total * 1.13).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                cartItems: items,
                                subtotal: total,
                              ),
                            ),
                          ).then((_) {
                            _loadCartItems(); // Reload cart after checkout
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'PROCEED TO CHECKOUT',
                          style: TextStyle(fontSize: 16),
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