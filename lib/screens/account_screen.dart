import 'package:ashtana/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:ashtana/services/auth_service.dart';
import 'package:ashtana/services/auth_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ashtana/services/database_service.dart';
import 'package:ashtana/models/cart_item.dart';
import 'package:ashtana/models/order.dart';
import 'package:intl/intl.dart';


class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            FutureBuilder<Map<String, dynamic>?>(
  future: AuthService.getUserInfo(),
  builder: (context, snapshot) {
    final userInfo = snapshot.data;
    final userName = userInfo?['userName'] ?? 'Guest';
    final userEmail = userInfo?['email'] ?? 'Not available';
    final firstName = userInfo?['userFirstName'] ?? '';
    final lastName = userInfo?['userLastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.deepPurple[50],
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple[100],
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fullName.isNotEmpty)
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Show token info dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Token Info'),
                        content: AuthService.token != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Token: ${AuthService.token!.substring(0, 30)}...'),
                                  const SizedBox(height: 10),
                                  Text('Expired: ${!AuthService.isAuthenticated}'),
                                  if (AuthService.decodeTokenPayload(AuthService.token!) != null)
                                    ...AuthService.decodeTokenPayload(AuthService.token!)!
                                      .entries
                                      .map((e) => Text('${e.key}: ${e.value}'))
                                      .toList(),
                                ],
                              )
                            : const Text('No token available'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('View Token Info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
),

            // Order Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusItem(
                            icon: Icons.payment,
                            label: 'To Pay',
                            count: 2,
                          ),
                          _buildStatusItem(
                            icon: Icons.local_shipping,
                            label: 'To Ship',
                            count: 1,
                          ),
                          _buildStatusItem(
                            icon: Icons.check_circle,
                            label: 'To Receive',
                            count: 0,
                          ),
                          _buildStatusItem(
                            icon: Icons.rate_review,
                            label: 'To Review',
                            count: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Items
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'My Orders',
                    subtitle: 'View your order history',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Shipping Address',
                    subtitle: 'Manage your addresses',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Payment Methods',
                    subtitle: 'Add or remove payment methods',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'My Favorites',
                    subtitle: 'View your saved items',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences and notifications',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Add this to your menu items list (before the support section)
            _buildMenuItem(
  icon: Icons.logout,
  title: 'Logout',
  subtitle: 'Sign out of your account',
  onTap: () async {
    await AuthService.clearToken();
    
    // Simply navigate to AuthScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false, // Remove all previous routes
    );
  },
),

            // Support Section
            

            // Logout Button
            
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.deepPurple[100],
              child: Icon(icon, color: Colors.deepPurple),
            ),
            if (count > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple[50],
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}



class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService.instance;
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  
  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;

  double get _shipping => widget.subtotal * 0.05;
  double get _tax => widget.subtotal * 0.08;
  double get _total => widget.subtotal + _shipping + _tax;

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create order
      final orderId = await _db.createOrder({
        'total_amount': _total,
        'shipping_address': '${_addressController.text}, ${_cityController.text}, ${_zipCodeController.text}',
        'payment_method': _selectedPaymentMethod,
      });

      // Add order items
      for (final item in widget.cartItems) {
        await _db.addOrderItem({
          'order_id': orderId,
          'product_id': item.productId,
          'product_name': item.productName,
          'product_price': item.productPrice,
          'quantity': item.quantity,
          'total_price': item.totalPrice,
        });
      }

      // Clear cart
      await _db.clearCart();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
        arguments: {'showOrderSuccess': true},
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = widget.cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} x${item.quantity}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildSummaryRow('Subtotal', widget.subtotal),
                      _buildSummaryRow('Shipping', _shipping),
                      _buildSummaryRow('Tax', _tax),
                      const Divider(),
                      _buildSummaryRow(
                        'Total',
                        _total,
                        isBold: true,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Shipping Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shipping Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your city';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              decoration: const InputDecoration(
                                labelText: 'ZIP Code',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter ZIP code';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment Method
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile(
                        title: const Text('Credit/Debit Card'),
                        value: 'card',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text('Cash on Delivery'),
                        value: 'cod',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text('Digital Wallet'),
                        value: 'wallet',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Place Order Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : null,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }
}