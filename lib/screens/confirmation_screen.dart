import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/cart_provider.dart';
import '../core/database_helper.dart';
import '../core/remote_database_service.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final DatabaseHelper _localDb = DatabaseHelper();
  final RemoteDatabaseService _remoteDb = RemoteDatabaseService();

  @override
  void initState() {
    super.initState();
    _processOrder();
  }

  Future<void> _processOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    final order = {
      'user_email': 'user@example.com', // Placeholder
      'total_amount': cart.subtotal + 10.0 + (cart.subtotal * 0.08),
      'shipping_address': cart.shippingAddress,
      'payment_method': 'Credit Card',
      'card_holder': cart.cardHolder,
      'card_number': cart.cardNumber,
      'expiry_date': cart.expiryDate,
      'status': 'Processing',
      'created_at': DateTime.now().toIso8601String(),
    };

    final items = cart.items.values.map((item) => {
      'outfit_title': item.outfit.title,
      'price': item.outfit.price ?? 49.99,
      'quantity': item.quantity,
    }).toList();

    // 1. Save to Local SQLite
    await _localDb.createOrder(order, items);

    // 2. Sync to Remote MySQL (XAMPP)
    await _remoteDb.createOrder(order, items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIRMATION', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text('Order Placed Successfully!', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Your order has been synced to our secure MySQL database.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().clearCart();
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppTheme.primaryGradient),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: const Text('BACK TO HOME', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
