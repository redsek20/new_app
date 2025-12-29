import 'package:flutter/material.dart';
import 'models/outfit_item.dart';

class CartItem {
  final OutfitItem outfit;
  int quantity;

  CartItem({required this.outfit, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Shipping & Payment Storage
  String shippingAddress = "";
  String cardHolder = "";
  String cardNumber = "";
  String expiryDate = "";

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += (cartItem.outfit.price) * cartItem.quantity;
    });
    return total;
  }

  void updateShipping(String address) {
    shippingAddress = address;
    notifyListeners();
  }

  void updatePayment(String holder, String number, String expiry) {
    cardHolder = holder;
    cardNumber = number;
    expiryDate = expiry;
    notifyListeners();
  }

  void addItem(OutfitItem outfit) {
    if (_items.containsKey(outfit.id)) {
      _items.update(
        outfit.id,
        (existing) =>
            CartItem(outfit: existing.outfit, quantity: existing.quantity + 1),
      );
    } else {
      _items.putIfAbsent(outfit.id, () => CartItem(outfit: outfit));
    }
    notifyListeners();
  }

  void removeOneItem(String outfitId) {
    if (!_items.containsKey(outfitId)) return;
    if (_items[outfitId]!.quantity > 1) {
      _items.update(
        outfitId,
        (existing) =>
            CartItem(outfit: existing.outfit, quantity: existing.quantity - 1),
      );
    } else {
      _items.remove(outfitId);
    }
    notifyListeners();
  }

  void removeItem(String outfitId) {
    _items.remove(outfitId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    shippingAddress = "";
    cardHolder = "";
    cardNumber = "";
    expiryDate = "";
    notifyListeners();
  }
}
