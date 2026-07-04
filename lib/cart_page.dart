import 'package:flutter/material.dart';
import 'package:mafia_store/cart_item.dart';
import 'package:mafia_store/cart_item_card.dart';
import 'package:mafia_store/cart_repository.dart';
import 'package:mafia_store/auth_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dependencies
  final CartRepository _cartRepository = CartRepository();
  final AuthService _authService = AuthService();

  Future<void> _checkout(List<CartItem> items) async {
    try {
      await _cartRepository.checkout(_authService.currentUserId!, items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserId;

    // Handle user not being logged in
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(
          child: Text('Please log in to see your cart.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _cartRepository.getCartStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_shopping_cart,
                      size: 56, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Your cart is empty',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final double totalPrice =
              items.fold(0, (sum, item) => sum + item.total);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemCard(
                      item: item,
                      onQuantityChanged: (newQuantity) {
                        _cartRepository.updateQuantity(
                            userId, item.productId, newQuantity);
                      },
                      onRemove: () {
                        _cartRepository.removeItem(userId, item.productId);
                      },
                    );
                  },
                ),
              ),
              _buildCheckoutFooter(context, totalPrice, items),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutFooter(
      BuildContext context, double totalPrice, List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: TextStyle(color: Colors.grey)),
                Text(
                  '$totalPrice EGP',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            child: ElevatedButton.icon(
              onPressed: items.isNotEmpty ? () => _checkout(items) : null,
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}
