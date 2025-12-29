import 'dart:math';
import 'models/outfit_item.dart';

class OutfitLibrary {
  static List<OutfitItem> get all {
    final random = Random(123);

    final mainCategories = ['Tops', 'Bottoms', 'Dresses', 'Footwear'];
    final subcategories = {
      'Tops': ['Premium Tee', 'Oxford Shirt', 'Urban Hoodie', 'Silk Blouse'],
      'Bottoms': ['Slim Jeans', 'Chino Pants', 'Cargo Trousers', 'Satin Skirt'],
      'Dresses': [
        'Evening Gown',
        'Floral Sundress',
        'Cocktail Dress',
        'Wrap Dress'
      ],
      'Footwear': [
        'Leather Sneakers',
        'Suede Loafers',
        'Chelsea Boots',
        'Street Trainers'
      ]
    };

    final styles = ['Minimalist', 'Modern', 'Streetwear', 'Vintage'];
    final materials = [
      'Pima Cotton',
      'Merino Wool',
      'Mulberry Silk',
      'Raw Denim'
    ];
    final brands = [
      'STYLX LUXE',
      'ESSENCE STUDIOS',
      'URBAN ARCHIVE',
      'RIDGEFIELD CO.'
    ];
    final demographics = ['Men', 'Women', 'Children'];

    // STRICTLY PRODUCT-ONLY FASHION IDs (No Models)
    final productIds = [
      '1521572163474-6864f9cf17ab', // White Shirt on Hanger
      '1541099643224-cce01d0a27bc', // Blue Denim Detail
      '1542291026-7eec264c27ff', // Sneakers Product
      '1523275335640-df515ff0d2f8', // Watch on Table
      '1515372039744-b8f02a3ae446', // Yellow Dress Flatlay
      '1591047139829-d91aecb6caea', // Utility Jacket
      '1556821840302-dfdf7b370bb2', // Gray Hoodie Product
      '1542838686-37da4a9fd1b3', // Tan Suede Boots
      '1581044777550-4cfa60707c03', // Black Hoodie Product
      '1542272604-de04e4ed3e07', // Red High-Tops
      '1520006401403-f62f7b08d1f6', // Suit Set
      '1511704953482-2361b2400970', // Folded Chinos
      '1516762689697-2b49e67c189f', // Leather Loafers
      '1583337130417-3346a1be7dee', // Silk Skirt Flatlay
      '1544022613-e87ca75a784a', // Trench Coat Product
      '1503342217505-b0a15ec3261c', // Accessories Flatlay
      '1539183037353-b84030373081', // Scarf Product
      '1512436991641-6745cdb1723f', // Flatlay Shirt
      '1506629082955-511b1aa562c8', // Leggings Product
      '1533867617858-e7b97e060509', // Brown Loafers
    ];

    return List.generate(200, (index) {
      final gender = demographics[index % demographics.length];
      String cat = mainCategories[index % mainCategories.length];
      if ((gender == 'Men' || gender == 'Children') && cat == 'Dresses') {
        cat = 'Tops';
      }

      final sub = subcategories[cat]![index % subcategories[cat]!.length];
      final imgId = productIds[index % productIds.length];

      return OutfitItem(
        id: (index + 1).toString(),
        title: '${brands[index % brands.length].split(' ')[0]} $sub',
        description: 'A premium product designed for excellence.',
        price: (249.0 + random.nextInt(2500)).toDouble(),
        category: cat,
        subcategory: sub,
        purpose: index % 2 == 0 ? 'Formal' : 'Casual',
        style: styles[index % styles.length],
        demographic: gender,
        color: 'Neutral',
        material: materials[index % materials.length],
        imageUrl: 'https://images.unsplash.com/photo-$imgId?w=800&q=80',
        brand: brands[index % brands.length],
        isNew: index % 7 == 0,
        isFeatured: index % 10 == 0,
        rating: 4.5,
        weather: 'All Season',
        shopUrl: 'https://zara.com',
        sizes:
            gender == 'Children' ? ['2Y', '4Y', '6Y'] : ['S', 'M', 'L', 'XL'],
        stock: 10 + random.nextInt(50),
      );
    });
  }
}
