class CartItem {
  final String productId;
  final String name;
  final num price;
  final String? imageKey;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.imageKey,
    required this.quantity,
  });

  num get total => price * quantity;

  factory CartItem.fromFirestore(String id, Map<String, dynamic> data) {
    return CartItem(
      productId: id,
      name: data['name'] ?? 'Unknown Product',
      price: data['price'] ?? 0,
      imageKey: data['imageKey'],
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': '', // Assuming description is not stored in cart item
      'price': price,
      'imageKey': imageKey,
      'quantity': quantity,
      'total': total,
    };
  }
}
