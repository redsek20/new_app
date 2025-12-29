import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/outfit_item.dart';
import 'dart:math';

class FirebaseSeeder {
  static final Random _random = Random();

  static Future<void> seedData() async {
    final CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    // PURGE
    debugPrint("Firebase: PURGING for MASTER DATASET (60 Items)...");
    final allDocs = await products.get();
    final delBatch = FirebaseFirestore.instance.batch();
    for (final doc in allDocs.docs) {
      delBatch.delete(doc.reference);
    }
    await delBatch.commit();
    debugPrint("Firebase: Seeding 60 Real-Style Items...");

    List<OutfitItem> newItems = [];

    // ==========================================
    // MEN (20 Items)
    // ==========================================
    newItems.addAll([
      _item(
          'Men',
          'Classic White Tee',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80',
          'White',
          199),
      _item(
          'Men',
          'Black Crew Neck',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&q=80',
          'Black',
          199),
      _item(
          'Men',
          'Navy Polo',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1620799140408-ed5341cd2431?w=800&q=80',
          'Blue',
          250), // Shirt
      _item(
          'Men',
          'Grey Hoodie',
          'Tops',
          'Hoodies',
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80',
          'Grey',
          399),
      _item(
          'Men',
          'Beige Hoodie',
          'Tops',
          'Hoodies',
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80',
          'Beige',
          399), // Re-use style, distinct item
      _item(
          'Men',
          'Denim Jacket',
          'Tops',
          'Jackets',
          'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=800&q=80',
          'Blue',
          899),
      _item(
          'Men',
          'Leather Biker',
          'Tops',
          'Jackets',
          'https://images.unsplash.com/photo-1551028919-ac668edd23b9?w=800&q=80',
          'Black',
          1200),
      _item(
          'Men',
          'Oxford Shirt',
          'Tops',
          'Shirts',
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&q=80',
          'Blue',
          450),
      _item(
          'Men',
          'Flannel Shirt',
          'Tops',
          'Shirts',
          'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?w=800&q=80',
          'Red',
          450), // Checkered

      _item(
          'Men',
          'Blue Jeans',
          'Bottoms',
          'Jeans',
          'https://images.unsplash.com/photo-1542272454324-4148e5885b0f?w=800&q=80',
          'Blue',
          599),
      _item(
          'Men',
          'Black Slim Jeans',
          'Bottoms',
          'Jeans',
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80',
          'Black',
          599),
      _item(
          'Men',
          'Beige Chinos',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&q=80',
          'Beige',
          499),
      _item(
          'Men',
          'Grey Joggers',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1517445312882-b4183896593a?w=800&q=80',
          'Grey',
          399), // Using Chino img as loose pant
      _item(
          'Men',
          'Cargo Pants',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&q=80',
          'Green',
          550),

      _item(
          'Men',
          'White Sneakers',
          'Footwear',
          'Sneakers',
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&q=80',
          'White',
          600),
      _item(
          'Men',
          'Running Shoes',
          'Footwear',
          'Sneakers',
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
          'Red',
          700),
      _item(
          'Men',
          'Chelsea Boots',
          'Footwear',
          'Boots',
          'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=800&q=80',
          'Brown',
          900),
      _item(
          'Men',
          'Leather Loafers',
          'Footwear',
          'Shoes',
          'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=800&q=80',
          'Black',
          1100),

      _item(
          'Men',
          'Silver Watch',
          'Accessories',
          'Watches',
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800&q=80',
          'Silver',
          1500),
      _item(
          'Men',
          'Backpack',
          'Accessories',
          'Bags',
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=80',
          'Green',
          500),
    ]);

    // ==========================================
    // WOMEN (20 Items)
    // ==========================================
    newItems.addAll([
      _item(
          'Women',
          'Satin Blouse',
          'Tops',
          'Blouses',
          'https://images.unsplash.com/photo-1564257631407-4deb1f99d9c2?w=800&q=80',
          'Pink',
          450),
      _item(
          'Women',
          'White Shirt',
          'Tops',
          'Shirts',
          'https://images.unsplash.com/photo-1598532163257-ae3c6b2524b6?w=800&q=80',
          'White',
          399),
      _item(
          'Women',
          'Crop Top',
          'Tops',
          'Tops',
          'https://images.unsplash.com/photo-1571513722275-4b41940f54b8?w=800&q=80',
          'Black',
          250),
      _item(
          'Women',
          'Beige Blazer',
          'Tops',
          'Blazers',
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&q=80',
          'Beige',
          899),
      _item(
          'Women',
          'Leather Jacket',
          'Tops',
          'Jackets',
          'https://images.unsplash.com/photo-1544022613-e87ca19202d6?w=800&q=80',
          'Black',
          1100),
      _item(
          'Women',
          'Floral Dress',
          'Dresses',
          'Casual',
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&q=80',
          'Red',
          499),
      _item(
          'Women',
          'Maxi Dress',
          'Dresses',
          'Evening',
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80',
          'White',
          699),
      _item(
          'Women',
          'High Waist Jeans',
          'Bottoms',
          'Jeans',
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&q=80',
          'Blue',
          499),
      _item(
          'Women',
          'Black Skirt',
          'Bottoms',
          'Skirts',
          'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&q=80',
          'Black',
          399),
      _item(
          'Women',
          'Leggings',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1506634572416-48cdfe530110?w=800&q=80',
          'Black',
          299),
      _item(
          'Women',
          'Shorts',
          'Bottoms',
          'Shorts',
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&q=80',
          'Blue',
          250),
      _item(
          'Women',
          'Heels',
          'Footwear',
          'Heels',
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&q=80',
          'Red',
          700),
      _item(
          'Women',
          'Ankle Boots',
          'Footwear',
          'Boots',
          'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=800&q=80',
          'Brown',
          850),
      _item(
          'Women',
          'Trainers',
          'Footwear',
          'Sneakers',
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&q=80',
          'White',
          600),
      _item(
          'Women',
          'Tote Bag',
          'Accessories',
          'Bags',
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&q=80',
          'Black',
          450),
      _item(
          'Women',
          'Mini Bag',
          'Accessories',
          'Bags',
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&q=80',
          'Black',
          350),
      _item(
          'Women',
          'Silk Scarf',
          'Accessories',
          'Scarves',
          'https://images.unsplash.com/photo-1601924638867-3a6d6c9c6c53?w=800&q=80',
          'Multi',
          199),
      _item(
          'Women',
          'Hat',
          'Accessories',
          'Hats',
          'https://images.unsplash.com/photo-1569388234763-b254703e774c?w=800&q=80',
          'Beige',
          250),
      _item(
          'Women',
          'Sunglasses',
          'Accessories',
          'Glasses',
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800&q=80',
          'Black',
          300),
      _item(
          'Women',
          'Gold Necklace',
          'Accessories',
          'Jewelry',
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&q=80',
          'Gold',
          400),
    ]);

    // ==========================================
    // CHILDREN (20 Items)
    // ==========================================
    newItems.addAll([
      _item(
          'Children',
          'Graphic Tee',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1519241047957-be31d7379a5d?w=800&q=80',
          'Blue',
          150),
      _item(
          'Children',
          'White Tee',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=80',
          'White',
          150),
      _item(
          'Children',
          'Hoodie',
          'Tops',
          'Hoodies',
          'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=800&q=80',
          'Grey',
          250),
      _item(
          'Children',
          'Denim Jacket',
          'Tops',
          'Jackets',
          'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=800&q=80',
          'Blue',
          400),
      _item(
          'Children',
          'Raincoat',
          'Tops',
          'Jackets',
          'https://images.unsplash.com/photo-1611025539328-111102913501?w=800&q=80',
          'Yellow',
          350),

      _item(
          'Children',
          'Denim Shorts',
          'Bottoms',
          'Shorts',
          'https://images.unsplash.com/photo-1519457431-44ccd64a579b?w=800&q=80',
          'Blue',
          200),
      _item(
          'Children',
          'Leggings',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=800&q=80',
          'Pink',
          150),
      _item(
          'Children',
          'Cargo Pants',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=800&q=80',
          'Green',
          250), // Overalls img
      _item(
          'Children',
          'Overalls',
          'Bottoms',
          'Overalls',
          'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=800&q=80',
          'Blue',
          300),

      _item(
          'Children',
          'Party Dress',
          'Dresses',
          'Party',
          'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=800&q=80',
          'Pink',
          350),

      _item(
          'Children',
          'Velcro Sneakers',
          'Footwear',
          'Sneakers',
          'https://images.unsplash.com/photo-1514989940723-e88754dfe639?w=800&q=80',
          'Grey',
          250),
      _item(
          'Children',
          'Sandals',
          'Footwear',
          'Sandals',
          'https://images.unsplash.com/photo-1621452773781-0f992fd1f5cb?w=800&q=80',
          'Brown',
          200),
      _item(
          'Children',
          'Boots',
          'Footwear',
          'Boots',
          'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=800&q=80',
          'Black',
          300),

      // Filler to hit 20
      _item(
          'Children',
          'Basic Tee',
          'Tops',
          'T-Shirts',
          'https://images.unsplash.com/photo-1519241047957-be31d7379a5d?w=800&q=80',
          'Grey',
          120),
      _item(
          'Children',
          'Joggers',
          'Bottoms',
          'Pants',
          'https://images.unsplash.com/photo-1519457431-44ccd64a579b?w=800&q=80',
          'Black',
          180),
      _item(
          'Children',
          'Summer Dress',
          'Dresses',
          'Casual',
          'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=800&q=80',
          'Yellow',
          280),
      _item(
          'Children',
          'Cap',
          'Accessories',
          'Hats',
          'https://images.unsplash.com/photo-1521320226546-8e8e184021a8?w=800&q=80',
          'Blue',
          120),
      _item(
          'Children',
          'Backpack',
          'Accessories',
          'Bags',
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=80',
          'Multi',
          250),
      _item(
          'Children',
          'Gloves',
          'Accessories',
          'Gloves',
          'https://images.unsplash.com/photo-1601924994987-69e2c70cb388?w=800&q=80',
          'Multi',
          90),
      _item(
          'Children',
          'Socks',
          'Accessories',
          'Socks',
          'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&q=80',
          'White',
          50),
    ]);

    final batch = FirebaseFirestore.instance.batch();
    int count = 0;

    for (final item in newItems) {
      final String docId =
          "${item.demographic}_${item.category}_${count}_${_random.nextInt(9999)}";
      final data = item.toMap();
      data['sortTimestamp'] =
          DateTime.now().millisecondsSinceEpoch - (count * 1000);

      final docRef = products.doc(docId);
      batch.set(docRef, data);
      count++;
    }

    await batch.commit();
    debugPrint("Firebase: Seeding Complete. $count FULL-SCALE items created.");
  }

  static OutfitItem _item(String demo, String title, String cat, String sub,
      String url, String color, double price) {
    return OutfitItem(
      id: '',
      title: title,
      description: "$title from the new collection.",
      price: price,
      category: cat,
      subcategory: sub,
      demographic: demo,
      imageUrl: url,
      shopUrl: 'https://www.hm.com', // Generic safe link
      brand: 'H&M',
      stock: 20 + _random.nextInt(50),
      sizes: demo == 'Children' ? ['4Y', '6Y'] : ['S', 'M', 'L'],
      isFeatured: _random.nextBool(),
      isNew: _random.nextBool(),
      purpose: 'Casual',
      style: 'Modern',
      color: color,
      material: 'Cotton',
      weather: 'All Season',
    );
  }
}
