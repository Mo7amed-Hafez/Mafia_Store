import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/fetures/screens/productes/producte_info.dart';
import 'package:mafia_store/fetures/widgets/producte_wid/serch_widget.dart';

class ProductesPage extends StatefulWidget {
  const ProductesPage({super.key});

  @override
  State<ProductesPage> createState() => _ProductesPageState();
}

class _ProductesPageState extends State<ProductesPage> {
  final Set<String> _favoriteIds = <String>{};
  ScaffoldMessengerState? _scaffoldMessenger;
  String _sortBy = 'name';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  }

  void _showSnack(String message) {
    if (!mounted || _scaffoldMessenger == null) return;
    _scaffoldMessenger!.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // دالة لإضافة للـ cart
  Future<void> _addToCart(Map<String, dynamic> product) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(product['id'])
        .set({
      'name': product['name'],
      'description': product['description'],
      'price': product['price'],
      'imageKey': product['imageKey'],
      'quantity': 1,
    });
  }

  // دالة لإضافة للـ favorites
  Future<void> _addToFavorites(Map<String, dynamic> product) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(product['id'])
        .set({
      'name': product['name'],
      'description': product['description'],
      'price': product['price'],
      'imageKey': product['imageKey'],
    });
  }

  // دالة لعرض فلاتر المنتجات
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sort Products'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sort By Filter
                  const Text('Sort By:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<String>(
                          value: 'name', child: Text('Name (A-Z)')),
                      DropdownMenuItem<String>(
                          value: 'name_desc', child: Text('Name (Z-A)')),
                      DropdownMenuItem<String>(
                          value: 'price', child: Text('Price (Low to High)')),
                      DropdownMenuItem<String>(
                          value: 'price_desc',
                          child: Text('Price (High to Low)')),
                      DropdownMenuItem<String>(
                          value: 'rating', child: Text('Rating (High to Low)')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortBy = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Update the main widget state
                      this.setState(() {});
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColore.primaryColor),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearch());
            },
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(Icons.tune_rounded, color: AppColore.primaryColor),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "Un Error has Ocurred: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No Products Found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final allProducts = snapshot.data!.docs;

          // Apply category filter - for now just show all products since we don't have category field
          List<QueryDocumentSnapshot> filteredProducts = allProducts;
          // TODO: Add category field to Firebase products if needed
          // if (_selectedCategory != 'All') {
          //   filteredProducts = allProducts.where((doc) {
          //     final product = doc.data() as Map<String, dynamic>;
          //     return product['category'] == _selectedCategory;
          //   }).toList();
          // }

          // Apply sorting
          filteredProducts.sort((a, b) {
            final productA = a.data() as Map<String, dynamic>;
            final productB = b.data() as Map<String, dynamic>;

            switch (_sortBy) {
              case 'price':
                return (productA['price'] ?? 0)
                    .compareTo(productB['price'] ?? 0);
              case 'price_desc':
                return (productB['price'] ?? 0)
                    .compareTo(productA['price'] ?? 0);
              case 'rating':
                return (productB['rating'] ?? 0)
                    .compareTo(productA['rating'] ?? 0);
              case 'name_desc':
                return (productB['name'] ?? '')
                    .compareTo(productA['name'] ?? '');
              case 'name':
              default:
                return (productA['name'] ?? '')
                    .compareTo(productB['name'] ?? '');
            }
          });

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product =
                  filteredProducts[index].data() as Map<String, dynamic>;
              product['id'] = filteredProducts[index].id;
              final String productId = filteredProducts[index].id;

              return GestureDetector(
                onTap: () {
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProducteInfo(productId: product['id'] as String),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: () {
                            final String? imageKey =
                                product['imageKey'] as String?;
                            final String? imagePath = imageKey != null
                                ? AppAssets.imagesMap[imageKey]
                                : null;
                            if (imagePath == null) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            );
                          }(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (product['name'] as String?) ?? "Unknown Product",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (product['description'] as String?) ??
                                  'No Description',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${product['price'] ?? 0} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart),
                                  onPressed: () async {
                                    await _addToCart(product);
                                    if (!mounted) return;
                                    _showSnack("Added to Cart");
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    _favoriteIds.contains(productId)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                  color: _favoriteIds.contains(productId)
                                      ? Colors.red
                                      : Colors.grey,
                                  onPressed: () async {
                                    final bool willBeFav =
                                        !_favoriteIds.contains(productId);
                                    setState(() {
                                      if (willBeFav) {
                                        _favoriteIds.add(productId);
                                      } else {
                                        _favoriteIds.remove(productId);
                                      }
                                    });
                                    if (willBeFav) {
                                      await _addToFavorites(product);
                                      if (!mounted) return;
                                      _showSnack("Added to Favorites");
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
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
