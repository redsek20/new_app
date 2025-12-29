import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MY BAG',
            style: TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Use the new Matte Dark theme
        child: cart.items.isEmpty
            ? _buildEmptyCart(context)
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          20, 100, 20, 20), // Top padding for AppBar
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items.values.toList()[index];
                        return _buildCartItem(context, item, index);
                      },
                    ),
                  ),
                  _buildOrderSummary(context, cart),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface, // Solid surface
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 60, color: Colors.white54),
          ).animate().scale().fadeIn(),
          const SizedBox(height: 24),
          const Text('Your bag is empty',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start Shopping',
                style: TextStyle(fontSize: 16, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    return Dismissible(
      key: Key(item.outfit.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6584), // Secondary red
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<CartProvider>().removeItem(item.outfit.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface, // Solid card color from theme (262A34)
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(item.outfit.imageUrl,
                  width: 90, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.outfit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('${item.outfit.price.toStringAsFixed(0)} MAD',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 12), // Spacing
                  Container(
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF181A20), // Darker background for pill
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQtyBtn(
                            Icons.remove,
                            () => context
                                .read<CartProvider>()
                                .removeOneItem(item.outfit.id)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('${item.quantity}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        _buildQtyBtn(
                            Icons.add,
                            () => context
                                .read<CartProvider>()
                                .addItem(item.outfit)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX();
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    double shipping = 50.0;
    double tax = cart.subtotal * 0.20;
    double total = cart.subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24,
          110), // Reduced bottom pad slightly but maintained clearance
      decoration: BoxDecoration(
        color: AppTheme.surface, // Standardized Surface Color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, -10))
        ],
        border:
            Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
              'Subtotal', '${cart.subtotal.toStringAsFixed(0)} MAD'),
          const SizedBox(height: 12),
          _buildSummaryRow('Shipping', '${shipping.toStringAsFixed(0)} MAD'),
          const SizedBox(height: 12),
          _buildSummaryRow('VAT (20%)', '${tax.toStringAsFixed(0)} MAD'),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildSummaryRow('Total', '${total.toStringAsFixed(0)} MAD',
              isTotal: true),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .pushNamed('/shipping'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: AppTheme.primary.withValues(alpha: 0.6),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppTheme.primaryGradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('PROCEED TO CHECKOUT',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white)),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20)
                  ],
                ),
              ),
            ),
          ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white54,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
            )),
        Text(value,
            style: TextStyle(
              color: isTotal ? AppTheme.primary : Colors.white,
              fontSize: isTotal ? 22 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            )),
      ],
    );
  }
}
