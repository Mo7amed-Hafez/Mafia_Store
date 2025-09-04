import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_assets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _cartRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('cart');

  Future<void> _updateQuantity(String docId, int newQuantity) async {
    if (newQuantity < 1) return;
    final doc = await _cartRef.doc(docId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final num price = (data['price'] ?? 0) as num;
    await _cartRef.doc(docId).update({
      'quantity': newQuantity,
      'total': price * newQuantity,
    });
  }

  Future<void> _removeItem(String docId) async {
    await _cartRef.doc(docId).delete();
  }

  Future<void> _checkout(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
      num totalPrice) async {
    if (items.isEmpty) return;
    try {
      final batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('orders')
          .doc();
      batch.set(orderRef, {
        'createdAt': FieldValue.serverTimestamp(),
        'totalPrice': totalPrice,
        'itemsCount': items.length,
        'status': 'pending',
      });

      for (final item in items) {
        final data = item.data();
        batch.set(orderRef.collection('items').doc(item.id), data);
        batch.delete(_cartRef.doc(item.id));
      }

      await batch.commit();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  ' Un Error has Ocurred : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_shopping_cart,
                      size: 56, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Your cart is empty', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          num total = 0;
          for (final d in docs) {
            final data = d.data();
            final num price = (data['price'] ?? 0) as num;
            final int quantity = (data['quantity'] ?? 1) as int;
            total += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final String? imageKey = data['imageKey'] as String?;
                    final String? imagePath =
                        imageKey != null ? AppAssets.imagesMap[imageKey] : null;
                    final String name = (data['name'] as String?) ?? 'product';
                    final num price = (data['price'] ?? 0) as num;
                    final int quantity = (data['quantity'] ?? 1) as int;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: imagePath != null
                                  ? Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey),
                                    ),
                            ),
                          ),

                          // Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$price EGP',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Quantity controls
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () => _updateQuantity(
                                                  doc.id, quantity - 1),
                                            ),
                                            Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () => _updateQuantity(
                                                  doc.id, quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _removeItem(doc.id),
                                        tooltip: 'Remove item',
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Footer total and checkout
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 8,
                        offset: Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '$total EGP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton.icon(
                        onPressed: () => _checkout(docs, total),
                        icon: const Icon(Icons.payment),
                        label: const Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
