import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafia_store/cart_item.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCartRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  Stream<List<CartItem>> getCartStream(String userId) {
    return _getCartRef(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> addToCart(String userId, CartItem item) async {
    await _getCartRef(userId).doc(item.productId).set(item.toJson());
  }

  Future<void> updateQuantity(
      String userId, String productId, int newQuantity) async {
    if (newQuantity < 1) {
      await removeItem(userId, productId);
      return;
    }
    final docRef = _getCartRef(userId).doc(productId);
    final doc = await docRef.get();
    if (doc.exists) {
      final price = doc.data()?['price'] ?? 0;
      await docRef.update({
        'quantity': newQuantity,
        'total': price * newQuantity,
      });
    }
  }

  Future<void> removeItem(String userId, String productId) async {
    await _getCartRef(userId).doc(productId).delete();
  }

  Future<void> checkout(String userId, List<CartItem> items) async {
    if (items.isEmpty) return;

    final batch = _firestore.batch();
    final userOrdersRef =
        _firestore.collection('users').doc(userId).collection('orders');
    final newOrderRef = userOrdersRef.doc();

    final double totalPrice = items.fold(0, (sum, item) => sum + item.total);

    batch.set(newOrderRef, {
      'createdAt': FieldValue.serverTimestamp(),
      'totalPrice': totalPrice,
      'itemsCount': items.length,
      'status': 'pending',
    });

    for (final item in items) {
      batch.set(
          newOrderRef.collection('items').doc(item.productId), item.toJson());
      batch.delete(_getCartRef(userId).doc(item.productId));
    }

    await batch.commit();
  }
}
