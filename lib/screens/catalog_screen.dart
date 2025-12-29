import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/ui/floating_widget.dart';
import '../core/app_theme.dart';
import '../core/database_helper.dart';
import '../core/cart_provider.dart';
import 'main_layout.dart';

import '../core/models/outfit_item.dart';
import '../core/firebase_seeder.dart';

class CatalogScreen extends StatefulWidget {
  final Map<String, String>? initialFilters;
  final String? initialGender;
  const CatalogScreen({super.key, this.initialFilters, this.initialGender});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'All';
  String? _selectedGender;
  final List<String> _categories = const [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Footwear',
    'Accessories'
  ];
  final DatabaseHelper _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance.collection('products');
    if (_selectedGender != null) {
      query = query.where('target', isEqualTo: _selectedGender);
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.2),
                boxShadow: const [
                  BoxShadow(
                      color: AppTheme.primary,
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              _buildCategories(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getFilteredStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final docs = snapshot.data!.docs;
                    List<OutfitItem> displayList = docs.map((doc) {
                      return OutfitItem.fromMap(
                          doc.data() as Map<String, dynamic>,
                          docId: doc.id);
                    }).toList();

                    final filteredList = displayList.where((item) {
                      if (_selectedCategory == 'All') return true;
                      return item.category == _selectedCategory;
                    }).toList();

                    if (filteredList.isEmpty) {
                      return _buildEmptyState();
                    }

                    return MasonryGridView.count(
                      padding: const EdgeInsets.all(16),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final outfit = filteredList[index];
                        final double aspectRatio =
                            (index % 3 == 0) ? 0.6 : 0.75;
                        return _buildAnimatedCard(outfit, index, aspectRatio);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    final secondary =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (Navigator.canPop(context))
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: secondary, size: 20),
                onPressed: () => Navigator.maybePop(context),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_selectedGender ?? 'EXPLORE').toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: secondary,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Collection ${DateTime.now().year}',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Didot'),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // RESET BUTTON (Added for testing)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Regenerating catalog...')),
                      );
                      await FirebaseSeeder.seedData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Catalog updated! Pull to refresh if needed.')),
                        );
                      }
                    },
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.shopping_bag_outlined, color: color),
                    onPressed: () => MainLayout.switchTab(context, 3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final color = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == _categories[index];
          final selectedText = Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: AnimatedContainer(
                duration: 300.ms,
                child: ChoiceChip(
                  label: Text(
                    _categories[index].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? selectedText : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: color,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                        color: isSelected ? color : color.withOpacity(0.3),
                        width: 1.5),
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedCategory = _categories[index]);
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rocket_launch_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "Nothing in this orbit yet!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Check back for new drops.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Regenerating catalog...')),
              );
              await FirebaseSeeder.seedData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catalog updated!')),
                );
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Initialize Catalog",
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ).animate().fadeIn().moveY(begin: 20, end: 0),
    );
  }

  Widget _buildAnimatedCard(OutfitItem outfit, int index, double aspectRatio) {
    return FloatingWidget(
      delay: Duration(milliseconds: index * 100),
      amplitude: 5,
      duration: const Duration(seconds: 4),
      child: Hero(
        tag: 'outfit_${outfit.id}',
        child: Material(
          color: Colors.transparent,
          child: OutfitCard(
            outfit: outfit,
            aspectRatio: aspectRatio,
            onFavorite: () => _db.addFavorite({
              'title': outfit.title,
              'imageUrl': outfit.imageUrl,
              'category': outfit.category,
              'product_id': outfit.id,
            }),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }
}

class OutfitCard extends StatefulWidget {
  final OutfitItem outfit;
  final VoidCallback onFavorite;
  final double aspectRatio;

  const OutfitCard(
      {super.key,
      required this.outfit,
      required this.onFavorite,
      this.aspectRatio = 0.75});

  @override
  State<OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<OutfitCard> {
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // IMAGE
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.outfit.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[900]!,
                  highlightColor: Colors.grey[800]!,
                  child: Container(color: Colors.black),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),

            // GRADIENT OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // FAVORITE BUTTON
            Positioned(
              top: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isFav ? Icons.favorite : Icons.favorite_border,
                      color: _isFav ? const Color(0xFFFF4848) : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isFav = !_isFav);
                      widget.onFavorite();
                    },
                  ),
                ),
              ),
            ),

            // CONTENT
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.outfit.brand.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.outfit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.outfit.price.toInt()} MAD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addItem(widget.outfit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Added to bag'),
                                backgroundColor: AppTheme.primary,
                                duration: Duration(milliseconds: 600)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 16, color: Colors.black),
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
}
