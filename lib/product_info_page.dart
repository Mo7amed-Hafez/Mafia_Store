import 'package:flutter/material.dart';
import 'package:mafia_store/cart_item.dart';
import 'package:mafia_store/cart_repository.dart';
import 'package:mafia_store/core/app_assets.dart';
import 'package:mafia_store/core/app_colore.dart';
import 'package:mafia_store/auth_service.dart';
import 'package:mafia_store/product.dart';
import 'package:mafia_store/product_repository.dart';

class ProductInfoPage extends StatefulWidget {
  final String productId;

  const ProductInfoPage({super.key, required this.productId});

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  int _quantity = 1;
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  // Dependencies
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productRepository.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          if (product == null) {
            _errorMessage = 'Product not found';
          } else {
            _product = product;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading product. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _showLoginSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login first")),
    );
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    final userId = _authService.currentUserId;
    if (userId == null) {
      _showLoginSnackbar();
      return;
    }

    try {
      final cartItem = CartItem(
        productId: _product!.id,
        name: _product!.name,
        price: _product!.price,
        imageKey: _product!.imageKey,
        quantity: _quantity,
      );
      await _cartRepository.addToCart(userId, cartItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Cart")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add to cart.")),
        );
      }
    }
  }

  Future<void> _addToFavorites() async {
    // Note: Favorites functionality is not fully implemented in this refactoring
    // to keep the scope focused, but the structure is here.
    if (_product == null) return;
    final userId = _authService.currentUserId;
    if (userId == null) {
      _showLoginSnackbar();
      return;
    }
    // TODO: Implement favorites repository and logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Favorites functionality coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    final product = _product!;
    final totalPrice = product.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // صورة المنتج
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: _buildProductImage(product.imageKey),
              ),
            ),

            // باقي التفاصيل
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Stock: ${product.stock}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColore.oliveGreen, // Assuming AppColore is defined
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rating: ${product.rating} ⭐",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColore.oliveGreen, // Assuming AppColore is defined
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Price: ${product.price} EGP",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // التحكم في الكمية
                  Row(children: [
                    // This could be extracted to its own StatefulWidget to isolate rebuilds
                    // For now, we keep it simple.
                    IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => setState(
                            () => _quantity = (_quantity - 1).clamp(1, 99))),
                    Text('$_quantity',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () => setState(
                            () => _quantity = (_quantity + 1).clamp(1, 99))),
                    const Spacer(),
                    Text(
                      "Total: $totalPrice EGP",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ]),

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
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Favorite",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageKey) {
    final String? imagePath =
        imageKey != null ? AppAssets.imagesMap[imageKey] : null;

    if (imagePath == null) {
      return Container(
        color: Colors.grey[300],
        child:
            const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported,
              size: 50, color: Colors.grey),
        );
      },
    );
  }

  Scaffold _buildErrorWidget() {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadProduct();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
