import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_assets.dart';

class ProducteInfo extends StatefulWidget {
  final String productId;

  const ProducteInfo({super.key, required this.productId});

  @override
  State<ProducteInfo> createState() => _ProducteInfoState();
}

class _ProducteInfoState extends State<ProducteInfo> {
  int _quantity = 1;
  DocumentSnapshot<Map<String, dynamic>>? _productDoc;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (!doc.exists) {
        setState(() {
          _errorMessage = 'Product not found';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _productDoc = doc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_productDoc == null) return;
    final product = _productDoc!.data()!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(widget.productId)
        .set({
      'name': product['name'],
      'description': product['description'],
      'price': product['price'],
      'imageKey': product['imageKey'],
      'quantity': _quantity,
      'total': (product['price'] ?? 0) * _quantity,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Cart")),
    );
  }

  Future<void> _addToFavorites() async {
    if (_productDoc == null) return;
    final product = _productDoc!.data()!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.productId)
        .set({
      'name': product['name'],
      'description': product['description'],
      'price': product['price'],
      'imageKey': product['imageKey'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to Favorites")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final product = _productDoc!.data()!;
    final totalPrice = (product['price'] ?? 0) * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text((product['name'] as String?) ?? 'منتج'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // صورة المنتج
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: () {
                final String? imageKey = product['imageKey'] as String?;
                final String? imagePath =
                    imageKey != null ? AppAssets.imagesMap[imageKey] : null;
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

          // باقي التفاصيل
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product['name'] as String?) ?? 'Product not found',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (product['description'] as String?) ?? 'No description',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Price: ${product['price'] ?? 0} EGP",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // التحكم في الكمية
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                      const Spacer(),
                      Text(
                        "Total: $totalPrice EGP",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // زرارين Cart و Favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add to Cart"),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addToFavorites,
                        icon: const Icon(Icons.favorite,color: Colors.red,),
                        label: const Text("Favorite",style: TextStyle(color: Colors.red),),
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Colors.red,
                        // ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
