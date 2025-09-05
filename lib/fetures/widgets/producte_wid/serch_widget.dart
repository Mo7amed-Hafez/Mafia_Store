import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mafia_store/fetures/screens/productes/producte_info.dart';
import 'package:mafia_store/core/app_assets.dart';

class ProductSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showResults(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data!.docs;
        final results = allProducts.where((doc) {
          final product = doc.data() as Map<String, dynamic>;
          final name = (product['name'] ?? '').toString().toLowerCase();
          final description =
              (product['description'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            final productData = product.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: () {
                    final String? imageKey = productData['imageKey'] as String?;
                    final String? imagePath =
                        imageKey != null ? AppAssets.imagesMap[imageKey] : null;
                    if (imagePath != null) {
                      return AssetImage(imagePath);
                    }
                    return null;
                  }(),
                  child: () {
                    final String? imageKey = productData['imageKey'] as String?;
                    final String? imagePath =
                        imageKey != null ? AppAssets.imagesMap[imageKey] : null;
                    if (imagePath == null) {
                      return const Icon(Icons.image_not_supported);
                    }
                    return null;
                  }(),
                ),
                title: Text(
                  productData['name'] ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${productData['price'] ?? 0} EGP"),
                    if (productData['description'] != null)
                      Text(
                        productData['description'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Close search first
                  close(context, null);
                  // Add a small delay to ensure smooth transition
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProducteInfo(productId: product.id),
                        ),
                      );
                    }
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data!.docs;
        final suggestions = allProducts.where((doc) {
          final product = doc.data() as Map<String, dynamic>;
          final name = (product['name'] ?? '').toString().toLowerCase();
          final description =
              (product['description'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final product = suggestions[index];
            final productData = product.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(productData['name'] ?? 'Unknown Product'),
              subtitle: Text("${productData['price'] ?? 0} EGP"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProducteInfo(productId: product.id),
                  ),
                );
                close(context, null);
              },
            );
          },
        );
      },
    );
  }
}
