import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_theme.dart';
import '../core/database_helper.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _wardrobeItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    final items = await _db.getFavorites();
    setState(() {
      _wardrobeItems = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY DIGITAL WARDROBE',
            style: TextStyle(
                letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wardrobeItems.isEmpty
              ? _buildEmptyWardrobe()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _wardrobeItems.length,
                  itemBuilder: (context, index) {
                    final item = _wardrobeItems[index];
                    return _buildWardrobeCard(item, index);
                  },
                ),
    );
  }

  Widget _buildEmptyWardrobe() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.door_sliding_outlined,
              size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text('Your wardrobe is empty',
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/upload'),
            child: const Text('Add your first style'),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeCard(Map<String, dynamic> item, int index) {
    final String imageUrl = item['imageUrl'] as String;
    final bool isNetwork = imageUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                    )
                  : Image.file(File(imageUrl), fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7)
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? 'Untitled',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(item['category'] ?? 'Casual',
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 10)),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.white70, size: 20),
                onPressed: () async {
                  await _db.removeFavorite(item['id']);
                  _loadWardrobe();
                },
              ),
            )
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).scale();
  }
}
