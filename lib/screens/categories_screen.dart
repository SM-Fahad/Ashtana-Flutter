import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {
        'name': 'Electronics',
        'icon': Icons.phone_android,
        'color': Colors.blue[100],
        'count': 45,
      },
      {
        'name': 'Fashion',
        'icon': Icons.checkroom,
        'color': Colors.pink[100],
        'count': 120,
      },
      {
        'name': 'Home & Garden',
        'icon': Icons.home,
        'color': Colors.green[100],
        'count': 89,
      },
      {
        'name': 'Automotive',
        'icon': Icons.directions_car,
        'color': Colors.orange[100],
        'count': 34,
      },
      {
        'name': 'Sports',
        'icon': Icons.sports_soccer,
        'color': Colors.red[100],
        'count': 67,
      },
      {
        'name': 'Books',
        'icon': Icons.menu_book,
        'color': Colors.brown[100],
        'count': 156,
      },
      {
        'name': 'Beauty',
        'icon': Icons.spa,
        'color': Colors.purple[100],
        'count': 78,
      },
      {
        'name': 'Toys',
        'icon': Icons.toys,
        'color': Colors.yellow[100],
        'count': 56,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigate to category products
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: categories[index]['color'],
                      child: Icon(
                        categories[index]['icon'],
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      categories[index]['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${categories[index]['count']} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}