// import 'package:flutter/material.dart';
// import 'package:ashtana/screens/home_screen.dart';
// import 'package:ashtana/screens/categories_screen.dart';
// import 'package:ashtana/screens/cart_screen.dart';
// import 'package:ashtana/screens/favorites_screen.dart';
// import 'package:ashtana/screens/account_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ashtana',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   static final List<Widget> _pages = [
//     const HomeScreen(),
//     const CategoriesScreen(),
//     const CartScreen(),
//     const FavoritesScreen(),
//     const AccountScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category),
//             label: 'Categories',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag),
//             label: 'Bag',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: 'Favorites',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Account',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.deepPurple,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:ashtana/services/auth_service.dart';
// import 'package:ashtana/screens/splash_screen.dart';
// import 'package:ashtana/screens/auth_screen.dart';
// import 'package:ashtana/screens/main_screen.dart'; // Add this import

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize auth service to load stored token
//   await AuthService.init();
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ashtana',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const AuthWrapper(),
//     );
//   }
// }

// // AuthWrapper remains the same
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: Future.delayed(const Duration(seconds: 2)),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (AuthService.isAuthenticated) {
//             return const MainScreen(); // Now this points to the correct class
//           } else {
//             return const AuthScreen();
//           }
//         }
//         return const SplashScreen();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:ashtana/services/auth_service.dart';
import 'package:ashtana/screens/main_screen.dart';
import 'package:ashtana/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize auth service
  await AuthService.init();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  print('✅ App initialized - Database ready');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ashtana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const MainScreen(), // Start directly with main screen
    );
  }
}