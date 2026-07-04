class Product {
  final String id;
  final String name;
  final String description;
  final num price;
  final String? imageKey;
  final int stock;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageKey,
    required this.stock,
    required this.rating,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? 'Unknown Product',
      description: data['description'] ?? 'No description',
      price: data['price'] ?? 0,
      imageKey: data['imageKey'],
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }
}
