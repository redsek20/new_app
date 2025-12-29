import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/cart_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();

  // Payment Selection
  String _selectedMethod = 'card'; // card, apple, google

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAYMENT',
            style: TextStyle(
                letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Payment Methods Row
            Row(
              children: [
                _buildPaymentOption('card', Icons.credit_card, 'Card'),
                const SizedBox(width: 12),
                _buildPaymentOption('apple', Icons.apple, 'Pay'),
              ],
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 32),

            AnimatedCrossFade(
              firstChild: _buildCardForm(),
              secondChild: Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text('Redirecting to external provider...',
                    style: TextStyle(color: Colors.white54)),
              ),
              crossFadeState: _selectedMethod == 'card'
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: 300.ms,
            ),

            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: () {
                context.read<CartProvider>().updatePayment(
                    _holderController.text,
                    _numberController.text,
                    _expiryController.text);
                Navigator.pushNamed(context, '/confirmation');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: AppTheme.primary.withValues(alpha: 0.5),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppTheme.primaryGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: const Text('PAY SECURELY',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),

            const SizedBox(height: 24),
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.white38),
                  SizedBox(width: 8),
                  Text('Encrypted & Secure Payment',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String id, IconData icon, String label) {
    final isSelected = _selectedMethod == id;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = id),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 1.5)),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppTheme.primary : Colors.white,
                  size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Card Details',
                style: TextStyle(fontWeight: FontWeight.w600)),
            // Card Logos
            Row(
              children: [
                _buildCardIcon(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                    24), // Mastercard
                const SizedBox(width: 8),
                _buildCardIcon(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
                    30), // Visa
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _numberController,
          style:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '0000 0000 0000 0000',
            prefixIcon: const Icon(Icons.credit_card),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Expiry',
                  hintText: 'MM/YY',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  suffixIcon: const Icon(Icons.help_outline,
                      size: 18, color: Colors.white30),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _holderController,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCardIcon(String url, double height) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Image.network(url,
          height: height,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.credit_card, color: Colors.black, size: 20)),
    );
  }
}
