import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/fetures/screens/productes/producte_info.dart';

class ProductesPage extends StatefulWidget {
  const ProductesPage({super.key});

  @override
  State<ProductesPage> createState() => _ProductesPageState();
}

class _ProductesPageState extends State<ProductesPage> {
  final Set<String> _favoriteIds = <String>{};
  ScaffoldMessengerState? _scaffoldMessenger;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        centerTitle: true,
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
                      "حدث خطأ أثناء تحميل المنتجات: ${snapshot.error}",
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
                    "لا توجد منتجات متاحة",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              product['id'] = products[index].id;
              final String productId = products[index].id;

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
                                  'لا يوجد وصف',
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
