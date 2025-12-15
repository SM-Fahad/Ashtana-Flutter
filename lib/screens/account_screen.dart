import 'package:ashtana/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:ashtana/services/auth_service.dart';
import 'package:ashtana/services/auth_service.dart';
import 'dart:convert';


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
                // Navigate back to auth screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),

            // Support Section
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Help Center',
                    subtitle: 'Get help with your orders',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.chat,
                    title: 'Contact Us',
                    subtitle: 'Get in touch with our team',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About Ashtana',
                    subtitle: 'Learn more about our app',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
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