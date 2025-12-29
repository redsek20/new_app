import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/outfit_item.dart';

class ColorService {
  /// The "Secret" Recommendations Engine
  Future<List<OutfitItem>> findMatchingOutfits(Color detectedColor) async {
    final bool isNeutral = _isNeutral(detectedColor);
    final List<String> targetColors = isNeutral
        ? [
            'Red',
            'Blue',
            'Green',
            'Yellow',
            'Pink',
            'Orange',
            'Gold',
            'Titanium'
          ]
        : ['Black', 'White', 'Grey', 'Beige', 'Navy', 'Brown'];

    // We can't do a massive 'whereIn' with partial string matches on Firestore easily without index.
    // However, our seed data has specific 'color' fields.
    // We will try to fetch items that MATCH the target colors.
    // Since 'targetColors' can be large, and Firestore 'whereIn' limits to 10, we are safe.

    try {
      // 1. Fetch potential matches (limit to 20 to avoid over-fetching)
      // Note: This relies on the 'color' field existing in docs.
      // If 'color' field is complex (e.g. "Red/White"), simple equality might fail.
      // But we will try our best with what we have.
      // Ideally, we'd do client side filtering found on a broader query.

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(50)
          .get();

      final allItems = snapshot.docs
          .map((doc) => OutfitItem.fromMap(doc.data() as Map<String, dynamic>,
              docId: doc.id))
          .toList();

      // 2. Client-Side Filtering for smart matching
      final matches = allItems.where((item) {
        String itemColor = item.color;

        // Check if any of our target colors are present in the item's color string
        for (final target in targetColors) {
          if (itemColor.toLowerCase().contains(target.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toList();

      return matches;
    } catch (e) {
      debugPrint("ColorService Error: $e");
      return [];
    }
  }

  bool _isNeutral(Color c) {
    // Basic logic: Low saturation OR extremes of brightness
    final HSVColor hsv = HSVColor.fromColor(c);

    // White/Grey/Black logic
    if (hsv.saturation < 0.25) {
      return true; // Very washed out = Grey/White/Blackish
    }
    if (hsv.value < 0.2) return true; // Very dark ~ Black
    if (hsv.value > 0.95 && hsv.saturation < 0.3) {
      return true; // Very bright ~ White
    }

    // Check for "Brown/Beige" which are essentially dark Orange/Yellow
    // Hue 20-50 approx.
    if (hsv.hue >= 20 && hsv.hue <= 50 && hsv.saturation < 0.6) return true;

    return false; // Otherwise it's BOLD (Red, Blue, Green, etc)
  }

  String getColorName(Color c) {
    if (_isNeutral(c)) return "Neutral / Classic";
    return "Bold / Vibrant";
  }
}
