class OutfitItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? discountPrice;
  final String category;
  final String subcategory;
  final String purpose;
  final String style;
  final String demographic; // Men, Women, Children
  final String color;
  final String material;
  final String imageUrl;
  final String brand;
  final bool isNew;
  final bool isFeatured;
  final double rating;
  final int stock;
  final List<String> sizes;
  final String weather;
  final String shopUrl;

  OutfitItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.subcategory,
    required this.purpose,
    required this.style,
    required this.demographic,
    required this.color,
    required this.material,
    required this.imageUrl,
    required this.brand,
    this.isNew = false,
    this.isFeatured = false,
    this.rating = 0.0,
    required this.stock,
    required this.sizes,
    required this.weather,
    required this.shopUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title, // Mapping title to name for Master Prompt compliance
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'subcategory': subcategory, // "shoes", "hoodies" etc
      'purpose': purpose,
      'style': style,
      'target': demographic, // Mapping demographic to target
      'color': color,
      'material': material,
      'imageUrl': imageUrl,
      'brand': brand,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'rating': rating,
      'stock': stock,
      'sizes': sizes,
      'weather': weather,
      'shopUrl': shopUrl,
    };
  }

  factory OutfitItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OutfitItem(
      id: docId ?? map['id']?.toString() ?? '',
      title: map['name'] ?? map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice'] as num).toDouble()
          : null,
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      purpose: map['purpose'] ?? '',
      style: map['style'] ?? '',
      demographic: map['target'] ?? map['demographic'] ?? 'Unisex',
      color: map['color'] ?? '',
      material: map['material'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      brand: map['brand'] ?? '',
      isNew: map['isNew'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      stock: map['stock']?.toInt() ?? 0,
      sizes: List<String>.from(map['sizes'] ?? []),
      weather: map['weather'] ?? '',
      shopUrl: map['shopUrl'] ?? 'https://google.com',
    );
  }
}
