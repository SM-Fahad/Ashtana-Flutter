import 'package:ashtana/screens/guest_account_screen.dart';
import 'package:ashtana/screens/guest_cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:ashtana/services/auth_service.dart';
import 'package:ashtana/screens/home_screen.dart';
import 'package:ashtana/screens/categories_screen.dart';
import 'package:ashtana/screens/cart_screen.dart';
import 'package:ashtana/screens/favorites_screen.dart';
import 'package:ashtana/screens/account_screen.dart';
import 'package:ashtana/screens/auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens that require authentication
  static const List<int> _protectedScreens = [2, 4]; // Cart (2) and Account (4)

  void _onItemTapped(int index) {
    // Check if the selected screen requires authentication
    if (_protectedScreens.contains(index) && !AuthService.isAuthenticated) {
      // Show auth screen instead
      _showAuthScreen(context, index);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAuthScreen(BuildContext context, int targetScreen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          onSuccess: () {
            // After successful login, navigate to the target screen
            setState(() {
              _selectedIndex = targetScreen;
            });
            Navigator.of(context).pop(); // Close auth screen
          },
          requiredFor: _getScreenName(targetScreen),
        ),
      ),
    );
  }

  String _getScreenName(int index) {
    switch (index) {
      case 2:
        return 'Cart';
      case 4:
        return 'Account';
      default:
        return 'this feature';
    }
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoriesScreen();
      case 2:
        return AuthService.isAuthenticated
            ? const CartScreen()
            : const GuestCartScreen(); // We'll create this
      case 3:
        return const FavoritesScreen();
      case 4:
        return AuthService.isAuthenticated
            ? const AccountScreen()
            : const GuestAccountScreen(); // We'll create this
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
