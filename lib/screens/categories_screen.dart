import 'package:flutter/material.dart';
import 'package:ashtana/services/database_service.dart';
import 'package:ashtana/screens/product_list_screen.dart'; // Create this screen

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  final DatabaseService _db = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _db.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final categories = snapshot.data ?? [];
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(
                        categoryId: category['id'],
                        categoryName: category['name'],
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Category Image
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: category['image_path'] != null
                                ? DecorationImage(
                                    image: AssetImage(category['image_path']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: category['image_path'] == null
                              ? const Center(
                                  child: Icon(
                                    Icons.category,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                        
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        
                        // Category Name
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              category['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}