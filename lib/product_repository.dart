import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mafia_store/product.dart';


class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Product?> getProductById(String productId) async {
    try {
      if (productId.isEmpty) {
        throw Exception('Invalid product ID');
      }
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        return Product.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      // Log the error for debugging
      print('Error fetching product: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }
}
